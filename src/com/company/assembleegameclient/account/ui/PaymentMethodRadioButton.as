package com.company.assembleegameclient.account.ui {
import com.company.assembleegameclient.account.ui.components.Selectable;
import com.company.ui.SimpleText;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import kabam.rotmg.util.components.RadioButton;

public class PaymentMethodRadioButton extends Sprite implements Selectable {

    public static const HEIGHT:int = 28;

    public function PaymentMethodRadioButton(label:String) {
        super();
        this.label = label;
        this.makeRadioButton();
        this.makeLabelText();
        addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
    }
    private var label:String;
    private var text:SimpleText;
    private var button:RadioButton;

    public function getValue():String {
        return this.label;
    }

    public function setSelected(selected:Boolean):void {
        this.button.setSelected(selected);
    }

    private function makeRadioButton():void {
        this.button = new RadioButton();
        addChild(this.button);
    }

    private function makeLabelText():void {
        this.text = new SimpleText(18, 16777215, false, 0, 0);
        this.text.setBold(true);
        this.text.text = this.label;
        this.text.updateMetrics();
        this.text.filters = [new DropShadowFilter(0, 0, 0)];
        this.text.x = HEIGHT + 8;
        addChild(this.text);
    }

    private function onMouseOver(event:MouseEvent):void {
        this.text.setColor(16768133);
    }

    private function onRollOut(event:MouseEvent):void {
        this.text.setColor(16777215);
    }
}
}
