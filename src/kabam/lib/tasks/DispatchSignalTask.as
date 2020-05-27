package kabam.lib.tasks {
import org.osflash.signals.Signal;

public class DispatchSignalTask extends BaseTask {


    public function DispatchSignalTask(signal:Signal, ...params) {
        super();
        this.signal = signal;
        this.params = params;
    }
    private var signal:Signal;
    private var params:Array;

    override protected function startTask():void {
        this.signal.dispatch.apply(null, this.params);
        completeTask(true);
    }
}
}
