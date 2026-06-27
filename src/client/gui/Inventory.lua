-- Inventory GUI System - FIXED VERSION

local Inventory = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local inventoryWindow = nil
local currentCategory = "Matériaux"
local selectedItem = nil
local itemsDisplay = {}
local isOpen = false

-- Rarity Colors
local RARITY_COLORS = {
    ["Commun"] = Color3.fromRGB(200, 200, 200),
    ["Rare"] = Color3.fromRGB(100, 150, 255),
    ["Épique"] = Color3.fromRGB(200, 100, 255),
    ["Légendaire"] = Color3.fromRGB(255, 200, 0)
}

local RARITY_BORDERS = {
    ["Commun"] = Color3.fromRGB(150, 150, 150),
    ["Rare"] = Color3.fromRGB(70, 120, 255),
    ["Épique"] = Color3.fromRGB(180, 70, 255),
    ["Légendaire"] = Color3.fromRGB(255, 200, 0)
}

-- Initialize Inventory GUI
function Inventory.init()
    if inventoryWindow then return end
    
    print("[Inventory] Initialisation...")
    Inventory.createInventoryWindow()
    Inventory.setupCategoryButtons()
    Inventory.loadItems("Matériaux")
    print("[Inventory] Prêt!")
end

-- Create main inventory window
function Inventory.createInventoryWindow()
    inventoryWindow = Instance.new("ScreenGui")
    inventoryWindow.Name = "InventoryGui"
    inventoryWindow.ResetOnSpawn = false
    inventoryWindow.Enabled = false
    inventoryWindow.Parent = playerGui
    
    -- Create dark background overlay
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.BorderSizePixel = 0
    background.Parent = inventoryWindow
    
    -- Main inventory container
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0.9, 0, 0.85, 0)
    mainContainer.Position = UDim2.new(0.05, 0, 0.075, 0)
    mainContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    mainContainer.BorderSizePixel = 2
    mainContainer.BorderColor3 = Color3.fromRGB(80, 120, 160)
    mainContainer.Parent = inventoryWindow
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    title.BorderSizePixel = 1
    title.BorderColor3 = Color3.fromRGB(80, 120, 160)
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 32
    title.Font = Enum.Font.GothamBold
    title.Text = "📦 INVENTAIRE"
    title.Parent = mainContainer
    
    -- Close X button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 50, 0, 50)
    closeBtn.Position = UDim2.new(1, -55, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "✕"
    closeBtn.Parent = title
    
    closeBtn.MouseButton1Click:Connect(function()
        Inventory.close()
    end)
    
    -- Left panel (items list)
    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.Size = UDim2.new(0.65, -5, 1, -70)
    leftPanel.Position = UDim2.new(0, 10, 0, 65)
    leftPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    leftPanel.BorderSizePixel = 1
    leftPanel.BorderColor3 = Color3.fromRGB(60, 100, 140)
    leftPanel.Parent = mainContainer
    
    -- Category buttons container
    local categoryContainer = Instance.new("Frame")
    categoryContainer.Name = "CategoryContainer"
    categoryContainer.Size = UDim2.new(0, 150, 1, 0)
    categoryContainer.Position = UDim2.new(0, 0, 0, 0)
    categoryContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    categoryContainer.BorderSizePixel = 1
    categoryContainer.BorderColor3 = Color3.fromRGB(50, 80, 120)
    categoryContainer.Parent = leftPanel
    
    -- Items scroll area
    local itemsScroll = Instance.new("ScrollingFrame")
    itemsScroll.Name = "ItemsScroll"
    itemsScroll.Size = UDim2.new(1, -160, 1, 0)
    itemsScroll.Position = UDim2.new(0, 150, 0, 0)
    itemsScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    itemsScroll.BorderSizePixel = 0
    itemsScroll.ScrollBarThickness = 8
    itemsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    itemsScroll.Parent = leftPanel
    
    -- UIGridLayout for items
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 100, 0, 120)
    gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    gridLayout.Parent = itemsScroll
    
    -- Right panel (item details)
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(0.30, -10, 1, -70)
    rightPanel.Position = UDim2.new(0.65, 10, 0, 65)
    rightPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    rightPanel.BorderSizePixel = 1
    rightPanel.BorderColor3 = Color3.fromRGB(60, 100, 140)
    rightPanel.Parent = mainContainer
    
    -- Item preview image placeholder
    local itemImage = Instance.new("Frame")
    itemImage.Name = "ItemImage"
    itemImage.Size = UDim2.new(0.8, 0, 0.35, 0)
    itemImage.Position = UDim2.new(0.1, 0, 0.05, 0)
    itemImage.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    itemImage.BorderSizePixel = 2
    itemImage.BorderColor3 = Color3.fromRGB(100, 150, 200)
    itemImage.Parent = rightPanel
    
    -- Item name
    local itemName = Instance.new("TextLabel")
    itemName.Name = "ItemName"
    itemName.Size = UDim2.new(1, -20, 0, 30)
    itemName.Position = UDim2.new(0, 10, 0.4, 0)
    itemName.BackgroundTransparency = 1
    itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
    itemName.TextSize = 16
    itemName.Font = Enum.Font.GothamBold
    itemName.Text = "Sélectionnez un objet"
    itemName.TextWrapped = true
    itemName.Parent = rightPanel
    
    -- Item rarity
    local itemRarity = Instance.new("TextLabel")
    itemRarity.Name = "ItemRarity"
    itemRarity.Size = UDim2.new(1, -20, 0, 25)
    itemRarity.Position = UDim2.new(0, 10, 0.48, 0)
    itemRarity.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    itemRarity.BorderSizePixel = 1
    itemRarity.BorderColor3 = Color3.fromRGB(80, 80, 85)
    itemRarity.TextColor3 = Color3.fromRGB(200, 200, 200)
    itemRarity.TextSize = 12
    itemRarity.Font = Enum.Font.Gotham
    itemRarity.Text = "Rareté: --"
    itemRarity.Parent = rightPanel
    
    -- Item quantity
    local itemQuantity = Instance.new("TextLabel")
    itemQuantity.Name = "ItemQuantity"
    itemQuantity.Size = UDim2.new(1, -20, 0, 25)
    itemQuantity.Position = UDim2.new(0, 10, 0.56, 0)
    itemQuantity.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    itemQuantity.BorderSizePixel = 1
    itemQuantity.BorderColor3 = Color3.fromRGB(80, 80, 85)
    itemQuantity.TextColor3 = Color3.fromRGB(200, 200, 200)
    itemQuantity.TextSize = 12
    itemQuantity.Font = Enum.Font.Gotham
    itemQuantity.Text = "Quantité: 0"
    itemQuantity.Parent = rightPanel
    
    -- Item description
    local itemDesc = Instance.new("TextLabel")
    itemDesc.Name = "ItemDescription"
    itemDesc.Size = UDim2.new(1, -20, 0.2, 0)
    itemDesc.Position = UDim2.new(0, 10, 0.65, 0)
    itemDesc.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    itemDesc.BorderSizePixel = 1
    itemDesc.BorderColor3 = Color3.fromRGB(60, 80, 110)
    itemDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
    itemDesc.TextSize = 11
    itemDesc.Font = Enum.Font.Gotham
    itemDesc.Text = "Description non disponible"
    itemDesc.TextWrapped = true
    itemDesc.TextXAlignment = Enum.TextXAlignment.Left
    itemDesc.TextYAlignment = Enum.TextYAlignment.Top
    itemDesc.Parent = rightPanel
    
    -- Value info
    local itemValue = Instance.new("TextLabel")
    itemValue.Name = "ItemValue"
    itemValue.Size = UDim2.new(1, -20, 0, 25)
    itemValue.Position = UDim2.new(0, 10, 0.88, 0)
    itemValue.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    itemValue.BorderSizePixel = 1
    itemValue.BorderColor3 = Color3.fromRGB(80, 80, 85)
    itemValue.TextColor3 = Color3.fromRGB(255, 200, 0)
    itemValue.TextSize = 12
    itemValue.Font = Enum.Font.GothamBold
    itemValue.Text = "💰 Valeur: 0"
    itemValue.Parent = rightPanel
    
    mainContainer.LeftPanel = leftPanel
    mainContainer.CategoryContainer = categoryContainer
    mainContainer.ItemsScroll = itemsScroll
    mainContainer.RightPanel = rightPanel
end

-- Setup category buttons
function Inventory.setupCategoryButtons()
    local mainContainer = inventoryWindow:FindFirstChild("MainContainer")
    local categoryContainer = mainContainer.CategoryContainer
    
    local categories = {"Matériaux", "Animaux", "Armes"}
    local categoryButtons = {}
    
    for i, category in ipairs(categories) do
        local btn = Instance.new("TextButton")
        btn.Name = category
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.Position = UDim2.new(0, 0, 0, (i-1) * 50)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(70, 90, 130)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Text = category
        btn.Parent = categoryContainer
        
        btn.MouseButton1Click:Connect(function()
            Inventory.switchCategory(category, categoryButtons)
        end)
        
        table.insert(categoryButtons, btn)
    end
    
    -- Highlight first category
    categoryButtons[1].BackgroundColor3 = Color3.fromRGB(80, 120, 160)
    categoryButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
    
    categoryContainer.CategoryButtons = categoryButtons
end

-- Switch category
function Inventory.switchCategory(category, categoryButtons)
    if currentCategory == category then return end
    
    currentCategory = category
    
    for _, btn in ipairs(categoryButtons) do
        if btn.Name == category then
            btn.BackgroundColor3 = Color3.fromRGB(80, 120, 160)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    Inventory.loadItems(category)
end

-- Load items for a category
function Inventory.loadItems(category)
    local mainContainer = inventoryWindow:FindFirstChild("MainContainer")
    local itemsScroll = mainContainer.ItemsScroll
    local rightPanel = mainContainer.RightPanel
    
    -- Clear previous items
    for _, child in ipairs(itemsScroll:GetChildren()) do
        if child:IsA("GuiObject") and child.ClassName ~= "UIGridLayout" then
            child:Destroy()
        end
    end
    
    itemsDisplay = {}
    selectedItem = nil
    
    -- Reset right panel
    rightPanel.ItemImage.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    rightPanel.ItemName.Text = "Sélectionnez un objet"
    rightPanel.ItemRarity.Text = "Rareté: --"
    rightPanel.ItemQuantity.Text = "Quantité: 0"
    rightPanel.ItemDescription.Text = "Description non disponible"
    rightPanel.ItemValue.Text = "💰 Valeur: 0"
    
    -- Mock inventory data
    local mockInventory = {
        ["Matériaux"] = {
            {name = "Bois primitif", rarity = "Commun", quantity = 145, value = 10, epoch = 1, desc = "Bois collecté dans les forêts primitives. Ressource de base."},
            {name = "Pierre", rarity = "Commun", quantity = 89, value = 10, epoch = 1, desc = "Pierre brute trouvée partout. Très commune."},
            {name = "Silex", rarity = "Rare", quantity = 34, value = 50, epoch = 1, desc = "Pierre dure et tranchante. Idéale pour les outils."},
            {name = "Os", rarity = "Rare", quantity = 12, value = 75, epoch = 1, desc = "Os d'animaux préhistoriques. Utile pour les armes."},
            {name = "Ambre préhistorique", rarity = "Épique", quantity = 5, value = 200, epoch = 1, desc = "Ambre ancien contenant des fossiles. Très précieux."},
            {name = "Cristal volcanique", rarity = "Légendaire", quantity = 1, value = 500, epoch = 1, desc = "Cristal formé par la lave. Extrêmement rare et puissant."},
        },
        ["Animaux"] = {
            {name = "Dodo", rarity = "Commun", quantity = 1, value = 0, epoch = 1, desc = "Petit compagnon de base. Bonus: x1.1 récolte"},
            {name = "Loup préhistorique", rarity = "Rare", quantity = 1, value = 0, epoch = 1, desc = "Compagnon rare. Bonus: x1.25 récolte"},
            {name = "Mammouth Alpha", rarity = "Légendaire", quantity = 1, value = 0, epoch = 1, desc = "Boss pet légendaire! Bonus: x3.0 récolte"},
        },
        ["Armes"] = {
            {name = "Hache en pierre", rarity = "Commun", quantity = 1, value = 0, epoch = 1, desc = "Hache basique. Multiplicateur: x1"},
            {name = "Hache en silex", rarity = "Rare", quantity = 1, value = 0, epoch = 1, desc = "Hache tranchante. Multiplicateur: x2"},
            {name = "Hache en os", rarity = "Rare", quantity = 1, value = 0, epoch = 1, desc = "Hache solide. Multiplicateur: x5"},
            {name = "Hache en cristal", rarity = "Épique", quantity = 0, value = 0, epoch = 1, desc = "Hache épique avec cristal. Multiplicateur: x10"},
        }
    }
    
    local items = mockInventory[category] or {}
    
    for _, item in ipairs(items) do
        local itemButton = Inventory.createItemButton(item)
        itemButton.Parent = itemsScroll
        table.insert(itemsDisplay, {button = itemButton, data = item})
    end
    
    -- Update canvas size
    local gridLayout = itemsScroll:FindFirstChildOfClass("UIGridLayout")
    if gridLayout then
        itemsScroll.CanvasSize = UDim2.new(0, itemsScroll.AbsoluteSize.X - 16, 0, gridLayout.AbsoluteContentSize.Y + 20)
    end
end

-- Create item button
function Inventory.createItemButton(item)
    local button = Instance.new("TextButton")
    button.Name = item.name
    button.Size = UDim2.new(0, 100, 0, 120)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    button.BorderSizePixel = 2
    button.BorderColor3 = RARITY_BORDERS[item.rarity] or Color3.fromRGB(100, 100, 100)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 10
    button.Font = Enum.Font.Gotham
    button.Text = ""
    
    -- Item icon
    local itemIcon = Instance.new("TextLabel")
    itemIcon.Name = "ItemIcon"
    itemIcon.Size = UDim2.new(1, 0, 0, 70)
    itemIcon.BackgroundColor3 = RARITY_COLORS[item.rarity]
    itemIcon.BorderSizePixel = 0
    itemIcon.TextColor3 = Color3.fromRGB(0, 0, 0)
    itemIcon.TextSize = 30
    itemIcon.Font = Enum.Font.GothamBold
    itemIcon.Text = "📦"
    itemIcon.Parent = button
    
    -- Item name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -5, 0, 25)
    nameLabel.Position = UDim2.new(0, 2.5, 0, 70)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 9
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = item.name
    nameLabel.TextWrapped = true
    nameLabel.Parent = button
    
    -- Item quantity
    local quantityLabel = Instance.new("TextLabel")
    quantityLabel.Name = "QuantityLabel"
    quantityLabel.Size = UDim2.new(1, 0, 0, 15)
    quantityLabel.Position = UDim2.new(0, 0, 1, -20)
    quantityLabel.BackgroundColor3 = RARITY_COLORS[item.rarity]
    quantityLabel.BorderSizePixel = 0
    quantityLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    quantityLabel.TextSize = 10
    quantityLabel.Font = Enum.Font.GothamBold
    quantityLabel.Text = "x" .. item.quantity
    quantityLabel.Parent = button
    
    -- Click handler
    button.MouseButton1Click:Connect(function()
        Inventory.selectItem(item, button)
    end)
    
    return button
end

-- Select item and show details
function Inventory.selectItem(item, button)
    selectedItem = item
    
    -- Reset previous selection
    for _, itemDisplay in ipairs(itemsDisplay) do
        itemDisplay.button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    end
    
    -- Highlight selected
    button.BackgroundColor3 = Color3.fromRGB(80, 120, 160)
    
    -- Update right panel
    local mainContainer = inventoryWindow:FindFirstChild("MainContainer")
    local rightPanel = mainContainer.RightPanel
    
    rightPanel.ItemImage.BackgroundColor3 = RARITY_COLORS[item.rarity]
    rightPanel.ItemImage.BorderColor3 = RARITY_BORDERS[item.rarity]
    
    rightPanel.ItemName.Text = item.name
    rightPanel.ItemName.TextColor3 = RARITY_COLORS[item.rarity]
    
    rightPanel.ItemRarity.Text = "⭐ Rareté: " .. item.rarity
    rightPanel.ItemRarity.TextColor3 = RARITY_COLORS[item.rarity]
    
    rightPanel.ItemQuantity.Text = "📦 Quantité: " .. item.quantity
    
    rightPanel.ItemDescription.Text = item.desc
    
    rightPanel.ItemValue.Text = "💰 Valeur: " .. (item.value or 0) .. " pièces"
end

-- Open inventory
function Inventory.open()
    if not inventoryWindow then
        Inventory.init()
    end
    
    if isOpen then return end
    isOpen = true
    
    inventoryWindow.Enabled = true
    print("[Inventory] Ouvert")
end

-- Close inventory
function Inventory.close()
    if not inventoryWindow or not isOpen then return end
    
    isOpen = false
    inventoryWindow.Enabled = false
    print("[Inventory] Fermé")
end

-- Toggle
function Inventory.toggle()
    if isOpen then
        Inventory.close()
    else
        Inventory.open()
    end
end

Inventory.isOpen = isOpen

return Inventory