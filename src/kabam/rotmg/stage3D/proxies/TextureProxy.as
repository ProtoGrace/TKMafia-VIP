package kabam.rotmg.stage3D.proxies {
import flash.display.BitmapData;
import flash.display3D.textures.Texture;
import flash.display3D.textures.TextureBase;

public class TextureProxy {


    public function TextureProxy(texture:Texture) {
        super();
        this.texture = texture;
    }
    protected var width:int;

    protected var height:int;
    private var texture:Texture;

    public function uploadFromBitmapData(bitmapData:BitmapData):void {
        this.width = bitmapData.width;
        this.height = bitmapData.height;
        this.texture.uploadFromBitmapData(bitmapData);
    }

    public function getTexture():TextureBase {
        return this.texture;
    }

    public function getWidth():int {
        return this.width;
    }

    public function getHeight():int {
        return this.height;
    }

    public function dispose():void {
        this.texture.dispose();
    }
}
}
