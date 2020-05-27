package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class JoinGuild extends OutgoingMessage {


    public function JoinGuild(id:uint, callback:Function) {
        super(id, callback);
    }
    public var guildName_:String;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeUTF(this.guildName_);
    }

    override public function toString():String {
        return formatToString("JOINGUILD", "guildName_");
    }
}
}
