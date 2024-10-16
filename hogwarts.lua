if SERVER then
    resource.AddFile("materials/hud/hud3.png")
end

local PLUGIN = PLUGIN

PLUGIN.name = "Simple HUD"
PLUGIN.description = "A simple HUD for Helix."
PLUGIN.author = "Juanzorro1997"
PLUGIN.schema = "Any"

ix.lang.AddTable("english", {
    optHealthColor = "Health Color",
    optArmorColor = "Shield Color",
    optStaminaColor = "Stamina Color",
    optHungerColor = "Hunger Color",
    optThirstColor = "Thirst Color",
})

ix.lang.AddTable("spanish", {
    optHealthColor = "Color de la Vida",
    optArmorColor = "Color del Escudo",
    optStaminaColor = "Color de la Estamina",
    optHungerColor = "Color de Hambre",
    optThirstColor = "Color de Sed",
})

ix.option.Add("healthColor", ix.type.color, Color(255, 75, 66), {
    category = "Hogwarts HUD",
    description = "Color de la barra de vida."
})

ix.option.Add("armorColor", ix.type.color, Color(255, 132, 187), {
    category = "Hogwarts HUD",
    description = "Color de la barra de armadura."
})

ix.option.Add("staminaColor", ix.type.color, Color(67, 223, 67), {
    category = "Hogwarts HUD",
    description = "Color de la barra de estamina."
})

ix.option.Add("hungerColor", ix.type.color, Color(255, 225, 0), {
    category = "Hogwarts HUD",
    description = "Color de la barra de hambre."
})

ix.option.Add("thirstColor", ix.type.color, Color(0, 0, 255), {
    category = "Hogwarts HUD",
    description = "Color de la barra de sed."
})

if CLIENT then
    local barW = 100
    local barH = 20
    local headPanelWidth = 70
    local headPanelHeight = 90
    local hudOffsetX = 150

    local hudMaterial = Material("hud/hud3.png")

    local function DrawBar(x, y, w, h, color, percentage, label)
        local r, g, b, a = color.r, color.g, color.b, color.a or 255
        surface.SetDrawColor(r, g, b, a)
        surface.DrawRect(x, y, w * percentage, h)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawOutlinedRect(x, y, w, h)


        draw.SimpleText(label, "Trebuchet24", x + w / 2, y + h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local elegant_model = nil

    hook.Add('InitPostEntity', 'player_give_head', function()
        if not IsValid(elegant_model) then
            elegant_model = vgui.Create("DModelPanel")
            elegant_model:SetModel(LocalPlayer():GetModel())
            elegant_model:SetSize(headPanelWidth, headPanelHeight)
            elegant_model:SetPos(15, ScrH() - 300)
            elegant_model:SetCamPos(Vector(0, 0, 0))
            elegant_model:SetLookAt(Vector(0, 0, 0))
            elegant_model:SetAnimated(true)
            function elegant_model:LayoutEntity(Entity) return end
        end
    end)


    hook.Add("PlayerSpawn", "UpdateModelOnSpawn", function(ply)
        if IsValid(elegant_model) and ply == LocalPlayer() then
            elegant_model:SetModel(LocalPlayer():GetModel())
        end
    end)


    hook.Add("OnCharacterLoaded", "UpdateModelOnCharacterLoad", function(ply)
        if IsValid(elegant_model) and ply == LocalPlayer() then
            elegant_model:SetModel(ply:GetModel())
        end
    end)

    hook.Add("OnReloaded", "UpdateModelOnReload", function()
        if IsValid(elegant_model) then
            elegant_model:SetModel(LocalPlayer():GetModel())
        end
    end)

    hook.Add("Think", "UpdateElegantModel", function()
        if IsValid(elegant_model) and LocalPlayer():Alive() then
            elegant_model:SetModel(LocalPlayer():GetModel())
            local boneIndex = elegant_model.Entity:LookupBone("ValveBiped.Bip01_Head1")
            if boneIndex then
                elegant_model:SetSize(200, 200)
                elegant_model:SetPos(45, ScrH() - 300)
                elegant_model:SetCamPos(Vector(50, -10, 65))
                elegant_model:SetLookAt(Vector(0, 0, 65))
                elegant_model:SetAnimated(true)
            end
        end
    end)

    hook.Add("HUDPaint", "Simple_HUD", function()
        if ix.option.Get("ocultarHUD", false) then return end

        local ply = LocalPlayer()
        if not ply:Alive() then return end

        local healthColor = ix.option.Get("healthColor", Color(255, 75, 66))
        local armorColor = ix.option.Get("armorColor", Color(255, 132, 187))
        local staminaColor = ix.option.Get("staminaColor", Color(67, 223, 67))
        local hungerColor = ix.option.Get("hungerColor", Color(255, 225, 0))
        local thirstColor = ix.option.Get("thirstColor", Color(0, 0, 255))

        local hp = ply:Health() / ply:GetMaxHealth()
        local armor = ply:Armor() / 100
        local stamina = ply:GetLocalVar("stm", 0) / 100
        local hunger = ply:GetLocalVar("hunger", 0) / 100
        local thirst = ply:GetLocalVar("thirst", 0) / 100

        local hudOffsetX = 250
        local x, y = 15 + hudOffsetX, ScrH() - barH * 6 - 150

        if IsValid(elegant_model) then
            elegant_model:SetPos(x - hudOffsetX, y - 110)
            elegant_model:PaintManual()
        end


        local imageWidth = headPanelWidth * 8
        local imageHeight = headPanelHeight * 7
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(hudMaterial)
        surface.DrawTexturedRect(-110, ScrH() - 580, imageWidth, imageHeight) 

        local barX = x
        local barY = y

        DrawBar(barX, barY, barW, barH, healthColor, hp, "HP")
        DrawBar(barX, barY + barH + 5, barW, barH, armorColor, armor, "Armor")
        DrawBar(barX, barY + 2 * (barH + 5), barW, barH, staminaColor, stamina, "Stamina")
        DrawBar(barX, barY + 3 * (barH + 5), barW, barH, hungerColor, hunger, "Hunger")
        DrawBar(barX, barY + 4 * (barH + 5), barW, barH, thirstColor, thirst, "Thirst")
    end)
end

function PLUGIN:ShouldHideBars()
    return true
end
