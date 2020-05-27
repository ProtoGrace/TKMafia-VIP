package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class Load extends OutgoingMessage {


    public function Load(id:uint, callback:Function) {
        super(id, callback);
    }
    public var charId_:int;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeInt(this.charId_);
    }

    override public function toString():String {
        return formatToString("LOAD", "charId_");
    }
}
}
