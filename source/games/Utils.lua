function containsClass(list, type)
    for _, value in pairs(list) do
        if value:isa(type) then
            return true
        end
    end
    return false
end

function getObjectOfClass(list, type)
    for _, value in pairs(list) do
        if value:isa(type) then
            return value
        end
    end
    return nil
end

function bit(p)
    return 2 ^ (p - 1) -- 1-based indexing
end

function hasbit(x, p)
    return x % (p + p) >= p
end

function hasGroup(mask, group)
    return hasbit(mask, bit(group))
end

function getRect(x1, y1, x2, y2)
    local x = math.min(x1, x2)
    local y = math.min(y1, y2)
    local w = math.abs(x1 - x2)
    local h = math.abs(y1 - y2)
    return playdate.geometry.rect.new(x, y, w, h)
end
