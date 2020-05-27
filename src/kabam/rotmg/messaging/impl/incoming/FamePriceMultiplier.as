package kabam.rotmg.messaging.impl.incoming {
import flash.utils.IDataInput;

public class FamePriceMultiplier extends IncomingMessage {


    public function FamePriceMultiplier(id:uint, callback:Function) {
        super(id, callback);
    }
    public var multiplier:Number;

    override public function parseFromInput(data:IDataInput):void {
        this.multiplier = data.readFloat();
    }

    override public function toString():String {
        return formatToString("FAME_PRICE_MULTIPLIER", "multiplier");
    }
}
}
