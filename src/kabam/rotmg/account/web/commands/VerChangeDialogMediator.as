package kabam.rotmg.account.web.commands {
import kabam.rotmg.dialogs.control.CloseDialogsSignal;

import robotlegs.bender.bundles.mvcs.Mediator;

public class VerChangeDialogMediator extends Mediator {
    public function VerChangeDialogMediator() {
        super();
    }
    [Inject]
    public var closeDialog:CloseDialogsSignal;
    [Inject]
    public var view:VerChangeDialog;

    override public function initialize():void {
        this.view.close.add(this.onClose);
    }

    override public function destroy():void {
        this.view.close.remove(this.onClose);
    }

    private function onClose():void {
        this.closeDialog.dispatch();
    }
}
}
