

local function tick_hello()
    local p_iter = sim.parts()
    local total_parts = 0
    while true do
        local p_index = p_iter()
        if p_index == nil then break end

        total_parts = total_parts + 1
    end

    print(total_parts)
    -- Send it over UDP
    print(_VERSION)
end

evt.register(evt.tick, tick_hello)