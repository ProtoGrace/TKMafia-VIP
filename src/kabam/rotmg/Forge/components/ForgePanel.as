package kabam.rotmg.Forge.components {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.TextBox;
import com.company.assembleegameclient.ui.panels.ButtonPanel;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import kabam.rotmg.Forge.ForgeModal;

public class ForgePanel extends ButtonPanel {


    public function ForgePanel(arg1:GameSprite, gm:GameObject) {
        super(arg1, "Forge", "Start Forging");
        this.gm_ = gm;
    }
    private var gm_:GameObject;

    override protected function onButtonClick(evt:MouseEvent):void {
        this.openDialogNoModal.dispatch(new ForgeModal(this.gs_, this.gm_));
        trace(this.gm_);
    }

    override protected function onKeyDown(evt:KeyboardEvent):void {
        if (evt.keyCode == Parameters.data.interact && !TextBox.isInputtingText) {
            this.openDialogNoModal.dispatch(new ForgeModal(this.gs_, this.gm_));
        }
    }
}
}
