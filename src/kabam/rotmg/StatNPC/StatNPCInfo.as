package kabam.rotmg.StatNPC {
import com.company.assembleegameclient.game.GameSprite;
import com.company.ui.SimpleText;

import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import io.decagames.rotmg.ui.buttons.SliceScalingButton;
import io.decagames.rotmg.ui.popups.header.PopupHeader;
import io.decagames.rotmg.ui.popups.modal.ModalPopup;
import io.decagames.rotmg.ui.texture.TextureParser;

import org.osflash.signals.Signal;

public class StatNPCInfo extends ModalPopup {


    public function StatNPCInfo(arg1:GameSprite) {
        this.quit = new Signal();
        super(350, 150, "Info");
        this.gs = arg1;
        this.quitButton = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI", "close_button"));
        this.header.addButton(this.quitButton, PopupHeader.RIGHT_BUTTON);
        this.quitButton.addEventListener(MouseEvent.CLICK, this.onClose);
        this.x = 120;
        this.y = 75;
        this.text = new SimpleText(20, 16777215, false, 350, 150);
        this.text.wordWrap = true;
        this.text.setText("Set Base Stat is a Stat that is directly from your account. What this does is increase what is worth this to your initial stats. Example, Your Attack is 27, and your Set Base Stat is 5, this adds to your attack and will result in Attack: 33 (+5).");
        this.text.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(this.text);
    }
    var gs:GameSprite;
    var text:SimpleText;
    var quitButton:SliceScalingButton;
    var quit:Signal;

    private function onClose(event:MouseEvent):void {
        this.quit.dispatch();
    }
}
}
