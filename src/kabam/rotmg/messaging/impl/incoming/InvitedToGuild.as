package kabam.rotmg.messaging.impl.incoming {
import flash.utils.IDataInput;

public class InvitedToGuild extends IncomingMessage {


    public function InvitedToGuild(id:uint, callback:Function) {
        super(id, callback);
    }
    public var name_:String;
    public var guildName_:String;

    override public function parseFromInput(data:IDataInput):void {
        this.name_ = data.readUTF();
        this.guildName_ = data.readUTF();
    }

    override public function toString():String {
        return formatToString("INVITEDTOGUILD", "name_", "guildName_");
    }
}
}
