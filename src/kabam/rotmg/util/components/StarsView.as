package kabam.rotmg.util.components {
import com.company.rotmg.graphics.StarGraphic;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.ColorTransform;

public class StarsView extends Sprite {

    private static const TOTAL:int = 5;

    private static const MARGIN:int = 4;

    private static const CORNER:int = 15;

    private static const BACKGROUND_COLOR:uint = 2434341;

    private static const EMPTY_STAR_COLOR:uint = 8618883;

    private static const FILLED_STAR_COLOR:uint = 16777215;


    private const stars:Vector.<StarGraphic> = this.makeStars();

    private const background:Sprite = this.makeBackground();

    public function StarsView() {
        super();
    }

    public function setStars(filled:int):void {
        for (var i:int = 0; i < TOTAL; i++) {
            this.updateStar(i, filled);
        }
    }

    private function makeStars():Vector.<StarGraphic> {
        var list:Vector.<StarGraphic> = this.makeStarList();
        this.layoutStars(list);
        return list;
    }

    private function makeStarList():Vector.<StarGraphic> {
        var list:Vector.<StarGraphic> = new Vector.<StarGraphic>(TOTAL, true);
        for (var i:int = 0; i < TOTAL; i++) {
            list[i] = new StarGraphic();
            addChild(list[i]);
        }
        return list;
    }

    private function layoutStars(list:Vector.<StarGraphic>):void {
        for (var i:int = 0; i < TOTAL; i++) {
            list[i].x = MARGIN + list[0].width * i;
            list[i].y = MARGIN;
        }
    }

    private function makeBackground():Sprite {
        var sprite:Sprite = new Sprite();
        this.drawBackground(sprite.graphics);
        addChildAt(sprite, 0);
        return sprite;
    }

    private function drawBackground(graphics:Graphics):void {
        var star:StarGraphic = this.stars[0];
        var width:int = star.width * TOTAL + 2 * MARGIN;
        var height:int = star.height + 2 * MARGIN;
        graphics.clear();
        graphics.beginFill(BACKGROUND_COLOR);
        graphics.drawRoundRect(0, 0, width, height, CORNER, CORNER);
        graphics.endFill();
    }

    private function updateStar(index:int, filled:int):void {
        var star:StarGraphic = this.stars[index];
        var ct:ColorTransform = star.transform.colorTransform;
        ct.color = index < filled ? uint(uint(FILLED_STAR_COLOR)) : uint(uint(EMPTY_STAR_COLOR));
        star.transform.colorTransform = ct;
    }
}
}
