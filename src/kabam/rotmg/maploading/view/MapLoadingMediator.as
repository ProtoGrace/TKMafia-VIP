package kabam.rotmg.maploading.view {
import kabam.rotmg.maploading.signals.HideMapLoadingSignal;

import robotlegs.bender.bundles.mvcs.Mediator;

public class MapLoadingMediator extends Mediator {


    public function MapLoadingMediator() {
        super();
    }
    [Inject]
    public var view:MapLoadingView;
    [Inject]
    public var hideMapLoading:HideMapLoadingSignal;

    override public function initialize():void {
        this.hideMapLoading.add(this.onHide);
    }

    override public function destroy():void {
        this.hideMapLoading.remove(this.onHide);
    }

    private function onHide():void {
        this.view.disable();
    }
}
}
