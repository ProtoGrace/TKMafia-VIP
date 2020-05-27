package com.company.assembleegameclient.ui.tooltip {
import flash.utils.Dictionary;

public class SlotComparisonResult {


    public function SlotComparisonResult() {
        super();
        this.text = "";
        this.processedTags = new Dictionary(true);
        this.processedActivateOnEquipTags = new Dictionary(true);
    }
    public var text:String;
    public var processedTags:Dictionary;
    public var processedActivateOnEquipTags:Dictionary;
}
}
