package kabam.rotmg.core.view {
import flash.display.Sprite;

public class ScreensView extends Sprite {


    public function ScreensView() {
        super();
    }
    private var current:Sprite;
    private var previous:Sprite;

    public function setScreen(sprite:Sprite):void {
        if (this.current == sprite) {
            return;
        }
        this.removePrevious();
        this.current = sprite;
        addChild(sprite);
    }

    public function getPrevious():Sprite {
        return this.previous;
    }

    private function removePrevious():void {
        if (this.current && contains(this.current)) {
            this.previous = this.current;
            removeChild(this.current);
        }
    }
}
}
