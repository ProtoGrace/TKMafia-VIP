package com.company.assembleegameclient.objects.animation {
public class AnimationsData {


    public function AnimationsData(xml:XML) {
        var animationXML:XML = null;
        this.animations = new Vector.<AnimationData>();
        super();
        for each(animationXML in xml.Animation) {
            this.animations.push(new AnimationData(animationXML));
        }
    }
    public var animations:Vector.<AnimationData>;
}
}
