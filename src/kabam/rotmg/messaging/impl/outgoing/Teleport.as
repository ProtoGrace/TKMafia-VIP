package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class Teleport extends OutgoingMessage {


    public function Teleport(id:uint, callback:Function) {
        super(id, callback);
    }
    public var objectId_:int;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeInt(this.objectId_);
    }

    override public function toString():String {
        return formatToString("TELEPORT", "objectId_");
    }
}
}
