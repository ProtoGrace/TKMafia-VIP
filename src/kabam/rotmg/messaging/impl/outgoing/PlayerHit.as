package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class PlayerHit extends OutgoingMessage {


    public function PlayerHit(id:uint, callback:Function) {
        super(id, callback);
    }
    public var bulletId_:uint;
    public var objectId_:int;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeByte(this.bulletId_);
        data.writeInt(this.objectId_);
    }

    override public function toString():String {
        return formatToString("PLAYERHIT", "bulletId_", "objectId_");
    }
}
}
