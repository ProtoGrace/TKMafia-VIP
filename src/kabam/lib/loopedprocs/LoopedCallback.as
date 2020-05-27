package kabam.lib.loopedprocs {
public class LoopedCallback extends LoopedProcess {


    public function LoopedCallback(runInterval:int, callbackFunc:Function, ...params) {
        super(runInterval);
        this.callback = callbackFunc;
        this.parameters = params;
    }
    public var callback:Function;
    public var parameters:Array;

    override protected function run():void {
        this.callback.apply(this.parameters);
    }

    override protected function onDestroyed():void {
        this.callback = null;
        this.parameters = null;
    }
}
}
