package kabam.rotmg.ui.commands {
import com.gskinner.motion.GTween;

import flash.display.DisplayObjectContainer;
import flash.utils.setTimeout;

import kabam.rotmg.ui.view.RevengeNotifViewPng;

import mx.core.BitmapAsset;

public class ShowRevengePopUICommand {

    private static var RevengeNotifPng:Class = RevengeNotifViewPng;

    public function ShowRevengePopUICommand() {
        super();
    }
    [Inject]
    public var contextView:DisplayObjectContainer;
    private var view:BitmapAsset;

    public function execute():void {
        this.view = new RevengeNotifPng();
        this.view.x = 0;
        this.view.y = 0;
        this.contextView.addChild(this.view);
        this.view.alpha = 0.8;
        new GTween(this.view, 0.5, {"alpha": 1});
        setTimeout(function ():void {
            new GTween(view, 0.5, {"alpha": 0});
        }, 2000);
        setTimeout(this.remove, 2500);
    }

    private function remove():void {
        this.contextView.removeChild(this.view);
        this.view = null;
    }
}
}
