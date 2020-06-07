package com.company.assembleegameclient.parameters {
import com.company.assembleegameclient.ui.options.KeyCodeBox;
import com.company.util.KeyCodes;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.net.SharedObject;
import flash.utils.Dictionary;

import kabam.rotmg.messaging.impl.data.StatData;

public class Parameters {
    public static const ENABLE_ENCRYPTION:Boolean = true;
    public static const PORT:int = 2050;
    public static const FELLOW_GUILD_COLOR:uint = 10944349;
    public static const NAME_CHOSEN_COLOR:uint = 16572160;
    public static const PARTY_MEMBER_COLOR:uint = 16761035;
    public static const PLAYER_ROTATE_SPEED:Number = 0.003;
    public static const BREATH_THRESH:int = 20;
    public static const SERVER_CHAT_NAME:String = "";
    public static const CLIENT_CHAT_NAME:String = "*Client*";
    public static const ERROR_CHAT_NAME:String = "*Error*";
    public static const HELP_CHAT_NAME:String = "*Help*";
    public static const PARTY_CHAT_NAME:String = "*Party*";
    public static const GUILD_CHAT_NAME:String = "*Guild*";
    public static const NAME_CHANGE_PRICE:int = 100;
    public static const GUILD_CREATION_PRICE:int = 1000;
    public static const TUTORIAL_GAMEID:int = -1;
    public static const NEXUS_GAMEID:int = -2;
    public static const NEXUSEXPLANATION_GAMEID:int = -3;
    public static const VAULT_GAMEID:int = -4;
    public static const REALM_GAMEID:int = -5;
    public static const MAPTEST_GAMEID:int = -6;
    public static const GUILDHALL_GAMEID:int = -7;
    public static const MAX_SINK_LEVEL:Number = 18;
    public static const TERMS_OF_USE_URL:String = "https://www.kabam.com/corporate/terms-of-service";
    public static const PRIVACY_POLICY_URL:String = "https://www.kabam.com/corporate/privacy-policy";
    public static const OUTGOING_TOKEN:String = "5E44602511D8A86A416EE138DFAAE2F9";
    public static const INCOMING_TOKEN:String = "1AE3517CCC0486ADEB5DE0D5B5247789";
    public static const RSA_PUBLIC_KEY:String = "-----BEGIN PUBLIC KEY-----\n" + "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDTa2VXtjKzQ8HO2hCRuXZPhezl\n" + "0HcWdO0QxUhz1b+N5xJIXjvPGYpawLnJHgVgjcTI4dqDW9sthI3hEActKdKV6Zm/\n" + "dpPMuCvgEXq1ajOcr8WEX+pDji5kr9ELH0iZjjlvgfzUiOBI6q4ba3SRYiAJFgOo\n" + "e1TCC1sDk+rDZEPcMwIDAQAB\n" + "-----END PUBLIC KEY-----";
    public static var root:DisplayObject;
    public static var DamageCounter:Array = [];
    public static var data:Object = null;
    public static var GPURenderFrame:Boolean = false;
    private static var savedOptions_:SharedObject = null;
    private static var keyNames_:Dictionary = new Dictionary();

    public static function load():void {
        try {
            savedOptions_ = SharedObject.getLocal("OSGameClientOptions", "/");
            data = savedOptions_.data;
        } catch (error:Error) {
            trace("WARNING: unable to save settings");
            data = {};
        }
        setDefaults();
        save();
    }

    public static function save():void {
        try {
            if (savedOptions_ != null) {
                savedOptions_.flush();
            }
        } catch (error:Error) {
        }
    }

    public static function setKey(keyName:String, key:uint):void {
        var otherKeyName:* = null;
        for (otherKeyName in keyNames_) {
            if (data[otherKeyName] == key) {
                data[otherKeyName] = KeyCodes.UNSET;
            }
        }
        data[keyName] = key;
    }

    public static function isGpuRender():Boolean {
        return data.GPURender;
    }

    public static function setDefaults():void {
        setDefaultKey("partyJoinWorld",KeyCodes.UNSET);
        setDefaultKey("partyInviteWorld",KeyCodes.UNSET);
        setDefaultKey("partyChat",KeyCodes.P);
        setDefaultKey("uiQualityToggle", KeyCodes.UNSET);
        setDefaultKey("GPURenderToggle", KeyCodes.UNSET);
        setDefaultKey("reconMarket", KeyCodes.UNSET);
        setDefaultKey("reconGuildHall", KeyCodes.UNSET);
        setDefaultKey("reconMarket", KeyCodes.UNSET);
        setDefaultKey("reconVault", KeyCodes.UNSET);
        setDefaultKey("reconRealm", KeyCodes.UNSET);
        setDefaultKey("reconCloth", KeyCodes.UNSET);
        setDefaultKey("moveLeft", KeyCodes.A);
        setDefaultKey("moveRight", KeyCodes.D);
        setDefaultKey("moveUp", KeyCodes.W);
        setDefaultKey("moveDown", KeyCodes.S);
        setDefaultKey("rotateLeft", KeyCodes.Q);
        setDefaultKey("rotateRight", KeyCodes.E);
        setDefaultKey("useSpecial", KeyCodes.SPACE);
        setDefaultKey("interact", KeyCodes.NUMBER_0);
        setDefaultKey("useInvSlot1", KeyCodes.NUMBER_1);
        setDefaultKey("useInvSlot2", KeyCodes.NUMBER_2);
        setDefaultKey("useInvSlot3", KeyCodes.NUMBER_3);
        setDefaultKey("useInvSlot4", KeyCodes.NUMBER_4);
        setDefaultKey("useInvSlot5", KeyCodes.NUMBER_5);
        setDefaultKey("useInvSlot6", KeyCodes.NUMBER_6);
        setDefaultKey("useInvSlot7", KeyCodes.NUMBER_7);
        setDefaultKey("useInvSlot8", KeyCodes.NUMBER_8);
        setDefaultKey("escapeToNexus", KeyCodes.INSERT);
        setDefaultKey("escapeToNexus2", KeyCodes.F5);
        setDefaultKey("autofireToggle", KeyCodes.I);
        setDefaultKey("scrollChatUp", KeyCodes.PAGE_UP);
        setDefaultKey("scrollChatDown", KeyCodes.PAGE_DOWN);
        setDefaultKey("miniMapZoomOut", KeyCodes.MINUS);
        setDefaultKey("miniMapZoomIn", KeyCodes.EQUAL);
        setDefaultKey("resetToDefaultCameraAngle", KeyCodes.R);
        setDefaultKey("togglePerformanceStats", KeyCodes.UNSET);
        setDefaultKey("options", KeyCodes.O);
        setDefaultKey("toggleCentering", KeyCodes.UNSET);
        setDefaultKey("chat", KeyCodes.ENTER);
        setDefaultKey("chatCommand", KeyCodes.SLASH);
        setDefaultKey("tell", KeyCodes.TAB);
        setDefaultKey("guildChat", KeyCodes.G);
        setDefaultKey("testOne", KeyCodes.J);
        setDefaultKey("testTwo", KeyCodes.K);
        setDefaultKey("useHealthPotion", KeyCodes.F);
        setDefaultKey("useMagicPotion", KeyCodes.V);
        setDefaultKey("switchTabs", KeyCodes.B);
        setDefault("disableAllParticles", false);
        setDefault("uiQuality", false);
        setDefault("FS", true);
        setDefault("disableAllyParticles", true);
        setDefault("hideList", 0);
        setDefault("cursorSelect", "4");
        setDefault("HPBarcolors", true);
        setDefault("showTierTag", true);
        setDefault("reduceParticles", 2);
        setDefault("itemDataOutlines", 0);
        setDefault("toggleBarText", 1);
        setDefault("sellMaxyPots", false);
        setDefault("smartProjectiles", false);
        setDefault("projOutline", true);
        setDefault("dynamicHPcolor", true);
        setDefault("playerObjectType", 782);
        setDefault("playMusic", true);
        setDefault("playSFX", true);
        setDefault("playPewPew", true);
        setDefault("centerOnPlayer", true);
        setDefault("preferredServer", null);
        setDefault("cameraAngle", 7 * Math.PI / 4);
        setDefault("defaultCameraAngle", 7 * Math.PI / 4);
        setDefault("showQuestPortraits", true);
        setDefault("allowRotation", false);
        setDefault("charIdUseMap", {});
        setDefault("drawShadows", true);
        setDefault("textBubbles", true);
        setDefault("showTradePopup", true);
        setDefault("paymentMethod", null);
        setDefault("showGuildInvitePopup", true);
        setDefault("contextualClick", true);
        setDefault("inventorySwap", true);
        setDefault("GPURender", false);
        setDefault("eyeCandyParticles", true);
        setDefault("hpBars", true);
        setDefault("allyShots", true);
        setDefault("allyDamage", true);
        setDefault("allyNotifs", true);
        setDefault("godmode",true);
        setDefaultKey("godmodeKey",KeyCodes.K);
        setDefault("AAException",[3414,3417,3448,3449,3472,3334,5952,2354,2369,3368,3366,3367,3391,3389,3390,5920,2314,3412,3639,3634,2327,1755,24582,24351,24363,24135,24133,24134,24132,24136,3356,3357,3358,3359,3360,3361,3362,3363,3364,2352,28780,28781,28795,28942,28957,28988,28938,29291,29018,29517,24338,29580,29712,6282,29054,29308,29309,29550,29551,29258,29259,29260,29261,29262]);
        setDefault("AAIgnore",[1550,1551,1552,1619,1715,2309,2310,2311,2371,3441,2312,2313,2370,2392,2393,2400,2401,3335,3336,3337,3338,3413,3418,3419,3420,3421,3427,3454,3638,3645,6157,28715,28716,28717,28718,28719,28730,28731,28732,28733,28734,29306,29568,29594,29597,29710,29711,29742,29743,29746,29748,30001,29752,43702,43708,43709,43710,3389,3390,3391,24223,2304,2305,2306,1536,1537,1538,1539,1540]);
        setDefault("AAPriority",[29054,29308,29309,29550,29551,29258,29259,29260,29261,29262,6282,1646]);
        setDefaultKey("AAHotkey",KeyCodes.N);
        setDefaultKey("AAModeHotkey",KeyCodes.M);
        setDefault("AATargetLead",true);
        setDefault("AAOn",false);
        setDefault("aimMode",1);
        setDefault("AAStasis",false);
        setDefault("AAInvincible",false);
        setDefault("AAInvulnerable",false);
        setDefault("AAInvulnerableQuest",false);
        setDefault("AAAddOne",false);
        setDefault("AABoundingDist",20);
        setDefault("projNoClip",true);
        setDefaultKey("projNoClipKey",KeyCodes.Y);
        setDefault("noSink",true);
        setDefault("sMult",1);
        setDefault("sMultDefault",1);
        setDefault("sMultSwitch",1);
        setDefault("autoGodmode",true);
        setDefault("autoSMult",true);
        setDefault("lootPreview",true);
        setDefault("noAAIgnore",false);
        setDefault("panicSMult",false);
        setDefault("disableIdleWatcher",true);
        setDefault("killAura",false);
        setDefault("disableDebuffs",true);
        setDefault("kaRangeSqr",-1);
        setDefault("customVersion", "7.23");
        setDefaultKey("killAuraKey", KeyCodes.UNSET);
        setDefaultKey("tqKey", KeyCodes.UNSET);
        setDefaultKey("tqDeathKey", KeyCodes.UNSET);
        setDefault("tqDeath", false);
        setDefault("customFPS", 60);
        setDefault("vSync", true);
        setDefault("autoDrink", true);
        setDefaultKey("autoDrinkKey", KeyCodes.UNSET);
        setDefault("LNAbility",6);
        setDefault("LNRing",6);
        setDefault("LNWeap", 13);
        setDefault("LNArmor", 14);
        setDefault("autoLoot",true);
        setDefault("NoLoot",["common","tincture"]);
        setDefault("pots2inv",true);
        setDefault("potsMinor",true);
        setDefault("potsMajor",true);
        setDefault("lootHP",true);
        setDefault("lootMP",true);
        setDefault("noClip",true);
        setDefaultKey("noClipKey", KeyCodes.UNSET);
        setDefaultKey("forgePotions", KeyCodes.UNSET);
        setDefault("consumeNormal", true);
        setDefault("forcedSpeed", -1);
        setDefault("permaFollow", "");
        setDefault("autoAcceptInv", true);
        setDefault("ROFHack", true);
    }

    private static function setDefaultKey(keyName:String, key:uint):void {
        if (!data.hasOwnProperty(keyName)) {
            data[keyName] = key;
        }
        keyNames_[keyName] = true;
    }

    private static function setDefault(keyName:String, value:*):void {
        if (!data.hasOwnProperty(keyName)) {
            data[keyName] = value;
        }
    }

    public function Parameters() {
        super();
    }
}
}
