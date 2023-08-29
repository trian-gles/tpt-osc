local losc = require'losc'
local plugin = require'losc.plugins.udp-socket'

local udp = plugin.new {sendAddr = 'localhost', sendPort = 9000}
local osc = losc.new {plugin = udp}

local MIN = 100000
local MAX = -100000

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



local yHandler = DistributionHandler:new()
local xHandler = DistributionHandler:new()
local velXHandler = GaussDistributionHandler:new()
local velYHandler = GaussDistributionHandler:new()

local sorter = ParticleIdCountSorter:new()

local frame = 0

local function tick()
    -- Reset all distributions
    xHandler:reset()
    yHandler:reset()
    velXHandler:reset()
    velYHandler:reset()

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
    print(sorted[1])

    -- Loop over all particles
    p_iter = sim.parts()
    local total_parts = 0

    local part_dict = {}

    while true do
        local p_index = p_iter()
        if p_index == nil then break end

        -- Only handle this particle if it is moving
        local xvel = sim.partProperty(p_index, sim.FIELD_VX)
        local yvel = sim.partProperty(p_index, sim.FIELD_VY)
        if (xvel ~= 0 and yvel ~=0) then
            
            local y = sim.partProperty(p_index, sim.FIELD_Y)
            local x = sim.partProperty(p_index, sim.FIELD_X)
            local type = sim.partProperty(p_index, sim.FIELD_TYPE)
            

            yHandler:update(y)
            xHandler:update(x)
            velXHandler:update(xvel)
            velYHandler:update(yvel)
            total_parts = total_parts + 1
        end
    end



    -- Extract params from distributions and send over OSC
    local miny, maxy = yHandler:get();
    local minx, maxx = xHandler:get();
    local sigXVel, muXVel = velXHandler:get();
    local sigYVel, muYVel = velYHandler:get();
    local sigVel = math.sqrt(sigXVel^2 + sigYVel^2)

    if isnan(sigVel) then
        sigVel = 0
    end

    local message = osc.new_message {
        address = '/pcount',
        types = 'ifffff',
        total_parts, sigVel, maxy, miny, maxx, minx
      }
    osc:send(message)
    frame = frame + 1
end

evt.register(evt.tick, tick)