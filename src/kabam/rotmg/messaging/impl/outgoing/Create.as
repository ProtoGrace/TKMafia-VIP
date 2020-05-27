package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class Create extends OutgoingMessage {


    public function Create(id:uint, callback:Function) {
        super(id, callback);
    }
    public var classType:int;
    public var skinType:int;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeShort(this.classType);
        data.writeShort(this.skinType);
    }

    override public function toString():String {
        return formatToString("CREATE", "classType");
    }
}
}
