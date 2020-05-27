package kabam.rotmg.messaging.impl.outgoing.bounty {
import flash.utils.IDataOutput;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

public class BountyRequest extends OutgoingMessage {


    public function BountyRequest(_arg1:uint, _arg2:Function) {
        super(_arg1, _arg2);
    }
    public var BountyId:int;

    override public function writeToOutput(_arg1:IDataOutput):void {
        _arg1.writeInt(this.BountyId);
    }

    override public function toString():String {
        return formatToString("BOUNTYREQUEST", "BountyId");
    }
}
}
