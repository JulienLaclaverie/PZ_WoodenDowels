-- ================================================ --
--            Dismantle Wooden Dowels               --
--      Many thanks to Butterbot & Blindcoder       --
-- ================================================ --

require "Context/World/ISContextDisassemble.lua"
local myMod = {}
myMod.ISWMEContextDisassemble = ISWorldMenuElements.ContextDisassemble;
ISWorldMenuElements.ContextDisassemble = function()

    local retVal = myMod.ISWMEContextDisassemble(self);

    -- Overide the disassemble function for the base game and replace it with one that allows custom drops on player made items
    retVal.disassemble = function( _data, _v )
        if _v and _v.moveProps and _v.square and _v.object then

            if _v.moveProps:canScrapObject( _data.player ) and _v.square:getObjects():contains(_v.object) then
                if _v.moveProps:scrapWalkToAndEquip( _data.player ) then

                    -- If the object is player-made it destroys it to get the items used to build it
                    -- If it's not, use the new dismantle system

                    local isObjectThumpable = instanceof(_v.object, "IsoThumpable");
                    local isPlayerMade = false;

                    -- checking if the object is dismantable according to the old dismantle system : in other words, is it player made
                    if isObjectThumpable then
                        isPlayerMade = _v.object:isDismantable();
                    end

                    if isPlayerMade then
                        -- The item HAS been builted by a player, use the old dismantle system
                        ISTimedActionQueue.add(ISDismantleAction:new(_data.player, _v.object));
                    else
                        -- The item HAS NOT been builted by a player, use the new dismantle system
                        ISTimedActionQueue.add(ISMoveablesAction:new(_data.player, _v.square, _v.moveProps, "scrap" ));
                    end

                end
            end
        
        end
    end

    return retVal;

end