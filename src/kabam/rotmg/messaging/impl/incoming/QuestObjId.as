package kabam.rotmg.messaging.impl.incoming {
import flash.utils.IDataInput;

public class QuestObjId extends IncomingMessage {


    public function QuestObjId(id:uint, callback:Function) {
        super(id, callback);
    }
    public var objectId_:int;

    override public function parseFromInput(data:IDataInput):void {
        this.objectId_ = data.readInt();
    }

    override public function toString():String {
        return formatToString("QUESTOBJID", "objectId_");
    }
}
}
