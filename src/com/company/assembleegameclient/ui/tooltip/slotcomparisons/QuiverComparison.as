package com.company.assembleegameclient.ui.tooltip.slotcomparisons {
public class QuiverComparison extends SlotComparison {


    public function QuiverComparison() {
        super();
        this.projectileComparison = new GeneralProjectileComparison();
    }
    private var projectileComparison:GeneralProjectileComparison;
    private var condition:XMLList;
    private var otherCondition:XMLList;

    override protected function compareSlots(itemXML:XML, curItemXML:XML):void {
        var htmlStr:String = null;
        var tagStr:String = null;
        var duration:Number = NaN;
        var conditionName:String = null;
        var compositeStr:String = null;
        htmlStr = null;
        this.condition = itemXML.Projectile.ConditionEffect.(text() == "Slowed" || text() == "Paralyzed" || text() == "Dazed");
        this.otherCondition = curItemXML.Projectile.ConditionEffect.(text() == "Slowed" || text() == "Paralyzed" || text() == "Dazed");
        this.projectileComparison.compare(itemXML, curItemXML);
        comparisonText = this.projectileComparison.comparisonText;
        for (tagStr in this.projectileComparison.processedTags) {
            processedTags[tagStr] = true;
        }
        if (this.condition.length() == 1 && this.otherCondition.length() == 1) {
            duration = Number(this.condition[0].@duration);
            conditionName = this.condition.text();
            compositeStr = " " + conditionName + " for " + duration + " secs\n";
            htmlStr = "Shot Effect:\n" + wrapInColoredFont(compositeStr, NO_DIFF_COLOR);
            comparisonText = comparisonText + htmlStr;
            processedTags[this.condition[0].toXMLString()] = htmlStr;
        }
    }
}
}
