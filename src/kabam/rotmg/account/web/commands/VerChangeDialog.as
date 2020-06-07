package kabam.rotmg.account.web.commands {
import com.company.ui.SimpleText;

import kabam.rotmg.account.web.view.*;

import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.parameters.Parameters;
import com.gskinner.motion.GTween;

import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import org.osflash.signals.Signal;

public class VerChangeDialog extends Frame {
    public function VerChangeDialog() {
        super("Change version", "Cancel", "Set", 330);
        this.addFade();
        this.makeUIElements();
        this.close = new Signal();
    }
    public var close:Signal;
    private var verInput:LabeledField;
    private var infoText:SimpleText;
    private var fadeIn_:Boolean;

    private function makeUIElements():void {
        this.verInput = new LabeledField("Version", false, 275);
        this.infoText = new SimpleText(12, 11776747);
        this.infoText.setBold(true);
        this.infoText.setText("Set your custom version in here, in case TK updates.\n" +
                "Type in the format of ex.: '7.23', without the quotes.\n" +
                "Current custom version: " + Parameters.data.customVersion);
        this.infoText.updateMetrics();
        this.infoText.filters = [new DropShadowFilter(0, 0, 0)];
        addComponent(this.infoText, 14);
        addSpace(9);
        addLabeledField(this.verInput);
        rightButton_.addEventListener(MouseEvent.CLICK, this.onSet);
        leftButton_.addEventListener(MouseEvent.CLICK, this.onCancel);
        if (this.fadeIn_) {
            new GTween(this, 0.1, {"alpha": 1});
        }
    }

    private function addFade():void {
        this.fadeIn_ = true;
        alpha = 0;
    }

    private function onCancel(event:MouseEvent):void {
        this.close.dispatch();
    }

    private function onSet(event:MouseEvent):void {
        Parameters.data.customVersion = this.verInput.text();
        this.close.dispatch();
    }
}
}
