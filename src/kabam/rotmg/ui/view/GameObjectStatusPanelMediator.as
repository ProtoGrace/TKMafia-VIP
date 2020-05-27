package kabam.rotmg.ui.view {
import com.company.assembleegameclient.ui.GameObjectStatusPanel;

import robotlegs.bender.bundles.mvcs.Mediator;

public class GameObjectStatusPanelMediator extends Mediator {


    public function GameObjectStatusPanelMediator() {
        this.names = ["Apple", "Tortilla", "Chainsaw", "Monkey", "Flotilla", "Zephyr", "Ghost", "Tupac", "Alluvial", "Dante", "Soprano", "Godzilla", "Hate", "Freebird", "Desire", "Good", "Nightie", "Osprey"];
        super();
    }
    [Inject]
    public var view:GameObjectStatusPanel;
    private var name:String;
    private var names:Array;

    override public function initialize():void {
    }

    override public function destroy():void {
        super.destroy();
    }
}
}
