package com.company.assembleegameclient.ui.tooltip {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.GameObjectListItem;
import com.company.ui.SimpleText;

import flash.filters.DropShadowFilter;

public class PlayerGroupToolTip extends ToolTip {


    public function PlayerGroupToolTip(players:Vector.<Player>, followMouse:Boolean = true) {
        this.playerPanels_ = new Vector.<GameObjectListItem>();
        super(3552822, 0.5, 16777215, 1, followMouse);
        this.clickMessage_ = new SimpleText(12, 11776947, false, 0, 0);
        this.clickMessage_.text = "(Click to open menu)";
        this.clickMessage_.updateMetrics();
        this.clickMessage_.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(this.clickMessage_);
        this.setPlayers(players);
        if (!followMouse) {
            filters = [];
        }
    }
    public var players_:Vector.<Player> = null;
    private var playerPanels_:Vector.<GameObjectListItem>;
    private var clickMessage_:SimpleText;

    override protected function position():void {
        if (stage == null) {
            return;
        }
        if (stage.mouseX < stage.stageWidth / 2) {
            x = stage.mouseX + 12;
        } else {
            x = stage.mouseX - width - 1;
        }
        if (stage.mouseY < stage.stageHeight / 3) {
            y = stage.mouseY + 12;
        } else {
            y = stage.mouseY - height - 1;
        }
    }

    public function setPlayers(players:Vector.<Player>):void {
        var playerPlanel:GameObjectListItem = null;
        var yVal:int = 0;
        var player:Player = null;
        playerPlanel = null;
        this.clear();
        this.players_ = players.slice();
        if (this.players_ == null || this.players_.length == 0) {
            return;
        }
        yVal = 0;
        for each(player in players) {
            playerPlanel = new GameObjectListItem(11776947, true, player);
            playerPlanel.x = 0;
            playerPlanel.y = yVal;
            addChild(playerPlanel);
            this.playerPanels_.push(playerPlanel);
            yVal = yVal + 32;
        }
        this.clickMessage_.x = width / 2 - this.clickMessage_.width / 2;
        this.clickMessage_.y = yVal;
        draw();
    }

    private function clear():void {
        var playerPanel:GameObjectListItem = null;
        graphics.clear();
        for each(playerPanel in this.playerPanels_) {
            removeChild(playerPanel);
        }
        this.playerPanels_.length = 0;
    }
}
}
