package com.company.assembleegameclient.objects.particles {
public class EffectProperties {


    public function EffectProperties(effectXML:XML) {
        super();
        this.id = effectXML.toString();
        this.particle = effectXML.@particle;
        this.cooldown = effectXML.@cooldown;
        this.color = effectXML.@color;
        this.rate = Number(Number(effectXML.@rate)) || Number(Number(5));
        this.speed = Number(Number(effectXML.@speed)) || Number(Number(0));
        this.speedVariance = Number(Number(effectXML.@speedVariance)) || Number(Number(0.5));
        this.spread = Number(Number(effectXML.@spread)) || Number(Number(0));
        this.life = Number(Number(effectXML.@life)) || Number(Number(1));
        this.lifeVariance = Number(Number(effectXML.@lifeVariance)) || Number(Number(0));
        this.size = int(int(effectXML.@size)) || int(int(3));
        this.rise = Number(Number(effectXML.@rise)) || Number(Number(3));
        this.riseVariance = Number(Number(effectXML.@riseVariance)) || Number(Number(0));
        this.riseAcc = Number(Number(effectXML.@riseAcc)) || Number(Number(0));
        this.rangeX = int(int(effectXML.@rangeX)) || int(int(0));
        this.rangeY = int(int(effectXML.@rangeY)) || int(int(0));
        this.zOffset = Number(Number(effectXML.@zOffset)) || Number(Number(0));
        this.bitmapFile = effectXML.@bitmapFile;
        this.bitmapIndex = effectXML.@bitmapIndex;
    }
    public var id:String;
    public var particle:String;
    public var cooldown:Number;
    public var color:uint;
    public var rate:Number;
    public var speed:Number;
    public var speedVariance:Number;
    public var spread:Number;
    public var life:Number;
    public var lifeVariance:Number;
    public var size:int;
    public var friction:Number;
    public var rise:Number;
    public var riseVariance:Number;
    public var riseAcc:Number;
    public var rangeX:int;
    public var rangeY:int;
    public var zOffset:Number;
    public var bitmapFile:String;
    public var bitmapIndex:uint;
}
}
