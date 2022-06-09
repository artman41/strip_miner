string = (function() 
    local string = string or {}

    local function split(s, pat)
        local start, finish = string.find(s, pat);
        if start ~= nil then
            return {
                [1] = string.sub(s, 1, start-1),
                [2] = string.sub(s, finish+1, string.len(s)),
            }
        else
            return {
                [1] = s,
                [2] = "",
            }
        end
    end

    function string.split(s, pat, count)
        count = count or 1
        if s == nil then
            return nil
        end
        local acc = {};
        local tmp = s;
        if count < 0 then
            while tmp ~= "" do
                local split = split(tmp, pat);
                table.insert(acc, split[1]);
                tmp = split[2];
            end
        else
            for _=1,count do
                local split = split(tmp, pat);
                table.insert(acc, split[1]);
                tmp = split[2];
            end
            if tmp ~= "" then
                table.insert(acc, tmp);
            end
        end
        return acc;
    end

    return string;
end)()