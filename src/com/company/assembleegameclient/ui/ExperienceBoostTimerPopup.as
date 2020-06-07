package com.company.assembleegameclient.ui {
import com.company.assembleegameclient.ui.components.TimerDisplay;
import com.company.ui.SimpleText;

import flash.display.Sprite;
import flash.filters.DropShadowFilter;

public class ExperienceBoostTimerPopup extends Sprite {


    public function ExperienceBoostTimerPopup() {
        super();
        this.textField = this.returnTimerTextField();
        this.textField.x = 5;
        this.timerDisplay = new TimerDisplay(this.textField);
        addChild(this.timerDisplay);
        this.timerDisplay.update(100000);
        graphics.lineStyle(2, 16777215);
        graphics.beginFill(3552822);
        graphics.drawRoundRect(0, 0, 150, 25, 10);
        filters = [new DropShadowFilter(0, 0, 0, 1, 16, 16, 1)];
    }
    private var timerDisplay:TimerDisplay;
    private var textField:SimpleText;

    public function update(_arg1:Number):void {
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
}
}
