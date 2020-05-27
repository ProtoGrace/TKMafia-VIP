package kabam.rotmg.core.view {
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import kabam.rotmg.dialogs.view.DialogsView;
import kabam.rotmg.tooltips.view.TooltipsView;

public class Layers extends Sprite {


    public function Layers() {
        super();
        addChild(this.menu = new ScreensView());
        addChild(this.overlay = new Sprite());
        addChild(this.top = new Sprite());
        addChild(this.mouseDisabledTop = new Sprite());
        this.mouseDisabledTop.mouseEnabled = false;
        addChild(this.dialogs = new DialogsView());
        addChild(this.tooltips = new TooltipsView());
        addChild(this.api = new Sprite());
        addChild(this.console = new Sprite());
    }
    public var overlay:DisplayObjectContainer;
    public var top:DisplayObjectContainer;
    public var mouseDisabledTop:DisplayObjectContainer;
    public var api:DisplayObjectContainer;
    public var console:DisplayObjectContainer;
    private var menu:ScreensView;
    private var tooltips:TooltipsView;
    private var dialogs:DialogsView;
}
}
