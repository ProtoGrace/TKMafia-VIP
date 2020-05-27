package kabam.rotmg.ui.commands {
import flash.display.DisplayObjectContainer;

import kabam.rotmg.ui.view.KeysView;

public class ShowKeyUICommand {


    public function ShowKeyUICommand() {
        super();
    }
    [Inject]
    public var contextView:DisplayObjectContainer;

    public function execute():void {
        var view:KeysView = new KeysView();
        view.x = 4;
        view.y = 4;
        this.contextView.addChild(view);
    }
}
}
