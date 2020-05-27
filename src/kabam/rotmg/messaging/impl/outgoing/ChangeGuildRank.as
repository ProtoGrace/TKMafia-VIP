package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class ChangeGuildRank extends OutgoingMessage {


    public function ChangeGuildRank(id:uint, callback:Function) {
        super(id, callback);
    }
    public var name_:String;
    public var guildRank_:int;

    override public function writeToOutput(data:IDataOutput):void {
        data.writeUTF(this.name_);
        data.writeInt(this.guildRank_);
    }

    override public function toString():String {
        return formatToString("CHANGEGUILDRANK", "name_", "guildRank_");
    }
}
}
