package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class GuildInvite extends OutgoingMessage {


    public function GuildInvite(id:uint, callback:Function) {
        super(id, callback);
    }
    public var name_:String;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeUTF(this.name_);
    }

    override public function toString():String {
        return formatToString("GUILDINVITE", "name_");
    }
}
}
