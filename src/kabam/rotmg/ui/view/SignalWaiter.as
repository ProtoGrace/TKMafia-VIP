package kabam.rotmg.ui.view {
import com.adobe.utils.DictionaryUtil;

import flash.utils.Dictionary;

import org.osflash.signals.Signal;

public class SignalWaiter {


    public function SignalWaiter() {
        this.complete = new Signal();
        this.texts = new Dictionary();
        super();
    }
    public var complete:Signal;
    private var texts:Dictionary;

    public function push(_arg1:Signal):SignalWaiter {
        this.texts[_arg1] = true;
        this.listenTo(_arg1);
        return this;
    }

    public function pushArgs(..._args):SignalWaiter {
        var _local2:Signal = null;
        for each(_local2 in _args) {
            this.push(_local2);
        }
        return this;
    }

    public function isEmpty():Boolean {
        return DictionaryUtil.getKeys(this.texts).length == 0;
    }

    private function listenTo(value:Signal):void {
        var onTextChanged:Function = null;
        onTextChanged = function ():void {
            delete texts[value];
            checkEmpty();
        };
        value.addOnce(onTextChanged);
    }

    private function checkEmpty():void {
        if (this.isEmpty()) {
            this.complete.dispatch();
        }
    }
}
}
