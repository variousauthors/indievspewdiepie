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

    t.sides = { 1005366685, 1351747387, 3316243027, 930149632 }
    t.floor_height = 27754

    t.side_length   = ""
    t.floor_height  = "" .. t.floor_height

    for i, v in ipairs(t.sides) do
        t.side_length = t.side_length .. DEC_HEX(v)
    end

    _G.conf = t -- Makes configuration options accessible later
end
