local function round(num)
    local rem = math.abs(num) % 1
    local op = math.floor
    if num > 0 and rem >= 0.5 then op = math.ceil end
    if num < 0 and rem < 0.5 then op = math.ceil end
    return op(num)
end

local function test(num)
    print("Num", num, "Remains", math.abs(num) % 1, "Floor", math.floor(num), "Ceil", math.ceil(num))
end

print("Rounded", round(0.1))
print("Rounded", round(0.49999))
print("Rounded", round(0.5))
print("Rounded", round(1.51))
print("Ro  unded", round(-0.49))
print("Rounded", round(-0.5))
print("Rounded", round(-0.6))
print("Rounded", round(0))
print("Rounded", round(-122.123))
print("Rounded", round(122.51))

-- test(0)
-- test(0.1)
-- test(0.51)
-- test(-0.1)
-- test(0.5)
-- test(-0.5)
-- test(0.4999)
-- test(-0.4999)
-- test(1.001)
-- test(-1.0001)
-- test(1.4999)
-- test(-1.4999)
-- test(1.5)
-- test(-1.5)
-- test(1.5001)
-- test(-1.5001)
