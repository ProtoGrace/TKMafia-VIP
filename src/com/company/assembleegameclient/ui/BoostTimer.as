package com.company.assembleegameclient.ui {
import com.company.assembleegameclient.ui.components.TimerDisplay;
import com.company.ui.SimpleText;

import flash.display.Sprite;
import flash.filters.DropShadowFilter;

import org.osflash.signals.Signal;

public class BoostTimer extends Sprite {


    public function BoostTimer() {
        super();
        this.createLabelTextField();
        this.textChanged = this.labelTextField.textChanged;
        this.labelTextField.x = 0;
        this.labelTextField.y = 0;
        var _local1:SimpleText = this.returnTimerTextField();
        this.timerDisplay = new TimerDisplay(_local1);
        this.timerDisplay.x = 0;
        this.timerDisplay.y = 20;
        addChild(this.timerDisplay);
        addChild(this.labelTextField);
    }
    public var textChanged:Signal;
    private var labelTextField:SimpleText;
    private var timerDisplay:TimerDisplay;

    public function setLabelBuilder(_arg1:String):void {
        this.labelTextField.setText(_arg1);
    }

    public function setTime(_arg1:Number):void {
        this.timerDisplay.update(_arg1);
    }

    private function returnTimerTextField():SimpleText {
        var _local1:SimpleText = null;
        _local1 = new SimpleText(16, 16777103);
        _local1.setBold(true);
        _local1.multiline = true;
        _local1.mouseEnabled = true;
        _local1.filters = [new DropShadowFilter(0, 0, 0)];
        return _local1;
    }

    private function createLabelTextField():void {
        this.labelTextField = new SimpleText(16, 16777215);
        this.labelTextField.multiline = true;
        this.labelTextField.mouseEnabled = true;
        this.labelTextField.filters = [new DropShadowFilter(0, 0, 0)];
    }
}
}
