package kabam.rotmg.messaging.impl.outgoing.market {
import flash.utils.IDataOutput;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

public class MarketSearch extends OutgoingMessage {


    public function MarketSearch(id:uint, callback:Function) {
        super(id, callback);
    }
    public var itemType_:int;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeInt(this.itemType_);
    }
}
}
