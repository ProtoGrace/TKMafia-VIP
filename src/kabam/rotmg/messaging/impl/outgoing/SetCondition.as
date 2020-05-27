package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class SetCondition extends OutgoingMessage {


    public function SetCondition(id:uint, callback:Function) {
        super(id, callback);
    }
    public var conditionEffect_:uint;
    public var conditionDuration_:Number;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeByte(this.conditionEffect_);
        data.writeFloat(this.conditionDuration_);
    }

    override public function toString():String {
        return formatToString("SETCONDITION", "conditionEffect_", "conditionDuration_");
    }
}
}
