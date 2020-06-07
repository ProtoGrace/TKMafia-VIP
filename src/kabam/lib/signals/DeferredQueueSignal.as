package kabam.lib.signals {
import org.osflash.signals.ISlot;
import org.osflash.signals.Signal;

public class DeferredQueueSignal extends Signal {


    public function DeferredQueueSignal(...valueClasses) {
        this.data = [];
        super(valueClasses);
    }
    private var data:Array;
    private var log:Boolean = true;

    override public function dispatch(... rest) : void {
        if (this.log) {
            this.data.push(rest);
        }
        super.dispatch.apply(this, rest);
    }

    override public function add(listener:Function):ISlot {
        var slot:ISlot = super.add(listener);
        while (this.data.length > 0) {
            listener.apply(this, this.data.shift());
        }
        this.log = false;
        return slot;
    }

    override public function addOnce(listener:Function):ISlot {
        var slot:ISlot = null;
        if (this.data.length > 0) {
            listener.apply(this, this.data.shift());
        } else {
            slot = super.addOnce(listener);
            this.log = false;
        }
        while (this.data.length > 0) {
            this.data.shift();
        }
        return slot;
    }

    public function getNumData():int {
        return this.data.length;
    }
}
}
