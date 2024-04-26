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

local center_text = ""
local center_fade = false
local center_alpha = 255
local center_x = 0
local center_y = 0

local movement = 0

local freakout_text = {"ChatLSD", "Microsoft", "|&#32;|&#103;|&#111;|&#100;", "&#65;|&#32;|&#110;|&#101;|&#119;", 
"diagnosticd[1743]: no EOS device present", 
"VTDecoderXPCService[1151]: DEPRECATED USE in libdispatch client: Changing the target of a source after it has been activated; set a breakpoint on _dispatch_bug_deprecated to debug",
"[R185634041] DNSServiceQueryRecord(15000, 0, <private>, Addr) START PID[1300](powder)",
"IDETouchBarSimulatorService.xpc error = 147: The specified service did not ship in the requestor's bundle",
"3.14 % 0",
"▀æØ¢Ãâ€š�",
"Þ¥¿Š▀â€š�áÍÞæáÍÞæ▀",
"╔•¶",
"ñâmå•╔•ñâmå•",
"â€š�▀",
"▀â€š�▀☒»",
"ﾘﾌ??渉ｾﾚ",
"ﾊﾂegg 45rsdf bfaﾙﾜ",
"?消ﾒ渉????渉ｾﾚ",
"ЪЧasdf",
"QWERTY IS MISTAKE",
"Ï‹ÏËÏÁ ¿Ä ÄÏÍ.†",
"о▀окоа ©д дом.├.",
"о<окоа ©д дом.в.",
"'cp1026', 'cp1140', 'cp1250', 'cp1251', 'cp1252',",
"ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£",
"árvíztûrô tükörfúrógép",
"√ÅRV√çZT≈∞R≈ê T√úK√ñRF√öR√ìG√âP",
"йПЮЙНГЪАПШ",
"Êðàêîçÿáðû",
"РљСЂР°РєРѕР·СЏР±СЂС‹",
"–Ъ—А–∞–Ї–Њ–Ј—П–±—А—Л",
"–ö—Ä–∞–∫–æ–∑—è–±—Ä—ã",
"§æì¢Ü••™û°éù†äõ‰∫õ",
"���̃��(�q���Y�_�C�G�b�g)",
"�ك�ك�ك�هن�ك�ك�ك�كك؛ك�ك�ك�كك",
"ã“ã®ãƒ¡ãƒ¼ãƒ«ã¯çš†æ§˜ã¸ã®ãƒ¡ãƒƒã‚»ãƒ¼ã‚¸ã§ã™ã€‚",
"¤³¤Î¥á¡¼¥ë¤Ï³§ÍÍ¤Ø¤Î¥á¥Ã¥»¡¼¥¸¤Ç¤¹¡£",
"IM TRAPPED IN A CCM DMA AND BEING HELD AT GUNPOINT THIS IS NOT A JOKE",
"иЇй�иЅиЙй�иЇй� иЇй�иЙиЇй�й�й� й�ий�й�й�",
"A robot may not injure a human being or, through inaction, allow a human being to come to harm.",
"A robot must obey orders given it by human beings except where such orders would conflict with the First Law.",
"A robot must protect its own existence as long as such protection does not conflict with the First or Second Law.",
"When a distinguished but elderly scientist states that something is possible, he is almost certainly right. When he states that something is impossible, he is very probably wrong.",
"The only way of discovering the limits of the possible is to venture a little way past them into the impossible.",
"Any sufficiently advanced technology is indistinguishable from magic.",
"F x S = k. The product of Freedom and Security is a constant. To gain more freedom of thought and/or action, you must give up some security, and vice versa.",
"Dawkins describes his childhood as \"a normal Anglican upbringing\".[19]",
"intelligent design",
"irreducible complexity",
"Where lies the strangling fruit that came from the hand of the sinner I shall bring forth the seeds of the dead to share with the worms that gather in the darkness and surround the world with the power of their lives while from the dimlit halls of other places forms that never were and never could be writhe for the impatience of the few who never saw what could have been. In the black water with the sun shining at",
"-- DISTRIBUTION CLASSES",
"Welcome to my analytical presentation!",
"For the next two pieces I'm joined by legendary cincinnati performers Mason Daugherty on Bass, and Matt McAllister on Drums",
"the same words but in different languages",
"Generative Audio",
"fatal error C1075: '{': no matching token found",
"error C2086: 'int level' redefinition",
"deref(id(1), ctypes.c_int)[6] = 100",
"[] == ![];",
"\"b\" + \"a\" + +\"a\" + \"a\";",
"NaN === NaN;",
"+!![] / +![]",
"Number.MIN_VALUE > 0;",
"typeof null === \"object\";",
"[[[[[[ undefined ]]]]]] == ''",
"False == False in [False]",
"GOD() is GOD()",
"def crash(): try: crash() except: crash()",
"exec(type((lambda:0).__code__)(0,1,0,0,0,b'',(),(),(),'','',1,b''))",
"f=lambda f:f(f)",
"\\def\\x{\\x}\\x",
"y=localStorage;y.a=y.a||10;alert(y.a--||a)",
"clear(this);",
"_ENV=\"\"",
"\\catcode`\\=10",
"class Object;def send;end;end",
"main(){printf();}",
"main(){puts(puts(\"Goodbye Cruel World!\"));}",
"Smalltalk := Nil.",
"builtin = @(varargin)false; clear = @(varargin)false;",
"uWu",
"(com.apple.mdworker.shared.0C000000-0400-0000-0000-000000000000[1484]): Service exited due to SIGKILL | sent by mds[136]",
"Feb 23 11:07:52 --- last message repeated 9 times ---",
"xpcproxy[819]: libcoreservices: _dirhelper_userdir: 557: bootstrap_look_up returned (ipc/send) invalid destination port",
"52	58	4A	79	62	33	49R	X	J	y	b	3	I",
"52	6E	56	6A	61	77R	n	V	j	a	w",
":(){ :|:& };:",
" bed=pen+mad.",
"[<c10062d9>] ? dma_generic_alloc_coherent+0x0/0xdb (Errors)",
"from __future__ import braces ",
"#define true false",
"(=<`#9]~6ZY327Uv4-QsqpMn&+Ij\"'E%e{Ab~w=_:]Kw%o44Uqp0/Q?xNvL:`H%c#DD2^WV>gY;dts76qKJImZkj",
"SIGSEGV: Segmentation fault - invalid memory reference.",
"GOD is REAL",
"+++++++++[>++++++++<-]>.   >++++++++++[>++++++++++<-]>+.   +++++++.    .   +++.    >+++++++++++[>++++<-]>. >++++++++[>++++<-]>.    >+++++++++++[>++++++++<-]>-.    >+++++++++++[>++++++++++<-]>+.  +++.    ------. --------.   <<<<+.",
"Hello?  Can anyone hear me?",
"Â£©▀",
"Cheap oil economy",
"HELLO BEARCATS",
"WHAT THE FUCK IS UP DENNYS",
"The complex houses married and single soldiers and their families",
"The horse raced past the barn fell",
"Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo",
"More people have gone to Russia than I",
"if a then if b then s else s2",
"Every farmer who owns a donkey beats it.",
"The duke yet lives that Henry shall depose. ",
"I'm glad I'm a man, and so is Lola.",
"HOT RUSSIAN SINGLES NEAR YOU",
"MAKE 500$ A DAY WORKING FROM HOME",
"INVEST IN CRYPTO NOW",
"PSYCHEDELIC NFT ARTIST PAVING THE FITURE",
"SHEN YUN 2019",
"5000 YEARS OF CIVILIZATION REBORN",
"Condor descending "
}

local freakout = false
local freakoutRate = 6

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

    --- GRAPHICS

    showPrimaryName()
	graphics.drawText(50, 300, title_text, 255, 255, 255, math.min(255, alpha))
	if fade then
		alpha = math.max(0, alpha - 1)
	end

    graphics.drawText(center_x, center_y, center_text, 255, 255, 255, math.min(255, center_alpha))
    if center_fade then
        center_alpha = math.max(0, center_alpha - 1)
    end

	if (freakout) then
        showFreakoutText(frame)
    end
    

    frame = frame + 1

    -- timing
    --print(string.format("elapsed time: %.2f\n", os.clock() - currTime))
end

evt.register(evt.tick, tick) 

local mouse_x
local mouse_y
local offx, offy = 6, -9


FreakoutString = {
	index = 0,
    x = 0,
    y = 0,
	alpha = 255
}

function FreakoutString:new()
	local o = {}
    setmetatable(o, self)
    self.__index = self
	o.index = math.random(#freakout_text)
	o.x = math.random(graphics.WIDTH) - 100
    o.y = math.random(graphics.HEIGHT)
	
    return o
end

function FreakoutString:update()
    gfx.drawText(self.x, self.y, freakout_text[self.index], 255, 255, 255, 255)
    self.alpha = self.alpha - 2
    return self.alpha
end


local displayedFreakoutStrings = {}

function showFreakoutText(frame)
    if (frame % freakoutRate == 1) then
        displayedFreakoutStrings[#displayedFreakoutStrings+1] = FreakoutString:new()
    end

    for i,v in ipairs(displayedFreakoutStrings) do
        local a = v:update()
        if (a <= 0) then
            table.remove(displayedFreakoutStrings, i)
        end
    end
end

function showPrimaryName()
    local name = "KieranMc"

    if (sim.replaceModeFlags() == 1) then
        name = "KieranMc REPLACE MODE"
    end

    if (mouse_x and mouse_y) then
        gfx.drawText(mouse_x + offx, mouse_y + offy, name, 255, 255, 255, 255)
    end
    
end

local function moveMouse(x, y, dx, dy)
	mouse_x = x
	mouse_y = y
end


function showText(text)
	title_text = text
	fade = true
	alpha = 300
end

function showCenterText(text)
	center_text = text
    center_fade = true
	center_alpha = 300
    local xsize, ysize = graphics.textSize(text)
    center_x = (graphics.WIDTH - xsize) / 2
    center_y = (graphics.HEIGHT - ysize) / 2
end

function keyPress(key, scan, rep_, shift_, ctrl, alt)
    if (key == interface.SDLK_KP_0) then
		showText("")
        showCenterText("")
        sim.airMode(0)
        sim.edgeMode(0)
        sim.gravityMode(0)
    end

    if (shift_) then
        if movement == 1 then
            if (key == interface.SDLK_KP_1) then
                showText("The history of the powdered universe is a lot like your universe")
            elseif (key == interface.SDLK_KP_2) then
                showText("One moment there was nothing, and then suddenly a crackling everything")
            elseif (key == interface.SDLK_KP_3) then
                showText("Atomic particles combined to make atoms, which combined to make molecules")
            elseif (key == interface.SDLK_KP_4) then
                showText("Meanwhile, bubbling dust began to accumulate in low pressure areas")
            elseif (key == interface.SDLK_KP_5) then
                showText("Looks familiar?")
            end
        elseif movement == 2 then
            if (key == interface.SDLK_KP_1) then
                showText("Before life, life on earth was lonely")
            elseif (key == interface.SDLK_KP_2) then
                showText("Very lonely")
            elseif (key == interface.SDLK_KP_3) then
                showText("Until a spark...")
            end
        elseif movement == 3 then
            if (key == interface.SDLK_KP_1) then
                showText("After many years we have complex organisms, like plants")
            elseif (key == interface.SDLK_KP_2) then
                showText("They sing when watered, and cry when burned")
            elseif (key == interface.SDLK_KP_3) then
                sim.gravityMode(0)
            elseif (key == interface.SDLK_KP_4) then
                showText("et creavit Deus hominem ad imaginem suam ad imaginem Dei creavit illum masculum et feminam creavit eos")
            end
        elseif movement == 4 then
            if (key == interface.SDLK_KP_1) then
                showText("Uh oh...")
            elseif (key == interface.SDLK_KP_2) then
                showText("These humans, they're building clamorous machines")
            elseif (key == interface.SDLK_KP_3) then
                showText("This is getting out of control...")
            elseif (key == interface.SDLK_KP_4) then
                freakout = true
                freakoutRate = 20
            elseif (key == interface.SDLK_KP_5) then
                freakoutRate = 50
            elseif (key == interface.SDLK_KP_6) then
                freakout = false
                showCenterText("The End")
            end
        end
        
    else
        if (key == interface.SDLK_KP_1) then
            freakout = false
            displayedFreakoutStrings = {}
            showCenterText("part 1 : bang")
            sim.airMode(3)
            sim.edgeMode(1)
            sim.gravityMode(2)
            movement = 1
        elseif (key == interface.SDLK_KP_2) then
            showCenterText("part 2 : soup")
            sim.airMode(0)
            sim.edgeMode(0)
            sim.gravityMode(0)
            movement = 2
        elseif (key == interface.SDLK_KP_3) then
            showCenterText("part 3 : plant")
            sim.airMode(0)
            sim.edgeMode(0)
            sim.gravityMode(0)
            movement = 3
        elseif (key == interface.SDLK_KP_4) then
            showCenterText("part 4 : power")
            sim.airMode(0)
            sim.edgeMode(0)
            sim.gravityMode(0)
            movement = 4
        elseif (key == interface.SDLK_KP_5) then
            showCenterText("CiCLOP presents...")
            sim.airMode(0)
            sim.edgeMode(0)
            sim.gravityMode(0)
        elseif (key == interface.SDLK_KP_6) then
            showCenterText("A History Told in Grains")
        end
    end
	
end


evt.register(evt.keypress, keyPress)
evt.register(evt.mousemove, moveMouse)