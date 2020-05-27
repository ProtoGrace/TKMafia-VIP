package kabam.rotmg.messaging.impl.incoming {
import flash.utils.IDataInput;

public class TradeRequested extends IncomingMessage {


    public function TradeRequested(id:uint, callback:Function) {
        super(id, callback);
    }
    public var name_:String;

    override public function parseFromInput(data:IDataInput):void {
        this.name_ = data.readUTF();
    }

    override public function toString():String {
        return formatToString("TRADEREQUESTED", "name_");
    }
}
}
