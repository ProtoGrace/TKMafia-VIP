package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class GotoAck extends OutgoingMessage {


    public function GotoAck(id:uint, callback:Function) {
        super(id, callback);
    }
    public var time_:int;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeInt(this.time_);
    }

    override public function toString():String {
        return formatToString("GOTOACK", "time_");
    }
}
}
