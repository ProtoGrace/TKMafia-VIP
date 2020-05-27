package kabam.rotmg.chat {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.Currency;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import kabam.rotmg.game.model.AddTextLineVO;
import kabam.rotmg.game.signals.AddTextLineSignal;
import kabam.rotmg.market.signals.MemMarketAddSignal;
import kabam.rotmg.market.signals.MemMarketBuySignal;
import kabam.rotmg.market.signals.MemMarketMyOffersSignal;
import kabam.rotmg.market.signals.MemMarketRemoveSignal;
import kabam.rotmg.market.signals.MemMarketSearchSignal;
import kabam.rotmg.messaging.impl.data.ForgeItem;
import kabam.rotmg.messaging.impl.data.MarketData;
import kabam.rotmg.messaging.impl.incoming.market.MarketAddResult;
import kabam.rotmg.messaging.impl.incoming.market.MarketSearchResult;
import kabam.rotmg.ui.model.HUDModel;

public class ParseChatMessageCommand {
    [Inject]
    public var data:String;
    [Inject]
    public var addTextLine:AddTextLineSignal;
    [Inject]
    public var hudModel:HUDModel;

    private var gs:GameSprite = null;

    private const addSignal:MemMarketAddSignal = new MemMarketAddSignal();
    private const removeSignal:MemMarketRemoveSignal = new MemMarketRemoveSignal();
    private const myOffersSignal:MemMarketMyOffersSignal = new MemMarketMyOffersSignal();
    private const buySignal:MemMarketBuySignal = new MemMarketBuySignal();
    private const searchSignal:MemMarketSearchSignal = new MemMarketSearchSignal();

    private var priceChecked:Boolean = false;

    public function ParseChatMessageCommand() {
        super();
        this.searchSignal.add(this.onSearch);
    }

    public function onSearch(result:MarketSearchResult) : void {
        if (!this.priceChecked)
            return;

        if (result.description_ != "") {
            this.addTextLine.dispatch(new AddTextLineVO("Market",
                    "No results found for the item."));
            return;
        }

        var min:int = int.MAX_VALUE;
        for each (var data:MarketData in result.results_)
            if (data.price_ < min)
                min = data.price_;
        this.addTextLine.dispatch(new AddTextLineVO("Market",
                "Lowest price: " + min + " Fame"));
        this.priceChecked = false;
    }

    public function execute():void {
        var classCount:Dictionary = null;
        var loops:uint = 0;
        var go:GameObject = null;
        var classList:String = null;
        var players:Vector.<int> = null;
        var objType:int = 0;
        this.gs = this.hudModel.gameSprite;
        switch(this.data) {
            case "/c":
            case "/classes":
            case "/class":
                classCount = new Dictionary();
                loops = 0;
                go = null;
                classList = "";
                players = new Vector.<int>();
                for each(go in this.gs.map.goDict_) {
                    if(go.props_.isPlayer_) {
                        classCount[go.objectType_] = classCount[go.objectType_] != undefined?classCount[go.objectType_] + 1:1;
                        if(players.indexOf(go.objectType_) == -1) {
                            players.push(go.objectType_);
                        }
                        loops++;
                    }
                }
                for each(objType in players) {
                    classList = classList + (" " + ObjectLibrary.typeToDisplayId_[objType] + ": " + classCount[objType]);
                }
                this.addTextLine.dispatch(new AddTextLineVO("","Classes online (" + loops + "):" + classList));
                break;
            case "/mscale":
                this.addTextLine.dispatch(new AddTextLineVO("*Help*","Map Scale: " + Parameters.data.mscale + " - Usage: /mscale <any decimal number>."));
                return;
            case "/pos":
                this.addTextLine.dispatch(new AddTextLineVO("*Help*","Your position: x = " + this.gs.map.player_.x_ + ", y = " + this.gs.map.player_.y_));
                return;
            case "/follow":
                Parameters.data.permaFollow = "";
                Parameters.save();
                this.gs.map.player_.followTarget = null;
                this.gs.map.player_.levelUpEffect("Stopped following");
                return;
            case "/speed":
                Parameters.data.forcedSpeed = -1;
                Parameters.save();
                this.addTextLine.dispatch(new AddTextLineVO("*Help*",
                        "Forced speed disabled"));
                return;
            case "/tq":
                try {
                    var gameObj:GameObject = this.gs.map.goDict_[this.gs.map.quest_.objectId_];
                    var yOffset:int = gameObj.getName() == "Hermit God" ? 5 : 0;
                    this.gs.map.player_.x_ = gameObj.x_;
                    this.gs.map.player_.y_ = gameObj.y_ + yOffset;
                    this.gs.map.player_.tq = true;
                }
                catch(e:Error) {
                    this.addTextLine.dispatch(new AddTextLineVO("*Help*","No quest entities found."));
                }
                break;
            default:
                if(!this.regexCommands(this.data)) {
                    this.gs.gsc_.playerText(this.data);
                }
        }
    }

    private function levenshtein(string_1:String, string_2:String):int {
        var matrix:Array = new Array();
        var dist:int;
        for (var i:int=0; i<=string_1.length; i++) {
            matrix[i] = new Array();
            for (var j:int = 0; j <= string_2.length; j++) {
                if (i!=0) {
                    matrix[i].push(0);
                } else {
                    matrix[i].push(j);
                }
            }
            matrix[i][0]=i;
        }
        for (i = 1; i <= string_1.length; i++) {
            for (j = 1; j <= string_2.length; j++) {
                if (string_1.charAt(i-1) == string_2.charAt(j-1)) {
                    dist = 0;
                } else {
                    dist = 1;
                }
                matrix[i][j] = Math.min(matrix[i-1][j]+1,matrix[i][j-1]+1,matrix[i-1][j-1]+dist);
            }
        }
        return matrix[string_1.length][string_2.length];
    }

    private function fixedName(input:String):GameObject {
        var dist2:int = int.MAX_VALUE;
        var temp:int;
        var go_:GameObject;
        var target:GameObject;
        for each(go_ in hudModel.gameSprite.map.goDict_) {
            if (!(go_ is Player)) {
                continue;
            }
            temp = levenshtein(input, go_.name_.toLowerCase().substr(0,input.length));
            if (temp < dist2) {
                dist2 = temp;
                target = go_;
            }
            if (dist2 == 0) {
                break;
            }
        }
        return target;
    }

    private function regexCommands(text:String) : Boolean {
        var match:Array;
        var _loc5_:int = 0;
        var _loc6_:int = 0;
        var _loc2_:DisplayObject = Parameters.root;
        text = text.toLowerCase();
        match = text.match("^/follow (\\w+)$");
        if (match != null) {
            var target:GameObject = fixedName(match[1]);
            Parameters.data.permaFollow = target.name_;
            Parameters.save();
            this.gs.map.player_.levelUpEffect("Following " + target.name_);
            this.gs.gsc_.teleport(target.name_);
            this.gs.map.player_.followTarget = target;
            return true;
        }
        match = text.match("^/mscale (\\d*\\.*\\d+)$");
        if(match != null) {
            Parameters.data.mscale = match[1];
            Parameters.save();
            _loc2_.dispatchEvent(new Event(Event.RESIZE));
            this.addTextLine.dispatch(new AddTextLineVO("*Help*","Map Scale: " + match[1]));
            return true;
        }
        match = text.match("^/smult (\\d*\\.*\\d+)$");
        if(match != null) {
            Parameters.data.sMult = match[1];
            Parameters.save();
            this.addTextLine.dispatch(new AddTextLineVO("*Help*","Speed Multiplier: " + match[1]));
            return true;
        }
        match = text.match("^/smult default (\\d*\\.*\\d+)$");
        if(match != null) {
            Parameters.data.sMultDefault = match[1];
            Parameters.save();
            this.addTextLine.dispatch(new AddTextLineVO("*Help*","Default Speed Multiplier: " + match[1]));
            return true;
        }
        match = text.match("^/smult switch (\\d*\\.*\\d+)$");
        if(match != null) {
            Parameters.data.sMultSwitch = match[1];
            Parameters.save();
            this.addTextLine.dispatch(new AddTextLineVO("*Help*","Switch Speed Multiplier: " + match[1]));
            return true;
        }
        match = text.match("^/speed (\\d+)$");
        if (match != null) {
            Parameters.data.forcedSpeed = match[1];
            Parameters.save();
            this.addTextLine.dispatch(new AddTextLineVO("*Help*",
                    "Forced speed to " + match[1]));
            return true;
        }
        match = text.match("^/tppos (\\d+) (\\d+)$");
        if(match != null) {
            this.gs.map.player_.x_ = match[1];
            this.gs.map.player_.y_ = match[2];
            this.gs.map.player_.tq = true;
            this.addTextLine.dispatch(new AddTextLineVO("*Help*",
                    "Teleported to x = " + match[1] + ", y = " + match[2]));
            return true;
        }
        match = text.split(' ');
        if (text.indexOf("/sell") != -1) {
            var items:Vector.<int> = new Vector.<int>();
            for each (var item:int in (match[1] as String).split(','))
                items.push(item + 3);
            var price:int = match[2];
            this.gs.gsc_.marketAdd(items, price, Currency.FAME, 24);
            return true;
        }
        if (text.indexOf("/pc") != -1 && text.indexOf("/pclose") == -1) {
            this.priceChecked = true;
            var itemType:int = -1;
            if (!isNaN(parseInt(match[1])))
                itemType = this.gs.map.player_.equipment_[parseInt(match[1]) + 3];
            else {
                for each (var xml:XML in ObjectLibrary.xmlLibrary_)
                    if (xml.@id.toLowerCase() == text.substr(4).toLowerCase())
                        itemType = xml.@type;
            }

            if (itemType == -1)
                this.addTextLine.dispatch(new AddTextLineVO("Market",
                        "Item not found within game files."));
            else
                this.gs.gsc_.marketSearch(itemType);
            return true;
        }
        var _loc4_:Boolean = false;
        match = text.match("^/aig (\\d+)$");
        if(match != null) {
            for each(_loc5_ in Parameters.data.AAIgnore) {
                if(_loc5_ == match[1]) {
                    _loc4_ = true;
                    this.addTextLine.dispatch(new AddTextLineVO("*Help*",match[1] + " (" + (ObjectLibrary.xmlLibrary_[match[1]] != undefined?ObjectLibrary.xmlLibrary_[match[1]].@id:"") + ") already exists in ignore list."));
                    break;
                }
            }
            if (!_loc4_) {
                if(ObjectLibrary.xmlLibrary_[match[1]] != undefined) {
                    Parameters.data.AAIgnore.push(match[1]);
                    this.addTextLine.dispatch(new AddTextLineVO("*Help*","Added " + match[1] + " (" + ObjectLibrary.xmlLibrary_[match[1]].@id + ") to ignore list."));
                } else {
                    this.addTextLine.dispatch(new AddTextLineVO("*Help*","No mob has the type " + match[1] + "."));
                }
            }
            Parameters.save();
            return true;
        }
        match = text.match("^/rig (\\d+)$");
        if(match != null) {
            _loc6_ = 0;
            while(_loc6_ < Parameters.data.AAIgnore.length) {
                if(Parameters.data.AAIgnore[_loc6_] == match[1]) {
                    _loc4_ = true;
                    Parameters.data.AAIgnore.splice(_loc6_,1);
                    this.addTextLine.dispatch(new AddTextLineVO("*Help*",match[1] + " (" + (ObjectLibrary.xmlLibrary_[match[1]] != undefined?ObjectLibrary.xmlLibrary_[match[1]].@id:"") + ") removed from ignore list."));
                    break;
                }
                _loc6_++;
            }
            if(_loc4_ == false) {
                if(ObjectLibrary.xmlLibrary_[match[1]] != undefined) {
                    this.addTextLine.dispatch(new AddTextLineVO("*Help*",match[1] + " (" + ObjectLibrary.xmlLibrary_[match[1]].@id + ") not found in ignore list."));
                } else {
                    this.addTextLine.dispatch(new AddTextLineVO("*Help*",match[1] + " not found in ignore list."));
                }
            }
            Parameters.save();
            return true;
        }
        return false;
    }
}
}
