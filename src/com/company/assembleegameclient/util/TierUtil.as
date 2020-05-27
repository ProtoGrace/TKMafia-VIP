package com.company.assembleegameclient.util {
import com.company.assembleegameclient.misc.DefaultLabelFormat;
import com.company.assembleegameclient.misc.UILabel;
import com.company.assembleegameclient.ui.tooltip.TooltipHelper;

public class TierUtil {


    public static function getTierTag(xml:XML, size:int = 16):UILabel {
        var label:UILabel = null;
        var color:Number = NaN;
        var tierTag:String = null;
        var isnotpet:* = !isPet(xml);
        var consumable:* = !xml.hasOwnProperty("Consumable");
        var noTierTag:* = !xml.hasOwnProperty("NoTierTag");
        var treasure:* = !xml.hasOwnProperty("Treasure");
        var petFood:* = !xml.hasOwnProperty("PetFood");
        var tier:Boolean = xml.hasOwnProperty("Tier");
        if (isnotpet && consumable && treasure && petFood && noTierTag) {
            label = new UILabel();
            if (tier) {
                color = 16777215;
                tierTag = "T" + xml.Tier;
            } else if (xml.hasOwnProperty("@setType")) {
                color = TooltipHelper.SET_COLOR;
                tierTag = "ST";
            } else if (xml.hasOwnProperty("SetTier")) {
                color = TooltipHelper.SET_COLOR;
                tierTag = "ST";
            } else if (xml.hasOwnProperty("SNormal")) {
                color = TooltipHelper.S;
                tierTag = "UT";
            } else if (xml.hasOwnProperty("SPlus")) {
                color = TooltipHelper.SPlus;
                tierTag = "UT";
            } else if(xml.hasOwnProperty("Legendary")) {
                color = 15446033;
                tierTag = "LG";
            } else if(xml.hasOwnProperty("Revenge") || xml.hasOwnProperty("Mythical")) {
                color = 13571123;
                tierTag = "MT";
            } else if (xml.hasOwnProperty("Eternal")) {
                color = 10026904;
                tierTag = "ET";
            } else {
                color = TooltipHelper.UNTIERED_COLOR;
                tierTag = "UT";
            }
            label.text = tierTag;
            DefaultLabelFormat.tierLevelLabel(label, size, color);
            return label;
        }
        return null;
    }

    public static function isPet(itemDataXML:XML):Boolean {
        var activateTags:XMLList = null;
        activateTags = itemDataXML.Activate.(text() == "PermaPet");
        return activateTags.length() >= 1;
    }

    public function TierUtil() {
        super();
    }
}
}
