package kabam.rotmg.messaging.impl.incoming {
import flash.utils.IDataInput;

public class NameResult extends IncomingMessage {


    public function NameResult(id:uint, callback:Function) {
        super(id, callback);
    }
    public var success_:Boolean;
    public var errorText_:String;

    override public function parseFromInput(data:IDataInput):void {
        this.success_ = data.readBoolean();
        this.errorText_ = data.readUTF();
    }

    override public function toString():String {
        return formatToString("NAMERESULT", "success_", "errorText_");
    }
}
}
