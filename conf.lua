function DEC_HEX(IN)
    local B,K,OUT,I,D=16,"0123456789abcdef","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return OUT
end

function love.conf(t)
    t.window.title = "Gunship Souls"

    t.sides = { 604046728, 2724984046, 3362718332, 3042791539 }
    t.floor_height = 38623

    t.side_length   = ""
    t.floor_height  = "" .. t.floor_height

    for i, v in ipairs(t.sides) do
        t.side_length = t.side_length .. DEC_HEX(v)
    end

    _G.conf = t -- Makes configuration options accessible later
end
