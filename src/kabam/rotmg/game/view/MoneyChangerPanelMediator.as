package kabam.rotmg.game.view {
import kabam.rotmg.account.core.Account;

import robotlegs.bender.bundles.mvcs.Mediator;

public class MoneyChangerPanelMediator extends Mediator {


    public function MoneyChangerPanelMediator() {
        super();
    }
    [Inject]
    public var account:Account;
    [Inject]
    public var view:MoneyChangerPanel;

    override public function initialize():void {
        this.view.triggered.add(this.onTriggered);
    }

    override public function destroy():void {
        this.view.triggered.remove(this.onTriggered);
    }

    private function onTriggered():void {
    }
}
}
