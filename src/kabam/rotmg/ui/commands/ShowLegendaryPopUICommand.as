package kabam.rotmg.ui.commands {
import com.gskinner.motion.GTween;

import flash.display.DisplayObjectContainer;
import flash.utils.setTimeout;

import kabam.rotmg.ui.view.LegendaryNotifViewPng;

import mx.core.BitmapAsset;

public class ShowLegendaryPopUICommand {

    private static var keyBackgroundPng:Class = LegendaryNotifViewPng;

    public function ShowLegendaryPopUICommand() {
        super();
    }
    [Inject]
    public var contextView:DisplayObjectContainer;
    private var view:BitmapAsset;

    public function execute():void {
        this.view = new keyBackgroundPng();
        this.view.x = 0;
        this.view.y = 0;
        this.contextView.addChild(this.view);
        this.view.alpha = 0.8;
        new GTween(this.view, 0.5, {"alpha": 1});
        setTimeout(function ():void {
            new GTween(view, 0.5, {"alpha": 0});
        }, 1500);
        setTimeout(this.remove, 2000);
    }

    private function remove():void {
        this.contextView.removeChild(this.view);
        this.view = null;
    }
}
}
