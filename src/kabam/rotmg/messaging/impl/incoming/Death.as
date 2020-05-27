package kabam.rotmg.messaging.impl.incoming {
import flash.display.BitmapData;
import flash.utils.IDataInput;

public class Death extends IncomingMessage {


    public function Death(id:uint, callback:Function) {
        super(id, callback);
    }
    public var accountId_:int;
    public var charId_:int;
    public var killedBy_:String;
    public var background:BitmapData;

    override public function parseFromInput(data:IDataInput):void {
        this.accountId_ = data.readInt();
        this.charId_ = data.readInt();
        this.killedBy_ = data.readUTF();
    }

    override public function toString():String {
        return formatToString("DEATH", "accountId_", "charId_", "killedBy_");
    }

    public function disposeBackground():void {
        this.background && this.background.dispose();
        this.background = null;
    }
}
}
