package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class ShootAck extends OutgoingMessage {


    public function ShootAck(id:uint, callback:Function) {
        super(id, callback);
    }
    public var time_:int;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeInt(this.time_);
    }

    override public function toString():String {
        return formatToString("SHOOTACK", "time_");
    }
}
}
