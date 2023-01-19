local a = {}

a.sajt = "sajt"
a.baj = "vaj"

a.sajt = nil

for key, value in pairs(a) do
    print("KEY", key, "VAL", value)
end
