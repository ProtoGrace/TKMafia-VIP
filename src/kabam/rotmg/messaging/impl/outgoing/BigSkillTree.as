package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class BigSkillTree extends OutgoingMessage {


    public function BigSkillTree(_arg1:uint, _arg2:Function) {
        super(_arg1, _arg2);
    }
    public var skillNumber:int;

    override public function writeToOutput(_arg1:IDataOutput):void {
        _arg1.writeInt(this.skillNumber);
    }

    override public function toString():String {
        return formatToString("BIGSKILLTREE", "skillNumber");
    }
}
}
