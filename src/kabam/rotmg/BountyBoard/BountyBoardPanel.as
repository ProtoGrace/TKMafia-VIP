package kabam.rotmg.BountyBoard {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.TextBox;
import com.company.assembleegameclient.ui.panels.ButtonPanel;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

public class BountyBoardPanel extends ButtonPanel {


    public function BountyBoardPanel(gs:GameSprite) {
        super(gs, "Guild Bounty Board", "Begin a Bounty");
    }

    override protected function onButtonClick(evt:MouseEvent):void {
        this.openDialog.dispatch(new BountyBoardModal(this.gs_));
    }

    override protected function onKeyDown(evt:KeyboardEvent):void {
        if (evt.keyCode == Parameters.data.interact && !TextBox.isInputtingText) {
            this.openDialog.dispatch(new BountyBoardModal(this.gs_));
        }
    }
}
}
