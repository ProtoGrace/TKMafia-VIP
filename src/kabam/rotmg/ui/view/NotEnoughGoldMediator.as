package kabam.rotmg.ui.view {
import kabam.rotmg.account.core.Account;
import kabam.rotmg.dialogs.control.CloseDialogsSignal;

import robotlegs.bender.bundles.mvcs.Mediator;

public class NotEnoughGoldMediator extends Mediator {


    public function NotEnoughGoldMediator() {
        super();
    }
    [Inject]
    public var account:Account;
    [Inject]
    public var view:NotEnoughGoldDialog;
    [Inject]
    public var closeDialogs:CloseDialogsSignal;

    override public function initialize():void {
        this.view.cancel.add(this.onCancel);
    }

    override public function destroy():void {
        this.view.cancel.remove(this.onCancel);
    }

    public function onCancel():void {
        this.closeDialogs.dispatch();
    }
}
}
