package kabam.rotmg.messaging.impl.incoming {
import flash.utils.IDataInput;

public class Ping extends IncomingMessage {


    public function Ping(id:uint, callback:Function) {
        super(id, callback);
    }
    public var serial_:int;

    override public function parseFromInput(data:IDataInput):void {
        this.serial_ = data.readInt();
    }

    override public function toString():String {
        return formatToString("PING", "serial_");
    }
}
}
