package com.company.assembleegameclient.ui.panels {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.TextBox;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import org.osflash.signals.Signal;

public class CharacterChangerPanel extends ButtonPanel {


    public function CharacterChangerPanel(gs:GameSprite) {
        this.triggered = new Signal();
        super(gs, "Change Characters", "Change");
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }
    public var triggered:Signal;

    override protected function onAddedToStage(event:Event):void {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
    }

    override protected function onRemovedFromStage(event:Event):void {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
    }

    override protected function onButtonClick(event:MouseEvent):void {
        this.gs_.closed.dispatch();
    }

    override protected function onKeyDown(event:KeyboardEvent):void {
        if (event.keyCode == Parameters.data.interact && !TextBox.isInputtingText) {
            this.gs_.closed.dispatch();
        }
    }
}
}
