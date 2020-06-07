package com.company.assembleegameclient.ui.tooltip {
public class TooltipHelper {

    public static const BETTER_COLOR:String = "#00ff00";

    public static const WORSE_COLOR:String = "#ff0000";

    public static const NO_DIFF_COLOR:String = "#FFFF8F";

    public static const S:uint = 248572;

    public static const SPlus:uint = 16564739;

    public static const WIS_BONUS_COLOR:uint = 4219875;

    public static const UNTIERED_COLOR:uint = 9055202;

    public static const SET_COLOR:uint = 13001;

    public static const LEGENDARY_COLOR:uint = 16764006;

    public static const HOLDABLE_COLOR:uint = 5373730;

    public static const HEROIC_COLOR:uint = 45823;

    public static const TIER_COLOR:uint = 16777215;

    public static const REVENGE_COLOR:uint = 15269888;

    public static const ETERNAL_COLOR:uint = 10026904;

    public static function wrapInFontTag(text:String, color:String):String {
        var tagStr:String = "<font color=\"" + color + "\">" + text + "</font>";
        return tagStr;
    }

    public static function getFormattedRangeString(range:Number):String {
        var decimalPart:Number = range - int(range);
        return int(decimalPart * 10) == 0 ? int(range).toString() : range.toFixed(1);
    }

    public static function getTextColor(difference:Number):String {
        if (difference < 0) {
            return WORSE_COLOR;
        }
        if (difference > 0) {
            return BETTER_COLOR;
        }
        return NO_DIFF_COLOR;
    }

    public function TooltipHelper() {
        super();
    }
}
}
