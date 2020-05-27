package kabam.rotmg.stage3D.graphic3D {
import flash.display.BitmapData;
import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsGradientFill;
import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import kabam.rotmg.stage3D.GraphicsFillExtra;
import kabam.rotmg.stage3D.proxies.Context3DProxy;
import kabam.rotmg.stage3D.proxies.IndexBuffer3DProxy;
import kabam.rotmg.stage3D.proxies.TextureProxy;
import kabam.rotmg.stage3D.proxies.VertexBuffer3DProxy;

public class Graphic3D {

    private static const indices:Vector.<uint> = Vector.<uint>([0,1,2,2,1,3]);

    private static const gradientVertex:Vector.<Number> = Vector.<Number>([-0.5,0.5,0,0,0,0,0.01,0,1,0.5,0.5,0,0,0,0,0.3,1,1,-0.5,-0.5,0,0,0,0,0.1,0,0,0.5,-0.5,0,0,0,0,0.2,1,0]);


    [Inject]
    public var textureFactory:TextureFactory;

    [Inject]
    public var vertexBuffer:VertexBuffer3DProxy;

    [Inject]
    public var indexBuffer:IndexBuffer3DProxy;

    public var texture:TextureProxy;

    public var matrix3D:Matrix3D;

    private var bitmapData:BitmapData;

    private var matrix2D:Matrix;

    private var shadowMatrix2D:Matrix;

    private var sinkLevel:Number = 0;

    private var offsetMatrix:Vector.<Number>;

    private var lastMatrix:Vector.<Number>;

    private var ctMult:Vector.<Number>;

    private var ctOffset:Vector.<Number>;

    private var vertexBufferCustom:VertexBuffer3D;

    private var gradientVB:VertexBuffer3D;

    private var gradientIB:IndexBuffer3D;

    private var repeat:Boolean;

    private var rawMatrix3D:Vector.<Number>;

    private var ct:ColorTransform;

    private var c3d:Context3D;

    private var defaultOffsetMatrix:Vector.<Number>;

    public function Graphic3D() {
        defaultOffsetMatrix = Vector.<Number>([0,0,0,0]);
        this.matrix3D = new Matrix3D();
        this.ctMult = new Vector.<Number>(4,true);
        this.ctOffset = new Vector.<Number>(4,true);
        this.rawMatrix3D = new Vector.<Number>(16,true);
        super();
    }

    public function setGraphic(param1:GraphicsBitmapFill, param2:Context3DProxy) : void {
        this.bitmapData = param1.bitmapData;
        this.repeat = param1.repeat;
        this.matrix2D = param1.matrix;
        this.texture = this.textureFactory.make(param1.bitmapData);
        this.offsetMatrix = GraphicsFillExtra.getOffsetUV(param1);
        this.vertexBufferCustom = GraphicsFillExtra.getVertexBuffer(param1);
        this.sinkLevel = GraphicsFillExtra.getSinkLevel(param1);
        if (this.sinkLevel != 0)
            this.offsetMatrix = new <Number>[0, -this.sinkLevel, 0, 0];

        this.transform();
        this.ct = GraphicsFillExtra.getColorTransform(this.bitmapData);
        if(this.ctMult[0] != this.ct.redMultiplier || this.ctMult[1] != this.ct.greenMultiplier || this.ctMult[2] != this.ct.blueMultiplier || this.ctMult[3] != this.ct.alphaMultiplier || this.ctOffset[0] != this.ct.redOffset / 255 || this.ctOffset[1] != this.ct.greenOffset / 255 || this.ctOffset[2] != this.ct.blueOffset / 255 || this.ctOffset[3] != this.ct.alphaOffset / 255) {
            this.ctMult[0] = this.ct.redMultiplier;
            this.ctMult[1] = this.ct.greenMultiplier;
            this.ctMult[2] = this.ct.blueMultiplier;
            this.ctMult[3] = this.ct.alphaMultiplier;
            this.ctOffset[0] = this.ct.redOffset / 255;
            this.ctOffset[1] = this.ct.greenOffset / 255;
            this.ctOffset[2] = this.ct.blueOffset / 255;
            this.ctOffset[3] = this.ct.alphaOffset / 255;
            this.c3d = param2.GetContext3D();
            this.c3d.setProgramConstantsFromVector("fragment",2,ctMult);
            this.c3d.setProgramConstantsFromVector("fragment",3,ctOffset);
        }
    }

    public function setGradientFill(param1:GraphicsGradientFill, param2:Context3DProxy, param3:Number, param4:Number) : void {
        this.shadowMatrix2D = param1.matrix;
        if(this.gradientVB == null || this.gradientIB == null) {
            this.gradientVB = param2.GetContext3D().createVertexBuffer(4,9);
            this.gradientVB.uploadFromVector(gradientVertex,0,4);
            this.gradientIB = param2.GetContext3D().createIndexBuffer(6);
            this.gradientIB.uploadFromVector(indices,0,6);
        }
        this.shadowTransform(param3,param4);
    }

    private function shadowTransform(param1:Number, param2:Number) : void {
        this.matrix3D.identity();
        var _loc3_:Vector.<Number> = this.matrix3D.rawData;
        _loc3_[4] = -this.shadowMatrix2D.c;
        _loc3_[1] = -this.shadowMatrix2D.b;
        _loc3_[0] = this.shadowMatrix2D.a * 4;
        _loc3_[5] = this.shadowMatrix2D.d * 4;
        _loc3_[12] = this.shadowMatrix2D.tx / param1;
        _loc3_[13] = -this.shadowMatrix2D.ty / param2;
        this.matrix3D.rawData = _loc3_;
    }

    private function transform() : void {
        this.matrix3D.identity();
        this.matrix3D.copyRawDataTo(rawMatrix3D);
        rawMatrix3D[4] = -this.matrix2D.c;
        rawMatrix3D[1] = -this.matrix2D.b;
        rawMatrix3D[0] = this.matrix2D.a;
        rawMatrix3D[5] = this.matrix2D.d;
        rawMatrix3D[12] = this.matrix2D.tx;
        rawMatrix3D[13] = -this.matrix2D.ty;
        this.matrix3D.copyRawDataFrom(rawMatrix3D);
        this.matrix3D.prependScale(Math.ceil(this.texture.getWidth()),Math.ceil(this.texture.getHeight()),1);
        this.matrix3D.prependTranslation(0.5,-0.5,0);
    }

    public function render(param1:Context3DProxy) : void {
        param1.setProgram(Program3DFactory.getInstance().getProgram(param1,this.repeat));
        param1.setTextureAt(0,this.texture);
        var _loc2_:Context3D = param1.GetContext3D();
        if(this.vertexBufferCustom != null) {
            _loc2_.setVertexBufferAt(0,this.vertexBufferCustom,0,"float3");
            _loc2_.setVertexBufferAt(1,this.vertexBufferCustom,3,"float2");
            if(this.offsetMatrix != this.lastMatrix) {
                _loc2_.setProgramConstantsFromVector("vertex",4,this.offsetMatrix);
                this.lastMatrix = this.offsetMatrix;
            }
            _loc2_.setVertexBufferAt(2,null,6,"float2");
            param1.drawTriangles(this.indexBuffer);
        } else {
            param1.setVertexBufferAt(0,this.vertexBuffer,0,"float3");
            param1.setVertexBufferAt(1,this.vertexBuffer,3,"float2");
            if(this.offsetMatrix != this.lastMatrix) {
                _loc2_.setProgramConstantsFromVector("vertex",4,this.offsetMatrix);
                this.lastMatrix = this.offsetMatrix;
            }
            _loc2_.setVertexBufferAt(2,null,6,"float2");
            param1.drawTriangles(this.indexBuffer);
        }
    }

    public function renderShadow(param1:Context3DProxy) : void {
        var _loc2_:Context3D = param1.GetContext3D();
        _loc2_.setVertexBufferAt(0,this.gradientVB,0,"float3");
        _loc2_.setVertexBufferAt(1,this.gradientVB,3,"float4");
        _loc2_.setVertexBufferAt(2,this.gradientVB,7,"float2");
        _loc2_.setTextureAt(0,null);
        _loc2_.drawTriangles(this.gradientIB);
    }

    public function getMatrix3D() : Matrix3D {
        return this.matrix3D;
    }
}
}
