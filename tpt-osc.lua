local losc = require'losc'
local plugin = require'losc.plugins.udp-socket'

local udp = plugin.new {sendAddr = 'localhost', sendPort = 9000}
local osc = losc.new {plugin = udp}

local MIN = 100000
local MAX = -100000

local HANDLERCOUNT = 8

local PLANT_ID = 20
local VINE_ID = 114

local alpha = 255
local title_text = ""
local fade = false

HANDLEGRAINS = true
HANDLEPLANTS = true
HANDLELIFE = true
HANDLEELEC = true

--------------------
-- UTILITY FUNCTIONS
--------------------

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

local function getKeyForValue( t, value )
    for k,v in pairs(t) do
      if v==value then return k end
    end
    return nil
end

local function reorder_second_array(first_array, second_array)
    local element_to_index = {}
    for index, element in ipairs(first_array) do
        element_to_index[element] = index
    end
    
    table.sort(second_array, function(a, b)
        local index_a = element_to_index[a] or math.huge
        local index_b = element_to_index[b] or math.huge
        return index_a < index_b
    end)
    
    return second_array
end

local function scale(min, max, value)
    return (value - min) / (max - min)
end

local function int_onehot_encode(val, bins)
    local encoding = {}
    for i=1,bins do
        if val == i then
            encoding[i] = 1
        else
            encoding[i] = 0
        end
    end
end

OR, XOR, AND = 1, 3, 4

local function bitoper(a, b, oper)
   local r, m, s = 0, 2^31
   repeat
      s,a,b = a+b+m, a%m, b%m
      r,m = r + m*oper%(s-a-b), m/2
   until m < 1
   return r
end
--------------------
-- ELECTRONICS STUFF
--------------------
MasterElectronicHandler = {
	handlers = {},
    lcdHandler = {},
	switchHandler = {}
}

function MasterElectronicHandler:new(ids, colors)
	local o = {}
    setmetatable(o, self)
    self.__index = self
	for _, v in ipairs(ids) do
        o.handlers[v] = ElectronicHandler:new(v)
    end
    o.lcdHandler = LCDHandler:new(colors)
	o.switchHandler = SwitchHandler:new()
	o:reset()
    return o
end

function MasterElectronicHandler:update(index, type)

    if self.handlers[type] then
        local life = sim.partProperty(index, sim.FIELD_LIFE)
        if (life > 0) then self.handlers[type]:update(life) end
        
    end

    if type == 54 then
        self.lcdHandler:update(index, sim.partProperty(index, sim.FIELD_DCOLOUR))
	elseif type == 56 then
		local life = sim.partProperty(index, sim.FIELD_LIFE)
		if (life > 0) then
			local x = sim.partProperty(index, sim.FIELD_X)
			self.switchHandler:update(life, x)
		end
		
    end
end

function MasterElectronicHandler:reset()
    for _, h in pairs(self.handlers) do
        h:reset()
    end
    self.lcdHandler:reset()
	self.switchHandler:reset()
end

function MasterElectronicHandler:get()
    local info = {}
    for id, h in pairs(self.handlers) do
        info[id] = h:get()
    end
	

    return info, self.lcdHandler:get(), self.switchHandler:get()
end


ElectronicHandler = {
	active = false,
    maxLife = 0,
    id = 0
}

function ElectronicHandler:new(id)
	local o = {}
    setmetatable(o, self)
    self.__index = self
	o.id = id
	o:reset()
	
    return o
end

function ElectronicHandler:reset()
    self.active = 0
    self.maxLife = 0
end

function ElectronicHandler:update(life)
    if life > self.maxLife then
        self.maxLife = life
    end
end

function ElectronicHandler:get()
    return self.maxLife
end


SwitchHandler = {
	active = false,
    weightedMaxLife = 0

}

function SwitchHandler:new()
	local o = {}
    setmetatable(o, self)
    self.__index = self
	o:reset()
	
    return o
end

function SwitchHandler:reset()
    self.active = 0
    self.weightedLife = 0
end

function SwitchHandler:update(life, x)
    self.weightedLife = math.pow(x, 3) * life / 60000000  + self.weightedLife
end


function SwitchHandler:get()
    return self.weightedLife
end



LCDHandler = {
	active = false,
    maxLife = 0,
    handlers = {}

}

function LCDHandler:new(colors)
	local o = {}
    setmetatable(o, self)
    self.__index = self
	for _, v in ipairs(colors) do
        o.handlers[v] = ElectronicHandler:new(v)
    end
	o:reset()
	
    return o
end

function LCDHandler:update(index, color)
    if self.handlers[color] then
        local life = sim.partProperty(index, sim.FIELD_LIFE)
        if (life > 0) then self.handlers[color]:update(life) end
    end
end

function LCDHandler:reset()
    for _, h in pairs(self.handlers) do
        h:reset()
    end
end

function LCDHandler:get()
    local info = {}
    for id, h in pairs(self.handlers) do
        info[id] = h:get()
    end

    return info
end


--------------------
-- DISTRIBUTION CLASSES
--------------------

BinHandler = {
	binCount = 0
	
}

function BinHandler:new(count)
	local o = {}
    setmetatable(o, self)
    self.__index = self
	o.bins = {}
	o.binCount = count
	o:reset()
	
    return o
end

function BinHandler:reset()
    
	for i=1,self.binCount do
		self.bins[i] = 0
		
	end
end

function BinHandler:update(index)
	self.bins[index] = self.bins[index] + 1
end

function BinHandler:get()
	return self.bins
end

PlantHandler = {
	oldPlants = {},
	continuingPlants = {},
	newPlants = {},
	newBins = {}
}

function PlantHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
	o.oldPlants = {}
	o.continuingPlants = {}
	o.oldBins = BinHandler:new(16)
	o.newBins = BinHandler:new(16)
    o.deletedBins = BinHandler:new(16)
    return o
end

function PlantHandler:reset()
	self.oldPlants = self.continuingPlants
	
	self.continuingPlants = {}
	self.oldBins:reset()
	self.newBins:reset()
    self.deletedBins:reset()
end

function PlantHandler:update(index)
	local x, y = sim.partPosition(index)
	local bin = math.floor(16 * (383 - y) / 383) + 1
	self.continuingPlants[index] = true
	-- only for new plants
	if (self.oldPlants[index] == nil) then
		self.newBins:update(bin)
	else
		self.oldBins:update(bin)
        self.oldPlants[index] = false
	end
	
	
end

function PlantHandler:get()
    for index, v in pairs(self.oldPlants) do
        if (v) then
            local x, y = sim.partPosition(index)
            if (y ~= nil) then   
	            local bin = math.floor(16 * (383 - y) / 383) + 1
                self.deletedBins:update(bin)
            end
        end
    end

	return self.newBins:get(), self.oldBins:get(), self.deletedBins:get()

end

LifeHandler = {
    oldPlants = {},
	continuingPlants = {},
    newCount = 0
}

function LifeHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
	o.oldPlants = {}
	o.continuingPlants = {}
    o.newCount = 0
    return o
end

function LifeHandler:reset()
	self.oldPlants = self.continuingPlants
	self.continuingPlants = {}
    self.newCount = 0
end

function LifeHandler:update(index)
	self.continuingPlants[index] = true
	-- only for new plants
	if (self.oldPlants[index] == nil) then
		self.newCount = self.newCount + 1
	else
        self.oldPlants[index] = false
	end
end

function LifeHandler:get()
    return self.newCount
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
    if self:count() == 0 then
        return 0, 0
    end
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


MultiGaussDistHandler = {
	samples = {}
}

function MultiGaussDistHandler:update(v) 
    table.insert(self.samples, v)
end

function MultiGaussDistHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function MultiGaussDistHandler:count()
    return #self.samples
end

function MultiGaussDistHandler:get()
	-- NEEDS TO BE FINISHED
	
	-- Calculate means
	local means = {}
	for _, arr in ipairs(self.samples) do
		
	end

	-- Make covariance matrix
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
    velHandler = nil,
    tempHandler = nil
}

function MasterHandler:new()
    local o = {}
    setmetatable(o, self)

    
    self.__index = self
    self.p_index = 0
    self.p_count = 0

    o.yHandler = GaussDistributionHandler:new()
    o.xHandler = DistributionHandler:new()

    o.velHandler = GaussDistributionHandler:new()

    o.tempHandler = GaussDistributionHandler:new()
    return o
end

function MasterHandler:update(p_index)
    self.p_index = sim.partProperty(p_index, sim.FIELD_TYPE)

    local y = sim.partProperty(p_index, sim.FIELD_Y)
    local x = sim.partProperty(p_index, sim.FIELD_X)
    local xvel = sim.partProperty(p_index, sim.FIELD_VX)
    local yvel = sim.partProperty(p_index, sim.FIELD_VY)
    local temp = sim.partProperty(p_index, sim.FIELD_TEMP)
    
    self.yHandler:update(y)
    self.xHandler:update(x)
    self.velHandler:update(math.sqrt(xvel^2 + yvel^2))
    self.tempHandler:update(temp)
    self.p_count = self.p_count + 1
end

function MasterHandler:get()
    local muY, sigY = self.yHandler:get();
    local minx, maxx = self.xHandler:get();

    local muVel, sigVel = self.velHandler:get();

    local muTemp, sigTemp = self.tempHandler:get()
    muTemp = scale(0, 2100, muTemp)


    local props = elements.property(self.p_index, "Properties")
    local liquid = math.min(bitoper(props, elements.TYPE_LIQUID, AND), 1)
    local powder = math.min(bitoper(props, elements.TYPE_PART, AND), 1)
    local gas = math.min(bitoper(props, elements.TYPE_GAS, AND), 1)
    local energy = math.min(bitoper(props, elements.TYPE_ENERGY, AND), 1)

    -- print(string.format("pcount %d liquid %d powder %d gas %d energy %d", self.p_count, liquid, powder, gas, energy))

    return self.p_count, muTemp, muVel, liquid, powder, gas, energy, muY, sigY, minx, maxx
end

function MasterHandler:reset()
    self.yHandler:reset()
    self.xHandler:reset()
    self.velHandler:reset()
    self.tempHandler:reset()
    self.p_count = 0
end


--------------------
-- SETUP
--------------------

local plantHandler = PlantHandler:new()
local lifeHandler = LifeHandler:new()

local topHandlers = {}

local masterElecHandler = MasterElectronicHandler:new({127, 87}, {4278190335, 4294901760, 4294967040, 4294902015, 4278255615})

for i=1,HANDLERCOUNT do
    topHandlers[i] = MasterHandler:new()
end

local function resetHandlers()
    for i=1,HANDLERCOUNT do
        topHandlers[i]:reset()
    end
    lifeHandler:reset()
    plantHandler:reset()
    masterElecHandler:reset()
end



local sorter = ParticleIdCountSorter:new()

local frame = 0

local lastSorted = nil

--------------------
-- MAIN LOOP
--------------------

local function tick()
    -- timing
    --local currTime = os.clock()

    -- Reset all distributions
    resetHandlers()
    sorter:reset()
    local sorted
	
	if HANDLEGRAINS then
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
		
		
		sorted = sorter:getres()
		if (lastSorted ~= nil) then
			sorted = reorder_second_array(lastSorted, sorted)
		end
		
		lastSorted = sorted
	end
	
    -- Loop over all particles
    p_iter = sim.parts()
    local total_parts = 0
    while true do
        local p_index = p_iter()
        if p_index == nil then break end

        -- Only handle this particle if it is moving

        local type = sim.partProperty(p_index, sim.FIELD_TYPE)
		
		
        

        if (type == PLANT_ID or type == VINE_ID) and HANDLEPLANTS then
            plantHandler:update(p_index)
        elseif (elements.property(type, "MenuSection") == elem.SC_LIFE) and HANDLELIFE then
            lifeHandler:update(p_index)
        elseif HANDLEELEC then
            masterElecHandler:update(p_index, type)
        end
		
		
		if HANDLEGRAINS then
			local xvel = sim.partProperty(p_index, sim.FIELD_VX)
			local yvel = sim.partProperty(p_index, sim.FIELD_VY)
			if (xvel ~= 0 and yvel ~=0) then
				
				
				local rank = getKeyForValue(sorted, type)
				if (rank ~= nil) and (rank <= HANDLERCOUNT) then
					topHandlers[rank]:update(p_index)
				end

				total_parts = total_parts + 1
			end
		end
    end
	
	
	--do return end 
    -- Extract params from distributions and send over OSC
	if HANDLEGRAINS then
		for i=1,HANDLERCOUNT do
			local p_count, muTemp, muVel, liquid, powder, gas, energy, muy, sigy, maxx, minx = topHandlers[i]:get()
			if (0 < muVel and muVel < 0.0000000000000000001) then
				--print("Mu vel too tiny!")
				muVel = 0.00000000000000001
			end



			if isnan(muVel) then
				muVel = 0
			end
			-- print (muTemp)
			local message = osc.new_message {
				address = '/tpt/' .. tostring(i),
				types = 'iffffffffff',
				p_count, muTemp, muVel, liquid, powder, gas, energy, muy, sigy, maxx, minx
			}
			
			--print(dump(message:args()))
			osc:send(message)
		end
	end
	
	if HANDLEPLANTS then
		-- Params for plants
		local newPlantBins, oldPlantBins, deletedPlantBins = plantHandler:get()

		local newPlantMessage = osc.new_message {
			address = '/tptplantnew/',
			types = 'iiiiiiiiiiiiiiii',
			unpack(newPlantBins)
		}
		

		local oldPlantMessage = osc.new_message {
			address = '/tptplantold/',
			types = 'iiiiiiiiiiiiiiii',
			unpack(oldPlantBins)
		}

		local deletedPlantMessage = osc.new_message {
			address = '/tptplantdel/',
			types = 'iiiiiiiiiiiiiiii',
			unpack(deletedPlantBins)
		}
		osc:send(oldPlantMessage)
		osc:send(deletedPlantMessage)
		osc:send(newPlantMessage)
	end
	
    -- Params for life
    if HANDLELIFE then
		local lifeMessage = osc.new_message {
			address = '/tptlife/',
			types = 'i',
			lifeHandler:get()
		}
		osc:send(lifeMessage)
	end

	if HANDLEELEC then
		local elecLifetimes, lcdLifetimes, switchLife = masterElecHandler:get()

		for i, v in pairs(elecLifetimes) do
			local electMessage = osc.new_message {
				address = "/tptelec/" .. tostring(i) .. "/",
				types = 'i',
				v
			}
			osc:send(electMessage)
			-- print(i)
		end

		for i, v in pairs(lcdLifetimes) do
			local addr
			if (v > 0) then
				addr = "on"
			else
				addr = "off"
			end
			local val = i % 7

			local lcdMessage = osc.new_message {
				address = "/tptlcd/" .. addr .. "/",
				types = 'i',
				val
			}

			osc:send(lcdMessage)
		end
		
		-- switch message

		local switchMessage = osc.new_message {
			address = "/tptswitch/",
			types = 'f',
			switchLife
		}

		osc:send(switchMessage)
		
	end

    
    showPrimaryName()
	graphics.drawText(100, 100, title_text, 255, 255, 255, alpha)
	if fade then
		alpha = math.max(0, alpha - 1)
	end
	
    frame = frame + 1

    -- timing
    --print(string.format("elapsed time: %.2f\n", os.clock() - currTime))
end

evt.register(evt.tick, tick) 

local mouse_x
local mouse_y
local offx, offy = 6, -9


function showPrimaryName()
    gfx.drawText(mouse_x + offx, mouse_y + offy, "KieranMc", 255, 255, 255, 255)
end

local function moveMouse(x, y, dx, dy)
	mouse_x = x
	mouse_y = y
end


function showText(text)
	title_text = text
	fade = false
	alpha = 255
end

function keyPress(key, scan, rep_, shift_, ctrl, alt)
    if (key == interface.SDLK_KP_0) then
		fade = true
    end

    if (shift_) then
        if (key == interface.SDLK_KP_1) then
            showText("Protons, neutrons and electrons combine to form the first atoms")
        elseif (key == interface.SDLK_KP_2) then
            showText("Elements combine forming molecules")
        elseif (key == interface.SDLK_KP_3) then
            showText("Meanwhile, dust accumulates in low pressure areas")
        elseif (key == interface.SDLK_KP_4) then
            showText("Looks familiar?")
        elseif (key == interface.SDLK_KP_5) then
            showText("part 2 : life")
        elseif (key == interface.SDLK_KP_6) then
            showText("part 3 : plant")
        elseif (key == interface.SDLK_KP_7) then
            showText("part 4 : machine")
        elseif (key == interface.SDLK_KP_8) then
            showText("part 3 : plant")
        elseif (key == interface.SDLK_KP_9) then
            showText("")
        end
    else
        if (key == interface.SDLK_KP_1) then
            showText("part 1 : bang")
        elseif (key == interface.SDLK_KP_2) then
            showText("part 2 : life")
        elseif (key == interface.SDLK_KP_3) then
            showText("part 3 : plant")
        elseif (key == interface.SDLK_KP_4) then
            showText("part 4 : machine")
        end
    end
	
end


evt.register(evt.keypress, keyPress)
evt.register(evt.mousemove, moveMouse)