package kabam.rotmg.messaging.impl.outgoing.market {
import flash.utils.IDataOutput;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

public class MarketRemove extends OutgoingMessage {


    public function MarketRemove(id:uint, callback:Function) {
        super(id, callback);
    }
    public var id_:int;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeInt(this.id_);
    }
}
}
