--***********************************************************
--**                    ROBERT JOHNSON                     **
--**       Contextual menu for building when clicking somewhere on the ground       **
--***********************************************************

ISBuildMenuDowel = {};
ISBuildMenuDowel.planks = 0;
ISBuildMenuDowel.WoodDowel = 0;
ISBuildMenuDowel.hinge = 0;
ISBuildMenuDowel.doorknob = 0;
ISBuildMenuDowel.cheat = false;
ISBuildMenuDowel.woodWorkXp = 0;

ISBuildMenuDowel.doBuildMenu = function(player, context, worldobjects, test)

	if test and ISWorldObjectContextMenu.Test then return true end

    if getCore():getGameMode()=="LastStand" then
        return;
    end

	ISBuildMenuDowel.woodWorkXp = getSpecificPlayer(player):getPerkLevel(Perks.Woodwork);
	local thump = nil;

	local square = nil;

	-- we get the thumpable item (like wall/door/furniture etc.) if exist on the tile we right clicked
	for i,v in ipairs(worldobjects) do
		square = v:getSquare();
		if instanceof(v, "IsoThumpable") and not v:isDoor() then
			thump = v;
		end
    end

	-- build menu
	-- if we have any thing to build in our inventory
	if ISBuildMenuDowel.haveSomethingtoBuildDowel(player) then
        if test then return ISWorldObjectContextMenu.setTest() end
		local buildOption = context:addOption(getText("Build with Dowels"), worldobjects, nil);
		-- create a brand new context menu wich contain our different material (wood, stone etc.) to build
		local subMenu = ISContextMenu:getNew(context);
		-- We create the different option for this new menu (wood, stone etc.)
		-- check if we can build something in wood material
		if haveSomethingtoBuildDowelWoodDowel(player) then
			-- we add the subMenu to our current option (Build)
			context:addSubMenu(buildOption, subMenu);

			------------------ WALL ------------------
            local wallOptionDowel = subMenu:addOption(getText("ContextMenu_Wall"), worldobjects, nil);
            local subMenuWallDowel = subMenu:getNew(subMenu);
            -- we add our new menu to the option we want (here door)
            context:addSubMenu(wallOptionDowel, subMenuWallDowel);
			ISBuildMenuDowel.buildWallMenuDowel(subMenuWallDowel, wallOptionDowel, player);
			------------------ DOOR ------------------
--			local doorOption = subMenu:addOption(getText("ContextMenu_Door"), worldobjects, nil);
--			local subMenuDoor = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here door)
--			context:addSubMenu(doorOption, subMenuDoor);
			ISBuildMenuDowel.buildDoorMenu(subMenu, player);
			------------------ DOOR FRAME ------------------
			ISBuildMenuDowel.buildDoorFrameMenu(subMenu, player);
--~ 			----------------- WINDOWS FRAME-----------------
			ISBuildMenuDowel.buildWindowsFrameMenu(subMenu, player);
--~ 			------------------ STAIRS ------------------
--			local stairsOption = subMenu:addOption(getText("ContextMenu_Stairs"), worldobjects, nil);
--			local subMenuStairs = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here wood)
--			context:addSubMenu(stairsOption, subMenuStairs);
			ISBuildMenuDowel.buildStairsMenu(subMenu, player);
--~ 			------------------ FLOOR ------------------
--			local floorOption = subMenu:addOption(getText("ContextMenu_Floor"), worldobjects, nil);
--			local subMenuFloor = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here build)
--			context:addSubMenu(floorOption, subMenuFloor);
			ISBuildMenuDowel.buildFloorMenu(subMenu, player);
			------------------ WOODEN CRATE ------------------
			ISBuildMenuDowel.buildContainerMenu(subMenu, player);
			------------------ BAR ------------------
			local barOption = subMenu:addOption(getText("ContextMenu_Bar"), worldobjects, nil);
			local subMenuBar = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here wood)
			context:addSubMenu(barOption, subMenuBar);
			ISBuildMenuDowel.buildBarMenu(subMenuBar, barOption, player);
			------------------ FURNITURE ------------------
			local furnitureOption = subMenu:addOption(getText("ContextMenu_Furniture"), worldobjects, nil);
			local subMenuFurniture = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here build)
			context:addSubMenu(furnitureOption, subMenuFurniture);
			ISBuildMenuDowel.buildFurnitureMenu(subMenuFurniture, context, furnitureOption, player);
			------------------ FENCE ------------------
			local fenceOption = subMenu:addOption(getText("ContextMenu_Fence"), worldobjects, nil);
			local subMenuFence = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here build)
			context:addSubMenu(fenceOption, subMenuFence);
			ISBuildMenuDowel.buildFenceMenu(subMenuFence, fenceOption, player);
            ------------------ LIGHT SOURCES ------------------
--            local lightOption = subMenu:addOption("Light source", worldobjects, nil);
--            local subMenuLight = subMenu:getNew(subMenu);
            -- we add our new menu to the option we want (here build)
--            context:addSubMenu(lightOption, subMenuLight);
--            ISBuildMenuDowel.buildLightMenu(subMenu, lightOption, player);
            ISBuildMenuDowel.buildLightMenu(subMenu, player);
		end
	end
end

function ISBuildMenuDowel.haveSomethingtoBuildDowel(player)
--~ 	return true;
	return haveSomethingtoBuildDowelWoodDowel(player);
end

function haveSomethingtoBuildDowelWoodDowel(player)
	ISBuildMenuDowel.materialOnGround = buildUtil.checkMaterialOnGround(getSpecificPlayer(player):getCurrentSquare())
	if ISBuildMenuDowel.cheat then
		return true;
	end
	ISBuildMenuDowel.planks = 0;
	ISBuildMenuDowel.WoodDowel = 0;
	ISBuildMenuDowel.hinge = 0;
	ISBuildMenuDowel.doorknob = 0;
	ISBuildMenuDowel.hasHammer = getSpecificPlayer(player):getInventory():contains("Hammer") or getSpecificPlayer(player):getInventory():contains("HammerStone")
	if ISBuildMenuDowel.hasHammer then
		-- most objects require a hammer
	elseif ISBuildMenuDowel.countMaterialDowel(player, "Base.Sandbag") >= 3 or ISBuildMenuDowel.countMaterialDowel(player, "Base.Gravelbag") >= 3 then
		-- no hammer required
	else
		return false
	end
	ISBuildMenuDowel.planks = ISBuildMenuDowel.countMaterialDowel(player, "Base.Plank")
	ISBuildMenuDowel.WoodDowel = ISBuildMenuDowel.countMaterialDowel(player, "Base.WoodDowel")
	ISBuildMenuDowel.hinge = ISBuildMenuDowel.countMaterialDowel(player, "Base.Hinge")
	ISBuildMenuDowel.doorknob = ISBuildMenuDowel.countMaterialDowel(player, "Base.Doorknob")
	return true;
end

-- **********************************************
-- **                   *BAR*                  **
-- **********************************************

ISBuildMenuDowel.buildBarMenu = function(subMenu, option, player)
	local barElemSprite = ISBuildMenuDowel.getBarElementSprites(player);
	local barElemOption = subMenu:addOption(getText("ContextMenu_Bar_Element"), worldobjects, ISBuildMenuDowel.onBarElement, barElemSprite, player);
	local tooltip = ISBuildMenuDowel.canBuild(5,8,0,0,0,6,barElemOption, player);
	tooltip:setName(getText("ContextMenu_Bar_Element"));
	tooltip.description = getText("Tooltip_craft_barElementDesc") .. tooltip.description;
	tooltip:setTexture(barElemSprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(barElemOption)

	local barCornerSprite = ISBuildMenuDowel.getBarCornerSprites(player);
	local barCornerOption = subMenu:addOption(getText("ContextMenu_Bar_Corner"), worldobjects, ISBuildMenuDowel.onBarElement, barCornerSprite, player);
	local tooltip2 = ISBuildMenuDowel.canBuild(5,8,0,0,0,6,barCornerOption, player);
	tooltip2:setName(getText("ContextMenu_Bar_Corner"));
	tooltip2.description = getText("Tooltip_craft_barElementDesc") .. tooltip2.description;
	tooltip2:setTexture(barCornerSprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(barCornerOption)

    if barElemOption.notAvailable and barCornerOption.notAvailable then
        option.notAvailable = true;
    end
end

ISBuildMenuDowel.onBarElement = function(worldobjects, sprite, player)
	-- sprite, northSprite
	local bar = ISWoodenContainer:new(sprite.sprite, sprite.northSprite);
	bar.name = "Bar";
	bar:setEastSprite(sprite.eastSprite);
	bar:setSouthSprite(sprite.southSprite);
	bar.modData["need:Base.Plank"] = "4";
	bar.modData["need:Base.WoodDowel"] = "4";
	bar.player = player
	bar.renderFloorHelper = true
	getCell():setDrag(bar, player);
end


-- **********************************************
-- **                  *FENCE*                 **
-- **********************************************

ISBuildMenuDowel.buildFenceMenu = function(subMenu, option, player)
	local woodenFenceSprite = ISBuildMenuDowel.getWoodenFenceSprites(player);
	local fenceOption = subMenu:addOption(getText("ContextMenu_Wooden_Fence"), worldobjects, ISBuildMenuDowel.onWoodenFence, square, woodenFenceSprite, player);
	local tooltip3 = ISBuildMenuDowel.canBuild(3,6,0,0,0,4,fenceOption, player);
	tooltip3:setName(getText("ContextMenu_Wooden_Fence"));
	tooltip3.description = getText("Tooltip_craft_woodenFenceDesc") .. tooltip3.description;
	tooltip3:setTexture(woodenFenceSprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(fenceOption)

    if fenceOption.notAvailable then
        option.notAvailable = true;
    end
end

ISBuildMenuDowel.onWoodenFence = function(worldobjects, square, sprite, player)
	-- sprite, northSprite, corner
	local fence = ISWoodenWall:new(sprite.sprite, sprite.northSprite, sprite.corner);
	-- you can hopp a fence
	fence.hoppable = true;
	fence.isThumpable = false;
	fence.modData["need:Base.Plank"] = "3";
	fence.modData["need:Base.WoodDowel"] = "6";
	fence.player = player
	fence.name = "Wooden Fence"
	getCell():setDrag(fence, player);
end

-- **********************************************
-- **          *LIGHT SOURCES*                 **
-- **********************************************
ISBuildMenuDowel.buildLightMenu = function(subMenu, player)
    local sprite = ISBuildMenuDowel.getPillarLampSprite(player);
    local lampOption = subMenu:addOption(getText("ContextMenu_Lamp_on_Pillar"), worldobjects, ISBuildMenuDowel.onPillarLamp, square, sprite, player);
    local toolTip = ISBuildMenuDowel.canBuild(3,8,0,0,0,5,lampOption, player);
    if not getSpecificPlayer(player):getInventory():contains("Torch") and not ISBuildMenuDowel.cheat then
        toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemText("Flashlight") .. "0/1 ";
        lampOption.onSelect = nil;
        lampOption.notAvailable = true;
    else
        toolTip.description = toolTip.description .. " <RGB:1,1,1>" .. getItemText("Flashlight") .. " 1 ";
    end
    if not getSpecificPlayer(player):getInventory():contains("Rope") and not ISBuildMenuDowel.cheat then
        toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0>" .. getItemText("Rope") .." 0/1 ";
        lampOption.onSelect = nil;
        lampOption.notAvailable = true;
    else
        toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1>" .. getItemText("Rope") .. "Rope 1 ";
    end
    toolTip:setName(getText("ContextMenu_Lamp_on_Pillar"));
    toolTip.description = getText("ContextMenu_Lamp_on_Pillar") .. " " .. toolTip.description;
    toolTip:setTexture("carpentry_02_59");
	ISBuildMenuDowel.requireHammerDowel(lampOption)

--    if lampOption.notAvailable then
--        option.notAvailable = true;
--    end
end

ISBuildMenuDowel.onPillarLamp = function(worldobjects, square, sprite, player)
-- sprite, northSprite
    local lamp = ISLightSource:new(sprite.sprite, sprite.northSprite, getSpecificPlayer(player));
    lamp.offsetX = 5;
    lamp.offsetY = 5;
    lamp.modData["need:Base.Plank"] = "3";
    lamp.modData["need:Base.Rope"] = "1";
    lamp.modData["need:Base.WoodDowel"] = "8";
--    lamp.modData["need:Base.Torch"] = "1";
    lamp:setEastSprite(sprite.eastSprite);
    lamp:setSouthSprite(sprite.southSprite);
    lamp.fuel = "Base.Battery";
    lamp.baseItem = "Base.Torch";
    lamp.radius = 10;
    lamp.player = player
    getCell():setDrag(lamp, player);
end

-- **********************************************
-- **                  *WALL*                  **
-- **********************************************

ISBuildMenuDowel.buildWallMenuDowel = function(subMenu, option, player)
	local sprite = ISBuildMenuDowel.getWoodenWallSprites(player);
	local wallOptionDowel = subMenu:addOption(getText("ContextMenu_Wooden_Wall"), worldobjects, ISBuildMenuDowel.onWoodenWall, sprite, player);
	local tooltip = ISBuildMenuDowel.canBuild(4, 6, 0, 0, 0, 4, wallOptionDowel, player);
	tooltip:setName(getText("ContextMenu_Wooden_Wall"));
	tooltip.description = getText("Tooltip_craft_woodenWallDesc") .. tooltip.description;
	tooltip:setTexture(sprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(wallOptionDowel)

	local pillarOption = subMenu:addOption(getText("ContextMenu_Wooden_Pillar"), worldobjects, ISBuildMenuDowel.onWoodenPillar, player);
	local tooltip = ISBuildMenuDowel.canBuild(3, 6, 0, 0, 0, 4, pillarOption, player);
	tooltip:setName(getText("ContextMenu_Wooden_Pillar"));
	tooltip.description = getText("Tooltip_craft_woodenPillarDesc") .. tooltip.description;
	tooltip:setTexture("walls_exterior_wooden_01_27");
	ISBuildMenuDowel.requireHammerDowel(pillarOption)

    if wallOptionDowel.notAvailable and pillarOption.notAvailable then
        option.notAvailable = true;
    end
end

ISBuildMenuDowel.onWoodenPillar = function(worldobjects, player)
	local wall = ISWoodenWall:new("walls_exterior_wooden_01_27", "walls_exterior_wooden_01_27", nil);
	wall.modData["need:Base.Plank"] = "3";
	wall.modData["need:Base.WoodDowel"] = "6";
	wall.canPassThrough = true;
	wall.canBarricade = false
    wall.player = player;
    wall.name = "Wooden Pillar"
	getCell():setDrag(wall, player);
end

ISBuildMenuDowel.onWoodenWall = function(worldobjects, sprite, player)
	-- sprite, northSprite, corner
	local wall = ISWoodenWall:new(sprite.sprite, sprite.northSprite, sprite.corner);
    if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) >= 4 then
	    wall.canBePlastered = true;
    end
	wall.canBarricade = false
	-- set up the required material
    wall.modData["wallType"] = "wall";
	wall.modData["need:Base.Plank"] = "4";
	wall.modData["need:Base.WoodDowel"] = "6";
    wall.player = player;
    getCell():setDrag(wall, player);
end

-- **********************************************
-- **              *WINDOWS FRAME*             **
-- **********************************************
ISBuildMenuDowel.buildWindowsFrameMenu = function(subMenu, player)
	local sprite = ISBuildMenuDowel.getWoodenWindowsFrameSprites(player);
	local wallOptionDowel = subMenu:addOption(getText("ContextMenu_Windows_Frame"), worldobjects, ISBuildMenuDowel.onWoodenWindowsFrame, square, sprite, player);
	local tooltip = ISBuildMenuDowel.canBuild(5, 8, 0, 0, 0, 4, wallOptionDowel, player);
	tooltip:setName(getText("ContextMenu_Windows_Frame"));
	tooltip.description = getText("Tooltip_craft_woodenFrameDesc") .. tooltip.description;
	tooltip:setTexture(sprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(wallOptionDowel)
end

ISBuildMenuDowel.onWoodenWindowsFrame = function(worldobjects, square, sprite, player)
	-- sprite, northSprite, corner
	local frame = ISWoodenWall:new(sprite.sprite, sprite.northSprite, sprite.corner);
    if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) >= 4 then
	    frame.canBePlastered = true;
    end
	frame.hoppable = true;
	frame.isThumpable = false
	-- set up the required material
    frame.modData["wallType"] = "windowsframe";
	frame.modData["need:Base.Plank"] = "5";
	frame.modData["need:Base.WoodDowel"] = "8";
	frame.player = player
	frame.name = "Window Frame"
	getCell():setDrag(frame, player);
end

-- **********************************************
-- **                  *FLOOR*                 **
-- **********************************************

ISBuildMenuDowel.buildFloorMenu = function(subMenu, player)
	-- simple wooden floor
    local floorSprite = ISBuildMenuDowel.getWoodenFloorSprites(player);
	local floorOption = subMenu:addOption(getText("ContextMenu_Wooden_Floor"), worldobjects, ISBuildMenuDowel.onWoodenFloor, square, floorSprite, player);
	local tooltip = ISBuildMenuDowel.canBuild(1,2,0,0,0,4,floorOption, player);
	tooltip:setName(getText("ContextMenu_Wooden_Floor"));
	tooltip.description = getText("Tooltip_craft_woodenFloorDesc") .. tooltip.description;
	tooltip:setTexture(floorSprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(floorOption)
end

ISBuildMenuDowel.onWoodenFloor = function(worldobjects, square, sprite, player)
	-- sprite, northSprite
	local foor = ISWoodenFloor:new(sprite.sprite, sprite.northSprite)
	foor.modData["need:Base.Plank"] = "1";
	foor.modData["need:Base.WoodDowel"] = "2";
	foor.player = player
	getCell():setDrag(foor, player);
end

ISBuildMenuDowel.onWoodenBrownFloor = function(worldobjects, square, player)
	-- sprite, northSprite
	local foor = ISWoodenFloor:new("TileFloorInt_24", "TileFloorInt_24")
	foor.modData["need:Base.Plank"] = "1";
	foor.modData["need:Base.WoodDowel"] = "2";
	getCell():setDrag(foor, player);
end

ISBuildMenuDowel.onWoodenLightBrownFloor = function(worldobjects, square, player)
	-- sprite, northSprite
	local foor = ISWoodenFloor:new("TileFloorInt_6", "TileFloorInt_6")
	foor.modData["need:Base.Plank"] = "1";
	foor.modData["need:Base.WoodDowel"] = "2";
	foor.player = player
	getCell():setDrag(foor, player);
end

-- **********************************************
-- **               *CONTAINER*                **
-- **********************************************

ISBuildMenuDowel.buildContainerMenu = function(subMenu, player)
    local crateSprite = ISBuildMenuDowel.getWoodenCrateSprites(player);
	local crateOption = subMenu:addOption(getText("ContextMenu_Wooden_Crate"), worldobjects, ISBuildMenuDowel.onWoodenCrate, square, crateSprite, player);
	local toolTip = ISBuildMenuDowel.canBuild(3,4,0,0,0,5,crateOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Crate"));
	toolTip.description = getText("Tooltip_craft_woodenCrateDesc") .. toolTip.description;
	toolTip:setTexture(crateSprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(crateOption)
end

ISBuildMenuDowel.onWoodenCrate = function(worldobjects, square, crateSprite, player)
	-- sprite, northSprite
	local crate = ISWoodenContainer:new(crateSprite.sprite, crateSprite.northSprite);
	crate.renderFloorHelper = true
	crate.canBeAlwaysPlaced = true;
	crate.modData["need:Base.Plank"] = "3";
	crate.modData["need:Base.WoodDowel"] = "4";
	crate:setEastSprite(crateSprite.eastSprite);
	crate.player = player
	getCell():setDrag(crate, player);
end

-- **********************************************
-- **              *FURNITURE*                 **
-- **********************************************

ISBuildMenuDowel.buildFurnitureMenu = function(subMenu, context, option, player)
	-- add the table submenu
	local tableOption = subMenu:addOption(getText("ContextMenu_Table"), worldobjects, nil);
	local subMenuTable = subMenu:getNew(subMenu);
	context:addSubMenu(tableOption, subMenuTable);

	-- add all our table option
	local tableSprite = ISBuildMenuDowel.getWoodenTableSprites(player);
	local smallTableOption = subMenuTable:addOption(getText("ContextMenu_Small_Table"), worldobjects, ISBuildMenuDowel.onSmallWoodTable, square, tableSprite, player);
	local tooltip = ISBuildMenuDowel.canBuild(6,8,0,0,0,4,smallTableOption, player);
	tooltip:setName(getText("ContextMenu_Small_Table"));
	tooltip.description = getText("Tooltip_craft_smallTableDesc") .. tooltip.description;
	tooltip:setTexture(tableSprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(smallTableOption)

	local largeTableSprite = ISBuildMenuDowel.getLargeWoodTableSprites(player);
	local largeTableOption = subMenuTable:addOption(getText("ContextMenu_Large_Table"), worldobjects, ISBuildMenuDowel.onLargeWoodTable, square, largeTableSprite, player);
	local tooltip2 = ISBuildMenuDowel.canBuild(7,8,0,0,0,4,largeTableOption, player);
	tooltip2:setName(getText("ContextMenu_Large_Table"));
	tooltip2.description = getText("Tooltip_craft_largeTableDesc") .. tooltip2.description;
	tooltip2:setTexture(largeTableSprite.sprite1);
	ISBuildMenuDowel.requireHammerDowel(largeTableOption)

	local drawerSprite = ISBuildMenuDowel.getTableWithDrawerSprites(player);
	local drawerTableOption = subMenuTable:addOption(getText("ContextMenu_Table_with_Drawer"), worldobjects, ISBuildMenuDowel.onSmallWoodTableWithDrawer, square, drawerSprite, player);
	local tooltip3 = ISBuildMenuDowel.canBuild(6,8,0,0,0,5,drawerTableOption, player);
	-- we add that we need a Drawer too
	if not getSpecificPlayer(player):getInventory():contains("Drawer") and not ISBuildMenuDowel.cheat then
		tooltip3.description = tooltip3.description .. " <RGB:1,0,0>" .. getItemText("Drawer") .. " 0/1 <LINE>";
		drawerTableOption.onSelect = nil;
		drawerTableOption.notAvailable = true;
	else
		tooltip3.description = tooltip3.description .. " <RGB:1,1,1>" .. getItemText("Drawer") .. " 1/1 <LINE>";
	end
	tooltip3:setName(getText("ContextMenu_Table_with_Drawer"));
	tooltip3.description = getText("Tooltip_craft_tableDrawerDesc") .. tooltip3.description;
	tooltip3:setTexture(drawerSprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(drawerTableOption)

    if smallTableOption.notAvailable and largeTableOption.notAvailable and drawerTableOption.notAvailable then
        tableOption.notAvailable = true;
    end

	-- now the chair
	local chairSprite = ISBuildMenuDowel.getWoodenChairSprites(player);
	local chairOption = subMenu:addOption(getText("ContextMenu_Wooden_Chair"), worldobjects, ISBuildMenuDowel.onWoodChair, square, chairSprite, player);
	local tooltip4 = ISBuildMenuDowel.canBuild(6,8,0,0,0,4,chairOption, player);
	tooltip4:setName(getText("ContextMenu_Wooden_Chair"));
	tooltip4.description = getText("Tooltip_craft_woodenChairDesc") .. tooltip4.description;
	tooltip4:setTexture(chairSprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(chairOption)

	-- rain collector barrel
	local barrelOption = subMenu:addOption(getText("ContextMenu_Rain_Collector_Barrel"), worldobjects, ISBuildMenuDowel.onCreateBarrel, player, "carpentry_02_54", 40);
	local tooltip = ISBuildMenuDowel.canBuild(5,8,0,0,0,6,barrelOption, player);
    -- we add that we need 4 garbage bag too
    if ISBuildMenuDowel.countMaterialDowel(player, "Base.Garbagebag") < 4 and not ISBuildMenuDowel.cheat then
        tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Garbage Bag") .. " " .. ISBuildMenuDowel.countMaterialDowel(player, "Base.Garbagebag") .. "/4 ";
        barrelOption.onSelect = nil;
        barrelOption.notAvailable = true;
    else
        tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Garbage Bag") .. " 4/4 ";
    end
	tooltip:setName(getText("ContextMenu_Rain_Collector_Barrel"));
	tooltip.description = getText("Tooltip_craft_rainBarrelDesc") .. tooltip.description;
	tooltip:setTexture("carpentry_02_54");
	ISBuildMenuDowel.requireHammerDowel(barrelOption)

    -- rain collector barrel
    local barrel2Option = subMenu:addOption(getText("ContextMenu_Rain_Collector_Barrel"), worldobjects, ISBuildMenuDowel.onCreateBarrel, player, "carpentry_02_52", 100);
    local tooltip = ISBuildMenuDowel.canBuild(5,8,0,0,0,7,barrel2Option, player);
    -- we add that we need 4 garbage bag too
    if ISBuildMenuDowel.countMaterialDowel(player, "Base.Garbagebag") < 4 and not ISBuildMenuDowel.cheat then
        tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Garbage Bag") .. " " .. ISBuildMenuDowel.countMaterialDowel(player, "Base.Garbagebag") .. "/4 ";
        barrel2Option.onSelect = nil;
        barrel2Option.notAvailable = true;
    else
        tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Garbage Bag") .. " 4/4 ";
    end
    tooltip:setName(getText("ContextMenu_Rain_Collector_Barrel"));
    tooltip.description = getText("Tooltip_craft_rainBarrelDesc") .. tooltip.description;
    tooltip:setTexture("carpentry_02_52");
	ISBuildMenuDowel.requireHammerDowel(barrel2Option)

    local bookSprite = ISBuildMenuDowel.getBookcaseSprite(player);
    local bookOption = subMenu:addOption(getText("ContextMenu_Bookcase"), worldobjects, ISBuildMenuDowel.onBookcase, square, bookSprite, player);
    local tooltip5 = ISBuildMenuDowel.canBuild(6,8,0,0,0,6,bookOption, player);
    tooltip5:setName(getText("ContextMenu_Bookcase"));
    tooltip5.description = getText("Tooltip_craft_bookcaseDesc") .. tooltip5.description;
    tooltip5:setTexture(bookSprite.southSprite);
	ISBuildMenuDowel.requireHammerDowel(bookOption)

    local book2Sprite = ISBuildMenuDowel.getSmallBookcaseSprite(player);
    local book2Option = subMenu:addOption(getText("ContextMenu_SmallBookcase"), worldobjects, ISBuildMenuDowel.onSmallBookcase, square, book2Sprite, player);
    local tooltip7 = ISBuildMenuDowel.canBuild(4,6,0,0,0,6,book2Option, player);
    tooltip7:setName(getText("ContextMenu_SmallBookcase"));
    tooltip7.description = getText("Tooltip_craft_smallBookcaseDesc") .. tooltip7.description;
    tooltip7:setTexture(book2Sprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(book2Option)

    local shelveSprite = ISBuildMenuDowel.getShelveSprite(player);
    local shelveOption = subMenu:addOption(getText("ContextMenu_Shelves"), worldobjects, ISBuildMenuDowel.onShelve, square, shelveSprite, player);
    local tooltip6 = ISBuildMenuDowel.canBuild(2,4,0,0,0,4,shelveOption, player);
    tooltip6:setName(getText("ContextMenu_Shelves"));
    tooltip6.description = getText("Tooltip_craft_shelvesDesc") .. tooltip6.description;
    tooltip6:setTexture(shelveSprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(shelveOption)

    local shelve2Sprite = ISBuildMenuDowel.getDoubleShelveSprite(player);
    local shelve2Option = subMenu:addOption(getText("ContextMenu_DoubleShelves"), worldobjects, ISBuildMenuDowel.onDoubleShelve, square, shelve2Sprite, player);
    local tooltip8 = ISBuildMenuDowel.canBuild(3,8,0,0,0,4,shelve2Option, player);
    tooltip8:setName(getText("ContextMenu_DoubleShelves"));
    tooltip8.description = getText("Tooltip_craft_doubleShelvesDesc") .. tooltip8.description;
    tooltip8:setTexture(shelve2Sprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(shelve2Option)

    -- bed
    local bedSprite = ISBuildMenuDowel.getBedSprite(player);
    local bedOption = subMenu:addOption(getText("ContextMenu_Bed"), worldobjects, ISBuildMenuDowel.onBed, square, bedSprite, player);
    local tooltip9 = ISBuildMenuDowel.canBuild(7,8,0,0,0,6,bedOption, player);
    -- we add that we need a mattress too
    if ISBuildMenuDowel.countMaterialDowel(player, "Base.Mattress") < 1 and not ISBuildMenuDowel.cheat then
        tooltip9.description = tooltip9.description .. " <RGB:1,0,0>" .. getItemText("Mattress") .. " 0/1 ";
        bedOption.onSelect = nil;
        bedOption.notAvailable = true;
    else
        tooltip9.description = tooltip9.description .. " <RGB:1,1,1>" .. getItemText("Mattress") .. " 1/1 ";
    end
    tooltip9:setName(getText("ContextMenu_Bed"));
    tooltip9.description = getText("Tooltip_craft_bedDesc") .. tooltip9.description;
    tooltip9:setTexture(bedSprite.northSprite1);
	ISBuildMenuDowel.requireHammerDowel(bedOption)

    local signSprite = ISBuildMenuDowel.getSignSprite(player);
    local signOption = subMenu:addOption(getText("ContextMenu_Sign"), worldobjects, ISBuildMenuDowel.onSign, square, signSprite, player);
    local tooltip10 = ISBuildMenuDowel.canBuild(4,6,0,0,0,4,signOption, player);
    tooltip10:setName(getText("ContextMenu_Sign"));
    tooltip10.description = getText("Tooltip_craft_signDesc") .. tooltip10.description;
    tooltip10:setTexture(signSprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(signOption)

    if tableOption.notAvailable and signOption.notAvailable and bedOption.notAvailable and shelve2Option.notAvailable and shelveOption.notAvailable and book2Option.notAvailable and bookOption.notAvailable and barrel2Option.notAvailable and barrelOption.notAvailable and chairOption.notAvailable then
        option.notAvailable = true;
    end
end

-- create a new barrel to drag a ghost render of the barrel under the mouse
ISBuildMenuDowel.onCreateBarrel = function(worldobjects, player, sprite, waterMax)
	local barrel = RainCollectorBarrel:new(player, sprite, waterMax);
	-- we now set his the mod data the needed material
	-- by doing this, all will be automatically consummed, drop on the ground if destoryed etc.
	barrel.modData["need:Base.Plank"] = "5";
	barrel.modData["need:Base.WoodDowel"] = "8";
    barrel.modData["need:Base.Garbagebag"] = "4";
	-- and now allow the item to be dragged by mouse
	barrel.player = player
	getCell():setDrag(barrel, player);
end

ISBuildMenuDowel.onBed = function(worldobjects, square, sprite, player)
    local furniture = ISDoubleTileFurniture:new("Bed", sprite.sprite1, sprite.sprite2, sprite.northSprite1, sprite.northSprite2);
    furniture.modData["need:Base.Plank"] = "7";
    furniture.modData["need:Base.WoodDowel"] = "8";
    furniture.modData["need:Base.Mattress"] = "1";
    furniture.player = player
    getCell():setDrag(furniture, player);
end

ISBuildMenuDowel.onSmallWoodTable = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Small Table", sprite.sprite, sprite.sprite);
	furniture.modData["need:Base.Plank"] = "6";
	furniture.modData["need:Base.WoodDowel"] = "8";
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenuDowel.onSmallWoodTableWithDrawer = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Small Table with Drawer", sprite.sprite, sprite.northSprite);
	furniture.modData["need:Base.Plank"] = "6";
	furniture.modData["need:Base.WoodDowel"] = "8";
	furniture.modData["need:Base.Drawer"] = "1";
	furniture:setEastSprite(sprite.eastSprite);
	furniture:setSouthSprite(sprite.southSprite);
	furniture.isContainer = true;
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenuDowel.onLargeWoodTable = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISDoubleTileFurniture:new("Large Table", sprite.sprite1, sprite.sprite2, sprite.northSprite1, sprite.northSprite2);
	furniture.modData["need:Base.Plank"] = "7";
	furniture.modData["need:Base.WoodDowel"] = "8";
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenuDowel.onWoodChair = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Wooden Chair", sprite.sprite, sprite.northSprite);
	furniture.modData["need:Base.Plank"] = "6";
	furniture.modData["need:Base.WoodDowel"] = "8";
	-- our chair have 4 tiles (north, east, south and west)
	-- then we define our east and south sprite
	furniture:setEastSprite(sprite.eastSprite);
	furniture:setSouthSprite(sprite.southSprite);
	furniture.canPassThrough = true;
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenuDowel.onBookcase = function(worldobjects, square, sprite, player)
    -- name, sprite, northSprite
    local furniture = ISSimpleFurniture:new("Bookcase", sprite.sprite, sprite.northSprite);
    furniture.canBeAlwaysPlaced = true;
    furniture.isContainer = true;
    furniture.containerType = "shelves";
    furniture.modData["need:Base.Plank"] = "6";
    furniture.modData["need:Base.WoodDowel"] = "8";
    -- our chair have 4 tiles (north, east, south and west)
    -- then we define our east and south sprite
    furniture:setEastSprite(sprite.eastSprite);
    furniture:setSouthSprite(sprite.southSprite);
    furniture.player = player
    getCell():setDrag(furniture, player);
end

ISBuildMenuDowel.onSmallBookcase = function(worldobjects, square, sprite, player)
-- name, sprite, northSprite
    local furniture = ISSimpleFurniture:new("Small Bookcase", sprite.sprite, sprite.northSprite);
    furniture.canBeAlwaysPlaced = true;
    furniture.isContainer = true;
    furniture.containerType = "shelves";
    furniture.modData["need:Base.Plank"] = "4";
    furniture.modData["need:Base.WoodDowel"] = "6";
    -- our chair have 4 tiles (north, east, south and west)
    -- then we define our east and south sprite
    furniture:setEastSprite(sprite.eastSprite);
    furniture:setSouthSprite(sprite.southSprite);
    furniture.player = player
    getCell():setDrag(furniture, player);
end

ISBuildMenuDowel.onShelve = function(worldobjects, square, sprite, player)
    -- name, sprite, northSprite
    local furniture = ISSimpleFurniture:new("Shelves", sprite.sprite, sprite.northSprite);
    furniture.isContainer = true;
    furniture.needToBeAgainstWall = true;
    furniture.blockAllTheSquare = false;
    furniture.containerType = "shelves";
    furniture.modData["need:Base.Plank"] = "2";
    furniture.modData["need:Base.WoodDowel"] = "4";
    furniture.player = player
    getCell():setDrag(furniture, player);
end

ISBuildMenuDowel.onSign = function(worldobjects, square, sprite, player)
-- name, sprite, northSprite
    local furniture = ISSimpleFurniture:new("Wooden Sign", sprite.sprite, sprite.northSprite);
    furniture.blockAllTheSquare = false;
    furniture.modData["need:Base.Plank"] = "4";
    furniture.modData["need:Base.WoodDowel"] = "6";
    furniture.player = player
    getCell():setDrag(furniture, player);
end

ISBuildMenuDowel.onDoubleShelve = function(worldobjects, square, sprite, player)
-- name, sprite, northSprite
    local furniture = ISSimpleFurniture:new("Double Shelves", sprite.sprite, sprite.northSprite);
    furniture.isContainer = true;
    furniture.needToBeAgainstWall = true;
    furniture.blockAllTheSquare = false;
    furniture.containerType = "shelves";
    furniture.modData["need:Base.Plank"] = "3";
    furniture.modData["need:Base.WoodDowel"] = "8";
    furniture.player = player
    getCell():setDrag(furniture, player);
end

-- **********************************************
-- **                 *STAIRS*                 **
-- **********************************************

ISBuildMenuDowel.buildStairsMenu = function(subMenu, player)
--	local darkStairsOption = subMenu:addOption(getText("ContextMenu_Dark_Wooden_Stairs"), worldobjects, ISBuildMenuDowel.onDarkWoodenStairs, square, player);
--	local tooltip = ISBuildMenuDowel.canBuild(8,8,0,0,0,3,darkStairsOption, player);
--	tooltip:setName(getText("ContextMenu_Dark_Wooden_Stairs"));
--	tooltip.description = getText("Tooltip_craft_stairsDesc") .. tooltip.description;
--	tooltip:setTexture("fixtures_stairs_01_16");

	local stairsOption = subMenu:addOption(getText("ContextMenu_Stairs"), worldobjects, ISBuildMenuDowel.onBrownWoodenStairs, square, player);
	local tooltip2 = ISBuildMenuDowel.canBuild(10,16,0,0,0,8,stairsOption, player);
	tooltip2:setName(getText("ContextMenu_Stairs"));
	tooltip2.description = getText("Tooltip_craft_stairsDesc") .. tooltip2.description;
	tooltip2:setTexture("carpentry_02_88");
	ISBuildMenuDowel.requireHammerDowel(stairsOption)

--	local lightStairsOption = subMenu:addOption(getText("ContextMenu_Light_Brown_Wooden_Stairs"), worldobjects, ISBuildMenuDowel.onLightBrownWoodenStairs, square, player);
--	local tooltip3 = ISBuildMenuDowel.canBuild(8,8,0,0,0,3,lightStairsOption, player);
--	tooltip3:setName(getText("ContextMenu_Light_Brown_Wooden_Stairs"));
--	tooltip3.description = getText("Tooltip_craft_stairsDesc") .. tooltip3.description;
--	tooltip3:setTexture("fixtures_stairs_01_32");

--    if darkStairsOption.notAvailable and stairsOption.notAvailable and lightStairsOption.notAvailable then
--        option.notAvailable = true;
--    end
end

ISBuildMenuDowel.onDarkWoodenStairs = function(worldobjects, square, player)
	local stairs = ISWoodenStairs:new("fixtures_stairs_01_16", "fixtures_stairs_01_17", "fixtures_stairs_01_18", "fixtures_stairs_01_24", "fixtures_stairs_01_25", "fixtures_stairs_01_26", "fixtures_stairs_01_22", "fixtures_stairs_01_23");
	stairs.modData["need:Base.Plank"] = "10";
	stairs.modData["need:Base.WoodDowel"] = "16";
    stairs.isThumpable = false;
    stairs.player = player
    getCell():setDrag(stairs, player);
end

ISBuildMenuDowel.onBrownWoodenStairs = function(worldobjects, square, player)
    local stairs = ISWoodenStairs:new("carpentry_02_88", "carpentry_02_89", "carpentry_02_90", "carpentry_02_96", "carpentry_02_97", "carpentry_02_98", "carpentry_02_94", "carpentry_02_95");
    stairs.modData["need:Base.Plank"] = "10";
    stairs.modData["need:Base.WoodDowel"] = "16";
    stairs.player = player
    getCell():setDrag(stairs, player);
end

ISBuildMenuDowel.onLightBrownWoodenStairs = function(worldobjects, square, player)
    local stairs = ISWoodenStairs:new("fixtures_stairs_01_32", "fixtures_stairs_01_33", "fixtures_stairs_01_34", "fixtures_stairs_01_40", "fixtures_stairs_01_41", "fixtures_stairs_01_42", "fixtures_stairs_01_38", "fixtures_stairs_01_39");
    stairs.modData["need:Base.Plank"] = "10";
	stairs.modData["need:Base.WoodDowel"] = "16";
    stairs.player = player
    getCell():setDrag(stairs, player);
end

-- **********************************************
-- **                 *DOOR*                   **
-- **********************************************

ISBuildMenuDowel.buildDoorMenu = function(subMenu, player)
	local sprite = ISBuildMenuDowel.getWoodenDoorSprites(player);
	local doorsOption = subMenu:addOption(getText("ContextMenu_Wooden_Door"), worldobjects, ISBuildMenuDowel.onWoodenDoor, square, sprite, player);
	local tooltip = ISBuildMenuDowel.canBuild(5,8,2,1,0,4,doorsOption, player);
	tooltip:setName(getText("ContextMenu_Wooden_Door"));
	tooltip.description = getText("Tooltip_craft_woodenDoorDesc") .. tooltip.description;
	tooltip:setTexture(sprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(doorsOption)

--~ 	local farmdoorsOption = subMenu:addOption("Farm Door", worldobjects, ISBuildMenuDowel.onFarmDoor, square);
--~ 	local tooltip2 = ISBuildMenuDowel.canBuild(4,4,2,1,0,1,farmdoorsOption);
--~ 	tooltip2:setName("Farm Door");
--~ 	tooltip2.description = "A farm door, has to be placed in a door frame " .. tooltip2.description;
--~ 	tooltip2:setTexture("TileDoors_8");
end

ISBuildMenuDowel.onWoodenDoor = function(worldobjects, square, sprite, player)
	-- sprite, northsprite, openSprite, openNorthSprite
	local door = ISWoodenDoor:new(sprite.sprite, sprite.northSprite, sprite.openSprite, sprite.openNorthSprite);
	door.modData["need:Base.Plank"] = "5";
	door.modData["need:Base.WoodDowel"] = "8";
	door.modData["need:Base.Hinge"] = "2";
	door.modData["need:Base.Doorknob"] = "1";
	door.player = player
	getCell():setDrag(door, player);
end

ISBuildMenuDowel.onFarmDoor = function(worldobjects, square, player)
	-- sprite, northsprite, openSprite, openNorthSprite
	getCell():setDrag(ISWoodenDoor:new("TileDoors_8", "TileDoors_9", "TileDoors_10", "TileDoors_11"), player);
end

-- **********************************************
-- **              *DOOR FRAME*                **
-- **********************************************

ISBuildMenuDowel.buildDoorFrameMenu = function(subMenu, player)
	local frameSprite = ISBuildMenuDowel.getWoodenDoorFrameSprites(player);
	local doorFrameOption = subMenu:addOption(getText("ContextMenu_Door_Frame"), worldobjects, ISBuildMenuDowel.onWoodenDoorFrame, square, frameSprite, player);
	local tooltip = ISBuildMenuDowel.canBuild(5,8,0,0,0,4,doorFrameOption, player);
	tooltip:setName(getText("ContextMenu_Door_Frame"));
	tooltip.description = getText("Tooltip_craft_doorFrameDesc") .. tooltip.description;
	tooltip:setTexture(frameSprite.sprite);
	ISBuildMenuDowel.requireHammerDowel(doorFrameOption)
end

ISBuildMenuDowel.onWoodenDoorFrame = function(worldobjects, square, sprite, player)
	-- sprite, northSprite, corner
	local doorFrame = ISWoodenDoorFrame:new(sprite.sprite, sprite.northSprite, sprite.corner)
    if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) >= 4 then
	    doorFrame.canBePlastered = true;
    end
    doorFrame.modData["wallType"] = "doorframe";
	doorFrame.modData["need:Base.Plank"] = "5";
	doorFrame.modData["need:Base.WoodDowel"] = "8";
	doorFrame.player = player
	getCell():setDrag(doorFrame, player);
end

-- **********************************************
-- **            SPRITE FUNCTIONS              **
-- **********************************************

ISBuildMenuDowel.getBedSprite = function(player)
    local sprite = {};
    sprite.sprite1 = "carpentry_02_73";
    sprite.sprite2 = "carpentry_02_72";
    sprite.northSprite1 = "carpentry_02_74";
    sprite.northSprite2 = "carpentry_02_75";
    return sprite;
end

ISBuildMenuDowel.getLargeWoodTableSprites = function(player)
	local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite1 = "carpentry_01_25";
		sprite.sprite2 = "carpentry_01_24";
		sprite.northSprite1 = "carpentry_01_26";
		sprite.northSprite2 = "carpentry_01_27";
	elseif spriteLvl == 2 then
		sprite.sprite1 = "carpentry_01_29";
		sprite.sprite2 = "carpentry_01_28";
		sprite.northSprite1 = "carpentry_01_30";
		sprite.northSprite2 = "carpentry_01_31";
	else
		sprite.sprite1 = "carpentry_01_33";
		sprite.sprite2 = "carpentry_01_32";
		sprite.northSprite1 = "carpentry_01_34";
		sprite.northSprite2 = "carpentry_01_35";
	end
	return sprite;
end

ISBuildMenuDowel.getTableWithDrawerSprites = function(player)
	local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_02_0";
		sprite.northSprite = "carpentry_02_2";
		sprite.southSprite = "carpentry_02_1";
		sprite.eastSprite = "carpentry_02_3";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_02_4";
		sprite.northSprite = "carpentry_02_6";
		sprite.southSprite = "carpentry_02_5";
		sprite.eastSprite = "carpentry_02_7";
	else
		sprite.sprite = "carpentry_02_8";
		sprite.northSprite = "carpentry_02_10";
		sprite.southSprite = "carpentry_02_9";
		sprite.eastSprite = "carpentry_02_11";
	end
	return sprite;
end

ISBuildMenuDowel.getWoodenFenceSprites = function(player)
	local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_02_40";
		sprite.northSprite = "carpentry_02_41";
		sprite.corner = "carpentry_02_43";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_02_44";
		sprite.northSprite = "carpentry_02_45";
		sprite.corner = "carpentry_02_47";
	else
		sprite.sprite = "carpentry_02_48";
		sprite.northSprite = "carpentry_02_49";
		sprite.corner = "carpentry_02_51";
	end
	return sprite;
end

ISBuildMenuDowel.getWoodenFloorSprites = function(player)
    local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
    local sprite = {};
    if spriteLvl == 1 then
        sprite.sprite = "carpentry_02_58";
        sprite.northSprite = "carpentry_02_58";
    elseif spriteLvl == 2 then
        sprite.sprite = "carpentry_02_57";
        sprite.northSprite = "carpentry_02_57";
    else
        sprite.sprite = "carpentry_02_56";
        sprite.northSprite = "carpentry_02_56";
    end
    if ISBuildMenuDowel.cheat then
        sprite.sprite = "carpentry_02_56";
        sprite.northSprite = "carpentry_02_56";
    end
    return sprite;
end

ISBuildMenuDowel.getWoodenCrateSprites = function(player)
    local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
    local sprite = {};
    if spriteLvl <= 2 then
        sprite.sprite = "carpentry_01_19";
        sprite.northSprite = "carpentry_01_20";
        sprite.eastSprite = "carpentry_01_21";
    else
        sprite.sprite = "carpentry_01_16";
        sprite.northSprite = "carpentry_01_17";
        sprite.eastSprite = "carpentry_01_18";
    end
    return sprite;
end

ISBuildMenuDowel.getWoodenChairSprites = function(player)
	local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_01_36";
		sprite.northSprite = "carpentry_01_38";
		sprite.southSprite = "carpentry_01_39";
		sprite.eastSprite = "carpentry_01_37";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_01_40";
		sprite.northSprite = "carpentry_01_42";
		sprite.southSprite = "carpentry_01_41";
		sprite.eastSprite = "carpentry_01_43";
	else
		sprite.sprite = "carpentry_01_45";
		sprite.northSprite = "carpentry_01_44";
		sprite.southSprite = "carpentry_01_46";
		sprite.eastSprite = "carpentry_01_47";
	end
	return sprite;
end

ISBuildMenuDowel.getWoodenDoorSprites = function(player)
	local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_01_48";
		sprite.northSprite = "carpentry_01_49";
		sprite.openSprite = "carpentry_01_50";
		sprite.openNorthSprite = "carpentry_01_51";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_01_52";
		sprite.northSprite = "carpentry_01_53";
		sprite.openSprite = "carpentry_01_54";
		sprite.openNorthSprite = "carpentry_01_55";
	else
		sprite.sprite = "carpentry_01_56";
		sprite.northSprite = "carpentry_01_57";
		sprite.openSprite = "carpentry_01_58";
		sprite.openNorthSprite = "carpentry_01_59";
	end
	return sprite;
end

ISBuildMenuDowel.getWoodenTableSprites = function(player)
	local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_01_60";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_01_61";
	else
		sprite.sprite = "carpentry_01_62";
	end
	return sprite;
end

ISBuildMenuDowel.getSmallBookcaseSprite = function(player)
    local sprite = {};
    sprite.sprite = "furniture_shelving_01_23";
    sprite.northSprite = "furniture_shelving_01_19";
    return sprite;
end

ISBuildMenuDowel.getBookcaseSprite = function(player)
    local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
    local sprite = {};
    if spriteLvl <= 2 then
        sprite.northSprite = "carpentry_02_64";
        sprite.sprite = "carpentry_02_65";
        sprite.eastSprite = "carpentry_02_66";
        sprite.southSprite = "carpentry_02_67";
    else
        sprite.northSprite = "furniture_shelving_01_40";
        sprite.sprite = "furniture_shelving_01_41";
        sprite.eastSprite = "furniture_shelving_01_42";
        sprite.southSprite = "furniture_shelving_01_43";
    end
    return sprite;
end

ISBuildMenuDowel.getSignSprite = function(player)
    local sprite = {};
    sprite.sprite = "constructedobjects_signs_01_27";
    sprite.northSprite = "constructedobjects_signs_01_11";
    return sprite;
end

ISBuildMenuDowel.getDoubleShelveSprite = function(player)
    local sprite = {};
    sprite.sprite = "furniture_shelving_01_2";
    sprite.northSprite = "furniture_shelving_01_1";
    return sprite;
end

ISBuildMenuDowel.getShelveSprite = function(player)
    local sprite = {};
    sprite.sprite = "carpentry_02_68";
    sprite.northSprite = "carpentry_02_69";
    return sprite;
end

ISBuildMenuDowel.getPillarLampSprite = function(player)
    local sprite = {};
    sprite.sprite = "carpentry_02_61";
    sprite.northSprite = "carpentry_02_60";
    sprite.southSprite = "carpentry_02_59";
    sprite.eastSprite = "carpentry_02_62";
    return sprite;
end

ISBuildMenuDowel.getWoodenWallSprites = function(player)
	local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "walls_exterior_wooden_01_44";
		sprite.northSprite = "walls_exterior_wooden_01_45";
	elseif spriteLvl == 2 then
		sprite.sprite = "walls_exterior_wooden_01_40";
		sprite.northSprite = "walls_exterior_wooden_01_41";
	else
		sprite.sprite = "walls_exterior_wooden_01_24";
		sprite.northSprite = "walls_exterior_wooden_01_25";
    end
    if ISBuildMenuDowel.cheat then
        sprite.sprite = "walls_exterior_wooden_01_24";
        sprite.northSprite = "walls_exterior_wooden_01_25";
    end
	sprite.corner = "walls_exterior_wooden_01_27";
	return sprite;
end

ISBuildMenuDowel.getWoodenWindowsFrameSprites = function(player)
	local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "walls_exterior_wooden_01_52";
		sprite.northSprite = "walls_exterior_wooden_01_53";
	elseif spriteLvl == 2 then
		sprite.sprite = "walls_exterior_wooden_01_48";
		sprite.northSprite = "walls_exterior_wooden_01_49";
	else
		sprite.sprite = "walls_exterior_wooden_01_32";
		sprite.northSprite = "walls_exterior_wooden_01_33";
	end
	sprite.corner = "walls_exterior_wooden_01_27";
	return sprite;
end

ISBuildMenuDowel.getWoodenDoorFrameSprites = function(player)
	local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "walls_exterior_wooden_01_54";
		sprite.northSprite = "walls_exterior_wooden_01_55";
	elseif spriteLvl == 2 then
		sprite.sprite = "walls_exterior_wooden_01_50";
		sprite.northSprite = "walls_exterior_wooden_01_51";
	else
		sprite.sprite = "walls_exterior_wooden_01_34";
		sprite.northSprite = "walls_exterior_wooden_01_35";
	end
	sprite.corner = "walls_exterior_wooden_01_27";
	return sprite;
end

ISBuildMenuDowel.getBarCornerSprites = function(player)
	local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.southSprite = "carpentry_02_32";
		sprite.sprite = "carpentry_02_34";
		sprite.northSprite = "carpentry_02_36";
		sprite.eastSprite = "carpentry_02_38";
	elseif spriteLvl == 2 then
		sprite.southSprite = "carpentry_02_24";
		sprite.sprite = "carpentry_02_26";
		sprite.northSprite = "carpentry_02_28";
		sprite.eastSprite = "carpentry_02_30";
	else
		sprite.southSprite = "carpentry_02_16";
		sprite.sprite = "carpentry_02_18";
		sprite.northSprite = "carpentry_02_20";
		sprite.eastSprite = "carpentry_02_22";
	end
	return sprite;
end

ISBuildMenuDowel.getBarElementSprites = function(player)
	local spriteLvl = ISBuildMenuDowel.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.southSprite = "carpentry_02_33";
		sprite.sprite = "carpentry_02_35";
		sprite.northSprite = "carpentry_02_37";
		sprite.eastSprite = "carpentry_02_39";
	elseif spriteLvl == 2 then
		sprite.southSprite = "carpentry_02_25";
		sprite.sprite = "carpentry_02_27";
		sprite.northSprite = "carpentry_02_29";
		sprite.eastSprite = "carpentry_02_31";
	else
		sprite.southSprite = "carpentry_02_17";
		sprite.sprite = "carpentry_02_19";
		sprite.northSprite = "carpentry_02_21";
		sprite.eastSprite = "carpentry_02_23";
	end
	return sprite;
end

ISBuildMenuDowel.getSpriteLvl = function(player)
	-- 0 to 1 wood work xp mean lvl 1 sprite
	if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) <= 1 then
		return 1;
	-- 2 to 3 wood work xp mean lvl 2 sprite
	elseif getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) <= 3 then
		return 2;
	-- 4 to 5 wood work xp mean lvl 3 sprite
	else
		return 3;
	end
end

-- **********************************************
-- **                  OTHER                   **
-- **********************************************

-- Create our toolTip, depending on the required material
ISBuildMenuDowel.canBuild = function(plankNb, WoodDowelNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player)
	-- create a new tooltip
	local tooltip = ISBuildMenuDowel.addToolTipDowel();
	-- add it to our current option
	option.toolTip = tooltip;
	local result = true;
	if ISBuildMenuDowel.cheat then
		return tooltip;
	end
	tooltip.description = "<LINE> <LINE>" .. getText("Tooltip_craft_Needs") .. " : <LINE>";
	-- now we gonna test all the needed material, if we don't have it, they'll be in red into our toolip
	if ISBuildMenuDowel.planks < plankNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Plank") .. " " .. ISBuildMenuDowel.planks .. "/" .. plankNb .. " <LINE>";
		result = false;
	elseif plankNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Plank") .. " " .. plankNb .. " <LINE>";
	end
	if ISBuildMenuDowel.WoodDowel < WoodDowelNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Wooden Dowels") .. " " .. ISBuildMenuDowel.WoodDowel .. "/" .. WoodDowelNb .. " <LINE>";
		result = false;
	elseif WoodDowelNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Wooden Dowels") .. " " .. WoodDowelNb .. " <LINE>";
	end
	if ISBuildMenuDowel.doorknob < doorknobNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Doorknob") .. " " .. ISBuildMenuDowel.doorknob .. "/" .. doorknobNb .. " <LINE>";
		result = false;
	elseif doorknobNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Doorknob") .. " " .. doorknobNb .. " <LINE>";
	end
	if ISBuildMenuDowel.hinge < hingeNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Door Hinge") .. " " .. ISBuildMenuDowel.hinge .. "/" .. hingeNb .. " <LINE>";
		result = false;
	elseif hingeNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Door Hinge") .. " " .. hingeNb .. " <LINE>";
	end
	if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) < carpentrySkill then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getText("IGUI_perks_Carpentry") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill .. " <LINE>";
		result = false;
	elseif carpentrySkill > 0 then
		tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getText("IGUI_perks_Carpentry") .. " " .. carpentrySkill .. " <LINE>";
	end
	if not result then
		option.onSelect = nil;
		option.notAvailable = true;
	end
	return tooltip;
end

ISBuildMenuDowel.addToolTipDowel = function()
	local toolTip = ISToolTip:new();
	toolTip:initialise();
	toolTip:setVisible(false);
	return toolTip;
end

ISBuildMenuDowel.countMaterialDowel = function(player, fullType)
    local inv = getSpecificPlayer(player):getInventory()
    local count = inv:getItemCount(fullType)
    local type = string.split(fullType, "\\.")[2]
    for k,v in pairs(ISBuildMenuDowel.materialOnGround) do
        if k == type then count = count + v end
    end
    return count
end

ISBuildMenuDowel.requireHammerDowel = function(option)
	if not ISBuildMenuDowel.hasHammer and not ISBuildMenuDowel.cheat then
		option.notAvailable = true
		option.onSelect = nil
	end
end

Events.OnFillWorldObjectContextMenu.Add(ISBuildMenuDowel.doBuildMenu);





