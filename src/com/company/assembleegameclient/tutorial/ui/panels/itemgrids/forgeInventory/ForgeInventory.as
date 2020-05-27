package com.company.assembleegameclient.ui.panels.itemgrids.forgeInventory {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.ui.Slot;
import com.company.util.MoreColorUtil;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;

import kabam.rotmg.constants.GeneralConstants;
import kabam.rotmg.messaging.impl.data.ForgeItem;

public class ForgeInventory extends Sprite {

    private static const NO_CUT:Array = [0, 0, 0, 0];

    private static const cuts:Array = [[1, 0, 0, 1], NO_CUT, NO_CUT, [0, 1, 1, 0], [1, 0, 0, 0], NO_CUT, NO_CUT, [0, 1, 0, 0], [0, 0, 0, 1], NO_CUT, NO_CUT, [0, 0, 1, 0]];

    public function ForgeInventory(gs:GameSprite, items:Vector.<int>, backPack:Boolean) {
        var inventory:ForgeSlot = null;
        var itemXML:XML = null;
        var backpackInv:ForgeSlot = null;
        var itembackpackXML:XML = null;
        this.slotId = new Vector.<int>();
        this.slots_ = new Vector.<ForgeSlot>();
        super();
        this.gs_ = gs;
        for (var i:int = 4; i < GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS; i++) {
            inventory = new ForgeSlot(items[i], cuts, i);
            inventory.x = int(i % 4) * (Slot.WIDTH + 4);
            inventory.y = int(i / 4) * (Slot.HEIGHT + 4) + 46;
            itemXML = ObjectLibrary.xmlLibrary_[items[i]];
            if (itemXML != null) {
                inventory.addEventListener(MouseEvent.MOUSE_DOWN, this.onSlotClick);
            } else {
                inventory.transform.colorTransform = MoreColorUtil.veryDarkCT;
            }
            this.slots_.push(inventory);
            addChild(inventory);
            if (backPack) {
                backpackInv = new ForgeSlot(items[i + 8], cuts, i);
                backpackInv.x = int(i % 4) * (Slot.WIDTH + 4);
                backpackInv.y = inventory.y + 100;
                itembackpackXML = ObjectLibrary.xmlLibrary_[items[i + 8]];
                if (itembackpackXML != null) {
                    backpackInv.addEventListener(MouseEvent.MOUSE_DOWN, this.onSlotClick);
                } else {
                    backpackInv.transform.colorTransform = MoreColorUtil.veryDarkCT;
                }
                this.slots_.push(backpackInv);
                addChild(backpackInv);
            }
            this.slotId.push(i);
            if (backPack) {
                this.slotId.push(i + 8);
            }
        }
    }
    public var gs_:GameSprite;
    public var slots_:Vector.<ForgeSlot>;
    public var slotId:Vector.<int>;
    public var boxInv:SliceScalingBitmap;
    public var boxBackpack:SliceScalingBitmap;

    public function getIncludedItems():Vector.<ForgeItem> {
        var forgeItem:ForgeItem = null;
        var included:Vector.<ForgeItem> = new Vector.<ForgeItem>();
        for (var i:int = 0; i < this.slots_.length; i++) {
            if (this.slots_[i].included_) {
                forgeItem = new ForgeItem();
                forgeItem.objectType_ = this.slots_[i].item_;
                forgeItem.slotId_ = this.slotId[i];
                forgeItem.included_ = this.slots_[i].included_;
                included.push(forgeItem);
            }
        }
        return included;
    }

    private function onSlotClick(event:MouseEvent):void {
        var slot:ForgeSlot = event.currentTarget as ForgeSlot;
        slot.setIncluded(!slot.included_);
        dispatchEvent(new Event(Event.CHANGE));
    }
}
}
