local losc = require'losc'
local plugin = require'losc.plugins.udp-socket'

local udp = plugin.new {sendAddr = 'localhost', sendPort = 9000}
local osc = losc.new {plugin = udp}

local MIN = 100000
local MAX = -100000

local HANDLERCOUNT = 6

local function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end


local function isnan(v)
    return (tostring(v) == "nan")
end

DistributionHandler = {
    min = MIN,
    max = -MAX
}

function DistributionHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function DistributionHandler:reset()
    self.min = MIN
    self.max = MAX
end

function DistributionHandler:update(v)
    self.max = math.max(self.max, v)
    self.min = math.min(self.min, v)
end

function DistributionHandler:get()
    return self.min, self.max
end


GaussDistributionHandler = {
    samples = {}
}

function GaussDistributionHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function GaussDistributionHandler:update(v) 
    table.insert(self.samples, v)
end

function GaussDistributionHandler:reset()
    self.samples = {}
end

function GaussDistributionHandler:get()
    local mu = 0
    for i, v in pairs(self.samples) do
        mu = mu + v
    end
    mu = mu / self:count()

    local sigma = 0
    for i, v in pairs(self.samples) do
        sigma = sigma + (v - mu)^2
    end
    sigma = math.sqrt(sigma / self:count())
    return mu, sigma
end

function GaussDistributionHandler:count()
    return #self.samples
end

ParticleIdCountSorter = {
    idCounts = {},
    types = {}
}

function ParticleIdCountSorter:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ParticleIdCountSorter:update(v) 
    if self.idCounts[v] == nil then
        self.idCounts[v] = 1
        table.insert(self.types, v)
    else 
        self.idCounts[v] = self.idCounts[v] + 1
    end

end


function ParticleIdCountSorter:getres()
    local function IsValueLarger(k1, k2)
        return self.idCounts[k1] > self.idCounts[k2]
    end

    table.sort(self.types, IsValueLarger)
    return self.types
end

function ParticleIdCountSorter:reset()
    self.idCounts = {}
    self.types = {}
end


MasterHandler = {
    yHandler = nil,
    xHandler = nil,
    velXHandler = nil,
    velYHandler = nil
}

function MasterHandler:new()
    local o = {}
    setmetatable(o, self)

    
    self.__index = self
    self.p_index = 0
    self.p_count = 0

    o.yHandler = DistributionHandler:new()
    o.xHandler = DistributionHandler:new()
    o.velXHandler = GaussDistributionHandler:new()
    o.velYHandler = GaussDistributionHandler:new()
    return o
end

function MasterHandler:update(p_index)
    self.p_index = sim.partProperty(p_index, sim.FIELD_TYPE)
    local y = sim.partProperty(p_index, sim.FIELD_Y)
    local x = sim.partProperty(p_index, sim.FIELD_X)
    local xvel = sim.partProperty(p_index, sim.FIELD_VX)
    local yvel = sim.partProperty(p_index, sim.FIELD_VY)

    self.yHandler:update(y)
    self.xHandler:update(x)
    self.velXHandler:update(xvel)
    self.velYHandler:update(yvel)
    self.p_count = self.p_count + 1
end

function MasterHandler:get()
    local miny, maxy = self.yHandler:get();
    local minx, maxx = self.xHandler:get();
    local sigXVel, muXVel = self.velXHandler:get();
    local sigYVel, muYVel = self.velYHandler:get();
    local sigVel = math.sqrt(sigXVel^2 + sigYVel^2)
    return self.p_count, sigVel, maxy, miny, maxx, maxy
end

function MasterHandler:reset()
    self.yHandler:reset()
    self.xHandler:reset()
    self.velXHandler:reset()
    self.velYHandler:reset()
    self.p_count = 0
end




local handler = MasterHandler:new()

local topHandlers = {}

for i=1,HANDLERCOUNT do
    topHandlers[i] = MasterHandler:new()
end

local function resetHandlers()
    for i=1,HANDLERCOUNT do
        topHandlers[i]:reset()
    end
end

local function get_key_for_value( t, value )
    for k,v in pairs(t) do
      if v==value then return k end
    end
    return nil
end

local sorter = ParticleIdCountSorter:new()

local frame = 0

local function tick()
    -- Reset all distributions
    resetHandlers()
    sorter:reset()

    -- Sort particles by most common type
    local p_iter = sim.parts()
    while true do
        local p_index = p_iter()
        if p_index == nil then break end

        -- Only handle this particle if it is moving
        local xvel = sim.partProperty(p_index, sim.FIELD_VX)
        local yvel = sim.partProperty(p_index, sim.FIELD_VY)
        if (xvel ~= 0 and yvel ~=0) then
            sorter:update(sim.partProperty(p_index, sim.FIELD_TYPE))
        end
    end

    local sorted = sorter:getres()

    -- Loop over all particles
    p_iter = sim.parts()
    local total_parts = 0


    while true do
        local p_index = p_iter()
        if p_index == nil then break end

        -- Only handle this particle if it is moving
        local xvel = sim.partProperty(p_index, sim.FIELD_VX)
        local yvel = sim.partProperty(p_index, sim.FIELD_VY)
        if (xvel ~= 0 and yvel ~=0) then
            
            local type = sim.partProperty(p_index, sim.FIELD_TYPE)
            local rank = get_key_for_value(sorted, type)
            if (rank ~= nil) and (rank <= HANDLERCOUNT) then
                topHandlers[rank]:update(p_index)
                print(rank)
            end

            total_parts = total_parts + 1
        end
    end



    -- Extract params from distributions and send over OSC
    for i=1,HANDLERCOUNT do
        local p_count, sigVel, maxy, miny, maxx, minx = topHandlers[i]:get()

        if isnan(sigVel) then
            sigVel = 0
        end
        
        local message = osc.new_message {
            address = '/tpt/' .. tostring(i),
            types = 'ifffff',
            p_count, sigVel, maxy, miny, maxx, minx
        }
        
        -- print(dump(message:args()))
        osc:send(message)
    end
    
    frame = frame + 1
end

evt.register(evt.tick, tick)