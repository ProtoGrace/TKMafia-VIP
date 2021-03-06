package kabam.rotmg.messaging.impl.incoming {
import flash.utils.IDataInput;

public class Damage extends IncomingMessage {


    public function Damage(id:uint, callback:Function) {
        this.effects_ = new Vector.<uint>();
        super(id, callback);
    }
    public var targetId_:int;
    public var effects_:Vector.<uint>;
    public var damageAmount_:int;
    public var kill_:Boolean;
    public var bulletId_:uint;
    public var objectId_:int;

    override public function parseFromInput(data:IDataInput):void {
        this.targetId_ = data.readInt();
        this.effects_.length = 0;
        var len:int = data.readUnsignedByte();
        for (var i:uint = 0; i < len; i++) {
            this.effects_.push(data.readUnsignedByte());
        }
        this.damageAmount_ = data.readUnsignedShort();
        this.kill_ = data.readBoolean();
        this.bulletId_ = data.readUnsignedByte();
        this.objectId_ = data.readInt();
    }

    override public function toString():String {
        return formatToString("DAMAGE", "targetId_", "effects_", "damageAmount_", "kill_", "bulletId_", "objectId_");
    }
}
}
