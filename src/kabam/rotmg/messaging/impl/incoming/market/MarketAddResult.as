package kabam.rotmg.messaging.impl.incoming.market {
import flash.utils.IDataInput;

import kabam.rotmg.messaging.impl.incoming.IncomingMessage;

public class MarketAddResult extends IncomingMessage {


    public function MarketAddResult(id:uint, callback:Function) {
        super(id, callback);
    }
    public var code:int;
    public var description_:String;

    override public function parseFromInput(data:IDataInput):void {
        this.code = data.readInt();
        this.description_ = data.readUTF();
    }
}
}
