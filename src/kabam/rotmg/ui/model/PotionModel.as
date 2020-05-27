package kabam.rotmg.ui.model {
import org.osflash.signals.Signal;

public class PotionModel {


    public function PotionModel() {
        super();
        this.update = new Signal(int);
        this.available = true;
    }
    public var objectId:uint;
    public var maxPotionCount:int;
    public var position:int;
    public var available:Boolean;
    public var update:Signal;
}
}
