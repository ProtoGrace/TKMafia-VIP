package com.company.assembleegameclient.mapeditor {
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.account.ui.TextInputField;

import flash.events.Event;
import flash.events.MouseEvent;

public class EditTilePropertiesFrame extends Frame {


    public function EditTilePropertiesFrame(oldName:String) {
        super("Tile properties", "Cancel", "Save", 288);
        this.objectName_ = new TextInputField("Object Name", false, "");
        if (oldName != null) {
            this.objectName_.inputText_.text = oldName;
        }
        addTextInputField(this.objectName_);
        leftButton_.addEventListener(MouseEvent.CLICK, this.onCancel);
        rightButton_.addEventListener(MouseEvent.CLICK, this.onDone);
    }
    public var objectName_:TextInputField;

    private function onCancel(event:MouseEvent):void {
        dispatchEvent(new Event(Event.CANCEL));
    }

    private function onDone(event:MouseEvent):void {
        dispatchEvent(new Event(Event.COMPLETE));
    }
}
}
