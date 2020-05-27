package kabam.lib.tasks {
import flash.errors.IllegalOperationError;

import org.osflash.signals.Signal;

public class BaseTask implements Task {


    public function BaseTask() {
        super();
    }

    private var _started:TaskStartedSignal;

    public final function get started():Signal {
        return this._started = this._started || new TaskStartedSignal();
    }

    private var _finished:TaskResultSignal;

    public final function get finished():TaskResultSignal {
        return this._finished = this._finished || new TaskResultSignal();
    }

    private var _lastly:TaskResultSignal;

    public final function get lastly():TaskResultSignal {
        return this._lastly = this._lastly || new TaskResultSignal();
    }

    private var _isStarted:Boolean;

    public function get isStarted():Boolean {
        return this._isStarted;
    }

    private var _isFinished:Boolean;

    public function get isFinished():Boolean {
        return this._isFinished;
    }

    private var _isOK:Boolean;

    public function get isOK():Boolean {
        return this._isOK;
    }

    private var _error:String;

    public function get error():String {
        return this._error;
    }

    public final function start():void {
        if (!this._isStarted) {
            this._isStarted = true;
            this._started && this._started.dispatch(this);
            this.startTask();
        }
    }

    public final function reset():void {
        if (this._isStarted) {
            this._isStarted = false;
            if (!this._isFinished) {
                throw new IllegalOperationError("Unable to Task.reset() when a task is ongoing");
            }
        }
        this._started && this._started.removeAll();
        this._finished && this._finished.removeAll();
        this._lastly && this._lastly.removeAll();
        this.onReset();
    }

    protected function startTask():void {
    }

    protected function onReset():void {
    }

    protected final function completeTask(isOK:Boolean, error:String = ""):void {
        this._isOK = isOK;
        this._error = error;
        this._isFinished = true;
        this._finished && this._finished.dispatch(this, isOK, error);
        this._lastly && this._lastly.dispatch(this, isOK, error);
    }
}
}
