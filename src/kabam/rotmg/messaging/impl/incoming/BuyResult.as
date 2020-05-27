package kabam.rotmg.messaging.impl.incoming {
import flash.utils.IDataInput;

public class BuyResult extends IncomingMessage {

    public static const SUCCESS_BRID:int = 0;

    public static const DIALOG_BRID:int = 1;

    public function BuyResult(id:uint, callback:Function) {
        super(id, callback);
    }
    public var result_:int;
    public var resultString_:String;

    override public function parseFromInput(data:IDataInput):void {
        this.result_ = data.readInt();
        this.resultString_ = data.readUTF();
    }

    override public function toString():String {
        return formatToString("BUYRESULT", "result_", "resultString_");
    }
}
}
