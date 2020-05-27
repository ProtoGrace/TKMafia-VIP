package kabam.rotmg.account.web.commands {
import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.web.view.VerChangeDialog;
import kabam.rotmg.account.web.view.WebAccountDetailDialog;
import kabam.rotmg.account.web.view.WebRegisterDialog;
import kabam.rotmg.dialogs.control.OpenDialogSignal;

public class OpenVerChangeCommand {


    public function OpenVerChangeCommand() {
        super();
    }
    [Inject]
    public var openDialog:OpenDialogSignal;

    public function execute():void {
        this.openDialog.dispatch(new VerChangeDialog());
    }
}
}
