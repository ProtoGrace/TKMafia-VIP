package com.company.assembleegameclient.ui.panels {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.TextBox;
import com.company.assembleegameclient.ui.board.GuildBoardWindow;
import com.company.assembleegameclient.util.GuildUtil;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

public class GuildBoardPanel extends ButtonPanel {


    public function GuildBoardPanel(gs:GameSprite) {
        super(gs, "Guild Board", "View");
    }

    override protected function onKeyDown(_arg1:KeyboardEvent):void {
        var p:Player = null;
        if (_arg1.keyCode == Parameters.data.interact && !TextBox.isInputtingText) {
            p = gs_.map.player_;
            if (p == null) {
                return;
            }
            this.openDialog.dispatch(new GuildBoardWindow(p.guildRank_ >= GuildUtil.OFFICER));
        }
    }

    override protected function onButtonClick(event:MouseEvent):void {
        var p:Player = gs_.map.player_;
        if (p == null) {
            return;
        }
        this.openDialog.dispatch(new GuildBoardWindow(p.guildRank_ >= GuildUtil.OFFICER));
    }
}
}
