package kabam.rotmg.stage3D {
import com.adobe.utils.AGALMiniAssembler;
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.parameters.Parameters;
import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsGradientFill;
import flash.display.IGraphicsData;
import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.display3D.textures.Texture;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;

import kabam.rotmg.stage3D.Object3D.Util;
import kabam.rotmg.stage3D.graphic3D.Graphic3D;
import kabam.rotmg.stage3D.proxies.Context3DProxy;

import org.swiftsuspenders.Injector;

public class Renderer {
    public static const STAGE3D_FILTER_PAUSE:uint = 1;
    public static const STAGE3D_FILTER_BLIND:uint = 2;
    public static const STAGE3D_FILTER_DRUNK:uint = 3;
    private static const POST_FILTER_VERTEX_CONSTANTS:Vector.<Number> = new <Number>[1,2,0,0];
    private static const GRAYSCALE_FRAGMENT_CONSTANTS:Vector.<Number> = new <Number>[0.3,0.59,0.11,0];
    private static const BLIND_FRAGMENT_CONSTANTS:Vector.<Number> = new <Number>[0.05,0.05,0.05,0];
    private static const POST_FILTER_POSITIONS:Vector.<Number> = new <Number>[-1,1,0,0,1,1,1,0,1,-1,1,1,-1,-1,0,1];
    private static const POST_FILTER_TRIS:Vector.<uint> = new <uint>[0,2,3,0,1,2];
    public static var inGame:Boolean;

    [Inject]
    public var context3D:Context3DProxy;
    [Inject]
    public var injector:Injector;

    private var tX:Number;
    private var tY:Number;
    private var postProcessingProgram:Program3D;
    private var blurPostProcessing:Program3D;
    private var shadowProgram:Program3D;
    private var graphic3D:Graphic3D;
    private var stageHeight:Number = 800;
    private var stageWidth:Number = 600;
    private var sceneTexture:Texture;
    private var blurFactor:Number = 0.01;
    private var postFilterVertexBuffer:VertexBuffer3D;
    private var postFilterIndexBuffer:IndexBuffer3D;
    protected var vertexShader:String;
    protected var fragmentShader:String;
    protected var blurFragmentConstants:Vector.<Number>;
    protected var projection:Matrix3D;
    public var program2:Program3D;
    private var lastCull:String = "none";

    public function Renderer(r3d:Render3D) {
        this.vertexShader = ["m44 op, va0, vc0",
            "m44 v0, va0, vc8",
            "m44 v1, va1, vc8",
            "mov v2, va2"].join("\n");
        this.fragmentShader = ["tex oc, v2, fs0 <2d,clamp>"].join("\n");
        this.blurFragmentConstants = Vector.<Number>([0.4,0.6,0.4,1.5]);
        super();
        this.setTranslationToTitle();
        r3d.add(this.onRender);
    }

    public function init(c3d:Context3D) : void {
        this.projection = Util.perspectiveProjection(56,1,0.1,2048);
        var _loc2_:AGALMiniAssembler = new AGALMiniAssembler();
        _loc2_.assemble("vertex",this.vertexShader);
        var _loc5_:AGALMiniAssembler = new AGALMiniAssembler();
        _loc5_.assemble("fragment",this.fragmentShader);
        this.program2 = context3D.createProgram().getProgram3D();
        this.program2.upload(_loc2_.agalcode,_loc5_.agalcode);
        var _loc10_:String = "tex ft0, v0, fs0 <2d,clamp,linear>\n" +
                "dp3 ft0.x, ft0, fc0\n" +
                "mov ft0.y, ft0.x\n" +
                "mov ft0.z, ft0.x\n" +
                "mov oc, ft0\n";
        var _loc11_:String = "mov op, va0\n" +
                "add vt0, vc0.xxxx, va0\n" +
                "div vt0, vt0, vc0.yyyy\n" +
                "sub vt0.y, vc0.x, vt0.y\n" +
                "mov v0, vt0\n";
        var _loc8_:AGALMiniAssembler = new AGALMiniAssembler();
        _loc8_.assemble("vertex",_loc11_);
        var _loc9_:ByteArray = _loc8_.agalcode;
        _loc8_.assemble("fragment",_loc10_);
        var _loc3_:ByteArray = _loc8_.agalcode;
        this.postProcessingProgram = c3d.createProgram();
        this.postProcessingProgram.upload(_loc9_,_loc3_);
        var _loc6_:String = "sub ft0, v0, fc0\n" +
                "sub ft0.zw, ft0.zw, ft0.zw\n" +
                "dp3 ft1, ft0, ft0\n" +
                "sqt ft1, ft1\n" +
                "div ft1.xy, ft1.xy, fc0.zz\n" +
                "pow ft1.x, ft1.x, fc0.w\n" +
                "mul ft0.xy, ft0.xy, ft1.xx\n" +
                "div ft0.xy, ft0.xy, ft1.yy\n" +
                "add ft0.xy, ft0.xy, fc0.xy\n" +
                "tex oc, ft0, fs0<2d,clamp>\n";
        var _loc12_:String = "m44 op, va0, vc0\n" +
                "mov v0, va1\n";
        _loc8_.assemble("vertex",_loc12_);
        var _loc16_:ByteArray = _loc8_.agalcode;
        _loc8_.assemble("fragment",_loc6_);
        var _loc15_:ByteArray = _loc8_.agalcode;
        this.blurPostProcessing = c3d.createProgram();
        this.blurPostProcessing.upload(_loc16_,_loc15_);
        var _loc14_:String = "m44 op, va0, vc0\n" +
                "mov v0, va1\n" +
                "mov v1, va2\n";
        _loc8_.assemble("vertex",_loc14_);
        var _loc13_:ByteArray = _loc8_.agalcode;
        var _loc7_:String = "sub ft0.xy, v1.xy, fc4.xx\n" +
                "mul ft0.xy, ft0.xy, ft0.xy\n" +
                "add ft0.x, ft0.x, ft0.y\n" +
                "slt ft0.y, ft0.x, fc4.y\n" +
                "mul oc, v0, ft0.yyyy\n";
        _loc8_.assemble("fragment",_loc7_);
        var _loc4_:ByteArray = _loc8_.agalcode;
        this.shadowProgram = c3d.createProgram();
        this.shadowProgram.upload(_loc13_,_loc4_);
        this.sceneTexture = c3d.createTexture(1024,1024,"bgra",true);
        this.postFilterVertexBuffer = c3d.createVertexBuffer(4,4);
        this.postFilterVertexBuffer.uploadFromVector(POST_FILTER_POSITIONS,0,4);
        this.postFilterIndexBuffer = c3d.createIndexBuffer(6);
        this.postFilterIndexBuffer.uploadFromVector(POST_FILTER_TRIS,0,6);
        this.graphic3D = this.injector.getInstance(Graphic3D);
    }

    private function onRender(gfx:Vector.<IGraphicsData>, effId:uint) : void {
        if (WebMain.STAGE.stageWidth != this.stageWidth
                || WebMain.STAGE.stageHeight != this.stageHeight)
            this.resizeStage3DBackBuffer();

        if (Renderer.inGame)
            this.setTranslationToGame();
        else
            this.setTranslationToTitle();

        if (effId > 0)
            this.renderWithPostEffect(gfx, effId);
        else
            this.renderScene(gfx);

        this.context3D.present();
    }

    private function resizeStage3DBackBuffer() : void {
        if (WebMain.STAGE.stageWidth > 1 || WebMain.STAGE.stageHeight > 1) {
            WebMain.STAGE.stage3Ds[0].context3D.configureBackBuffer(WebMain.STAGE.stageWidth,WebMain.STAGE.stageHeight,0,true);
            this.stageWidth = WebMain.STAGE.stageWidth;
            this.stageHeight = WebMain.STAGE.stageHeight;
        }
    }

    private function renderWithPostEffect(gfx:Vector.<IGraphicsData>, effId:uint) : void {
        this.context3D.GetContext3D().setRenderToTexture(this.sceneTexture,true);
        this.renderScene(gfx);
        this.context3D.GetContext3D().setRenderToBackBuffer();
        switch (effId - 1) {
            case 0:
            case 1:
                this.context3D.GetContext3D().setProgram(this.postProcessingProgram);
                this.context3D.GetContext3D().setTextureAt(0,this.sceneTexture);
                this.context3D.GetContext3D().clear();
                this.context3D.GetContext3D().setVertexBufferAt(0,this.postFilterVertexBuffer,0,"float2");
                this.context3D.GetContext3D().setVertexBufferAt(1,null);
                break;
            case 2:
                this.context3D.GetContext3D().setProgram(this.blurPostProcessing);
                this.context3D.GetContext3D().setTextureAt(0,this.sceneTexture);
                this.context3D.GetContext3D().clear();
                this.context3D.GetContext3D().setVertexBufferAt(0,this.postFilterVertexBuffer,0,"float2");
                this.context3D.GetContext3D().setVertexBufferAt(1,this.postFilterVertexBuffer,2,"float2");
        }

        this.context3D.GetContext3D().setVertexBufferAt(2,null);

        switch (effId - 1) {
            case 0:
                this.context3D.setProgramConstantsFromVector("vertex",0,POST_FILTER_VERTEX_CONSTANTS);
                this.context3D.setProgramConstantsFromVector("fragment",0,GRAYSCALE_FRAGMENT_CONSTANTS);
                break;
            case 1:
                this.context3D.setProgramConstantsFromVector("vertex",0,POST_FILTER_VERTEX_CONSTANTS);
                this.context3D.setProgramConstantsFromVector("fragment",0,BLIND_FRAGMENT_CONSTANTS);
                break;
            case 2:
                if (this.blurFragmentConstants[3] <= 0.2 || this.blurFragmentConstants[3] >= 1.8)
                    this.blurFactor = this.blurFactor * -1;

                this.blurFragmentConstants[3] = this.blurFragmentConstants[3] + this.blurFactor;
                this.context3D.setProgramConstantsFromMatrix("vertex",0,new Matrix3D());
                this.context3D.setProgramConstantsFromVector("fragment",0,this.blurFragmentConstants,this.blurFragmentConstants.length / 4);
        }

        this.context3D.GetContext3D().clear();
        this.context3D.GetContext3D().drawTriangles(this.postFilterIndexBuffer);
    }

    private function renderScene(gfxData:Vector.<IGraphicsData>) : void {
        var matrixSet:Boolean = false;
        this.context3D.clear();
        var m3d:Matrix3D = new Matrix3D();
        var gm3d:Matrix3D = this.graphic3D.getMatrix3D();
        var c3d:Context3D = this.context3D.GetContext3D();
        var gfxLen:int = gfxData.length;
        for (var i:int = 0; i < gfxLen; i++) {
            if (lastCull != "none") {
                this.context3D.GetContext3D().setCulling("none");
                lastCull = "none";
            }

            var gfx:IGraphicsData = gfxData[i];
            if (gfx is GraphicsBitmapFill) {
                this.graphic3D.setGraphic(GraphicsBitmapFill(gfx), this.context3D);
                if (!matrixSet) {
                    m3d.identity();
                    m3d.append(gm3d);
                    m3d.appendScale(1 / (this.stageWidth / Parameters.data.mscale / 2),
                            1 / (this.stageHeight / Parameters.data.mscale / 2),1);
                    m3d.appendTranslation(this.tX / (this.stageWidth / Parameters.data.mscale),
                            this.tY / (this.stageHeight / Parameters.data.mscale),0);
                    matrixSet = true;
                }

                this.context3D.setProgramConstantsFromMatrix("vertex", 0, m3d, true);
                this.graphic3D.render(this.context3D);
            }

            matrixSet = false;

            if (gfx is GraphicsGradientFill) {
                c3d.setProgram(this.shadowProgram);
                this.graphic3D.setGradientFill(GraphicsGradientFill(gfx),this.context3D,this.stageWidth / Parameters.data.mscale / 2,this.stageHeight / Parameters.data.mscale / 2);
                if (!matrixSet) {
                    m3d.identity();
                    m3d.append(gm3d);
                    m3d.appendTranslation(this.tX / (this.stageWidth / Parameters.data.mscale),
                            this.tY / (this.stageHeight / Parameters.data.mscale),0);
                    matrixSet = true;
                }

                this.context3D.setProgramConstantsFromMatrix("vertex",0,m3d,true);
                this.context3D.setProgramConstantsFromVector("fragment",4,
                        Vector.<Number>([0.5,0.25,0,0]));
                this.graphic3D.renderShadow(this.context3D);
            }
        }
    }

    private function setTranslationToGame() : void {
        this.tX = -200 * WebMain.STAGE.stageWidth / 800;
        this.tY = Parameters.data.centerOnPlayer ?
                (Camera.CenterRect.y + Camera.CenterRect.height / 2) * 2 :
                (Camera.OffCenterRect.y + Camera.OffCenterRect.height / 2) * 2;
    }

    private function setTranslationToTitle() : void {
        this.tY = this.tX = 0;
    }
}
}