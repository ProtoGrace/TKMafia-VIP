package com.company.assembleegameclient.sound {
import com.company.assembleegameclient.parameters.Parameters;

import flash.media.SoundTransform;

public class SFX {

    private static var sfxTrans_:SoundTransform;

    public static function load():void {
        sfxTrans_ = new SoundTransform(!!Boolean(Parameters.data.playSFX) ? Number(Number(1)) : Number(Number(0)));
    }

    public static function setPlaySFX(playSFX:Boolean):void {
        Parameters.data.playSFX = playSFX;
        Parameters.save();
        SoundEffectLibrary.updateTransform();
    }

    public function SFX() {
        super();
    }
}
}
