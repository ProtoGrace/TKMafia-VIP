package com.company.assembleegameclient.util.redrawers {
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.PointUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import flash.utils.Dictionary;

public class GlowRedrawer {
    private static const GLOW_FILTER:GlowFilter = new GlowFilter(0, 0.3, 12, 12, 2, BitmapFilterQuality.LOW, false, false);

    private static var glowHashes:Dictionary = new Dictionary();

    public static function clearCache() : void {
        var _loc6_:int = 0;
        var _loc5_:* = glowHashes;
        for each(var _loc2_ in glowHashes) {
            var _loc4_:int = 0;
            var _loc3_:* = _loc2_;
            for each(var _loc1_ in _loc2_) {
                delete _loc2_[_loc1_];
            }
            delete glowHashes[_loc2_];
        }
        glowHashes = new Dictionary();
    }

    public static function outlineGlow(texture:BitmapData, glowColor:uint, outlineSize:Number = 1.4, caching:Boolean = true, outlineColor:int = 0):BitmapData {
        var hash:String = getHash(glowColor, outlineSize, outlineColor);
        if (caching && isCached(texture, hash)) {
            return glowHashes[texture][hash];
        }
        var newTexture:BitmapData = texture.clone();
        var origBitmap:Bitmap = new Bitmap(texture);
        newTexture.draw(origBitmap, null, null, BlendMode.ALPHA);
        TextureRedrawer.OUTLINE_FILTER.blurX = outlineSize;
        TextureRedrawer.OUTLINE_FILTER.blurY = outlineSize;
        TextureRedrawer.OUTLINE_FILTER.color = outlineColor;
        newTexture.applyFilter(newTexture, newTexture.rect, PointUtil.ORIGIN, TextureRedrawer.OUTLINE_FILTER);
        if (glowColor != 4294967295) {
            if (Parameters.isGpuRender() && glowColor != 0) {
                GLOW_FILTER.color = glowColor;
                newTexture.applyFilter(newTexture, newTexture.rect, PointUtil.ORIGIN, GLOW_FILTER);
            } else {
                GLOW_FILTER.color = glowColor;
                newTexture.applyFilter(newTexture, newTexture.rect, PointUtil.ORIGIN, GLOW_FILTER);
            }
        }
        if (caching) {
            cache(texture, glowColor, outlineSize, newTexture, outlineColor);
        }
        return newTexture;
    }

    private static function cache(texture:BitmapData, glowColor:uint, outlineSize:Number, newTexture:BitmapData, outlineColor:int):void {
        var glowHash:Object = null;
        var hash:String = getHash(glowColor, outlineSize, outlineColor);
        if (texture in glowHashes) {
            glowHashes[texture][hash] = newTexture;
        } else {
            glowHash = {};
            glowHash[hash] = newTexture;
            glowHashes[texture] = glowHash;
        }
    }

    private static function isCached(texture:BitmapData, hash:String):Boolean {
        var outlineHash:Object = null;
        if (texture in glowHashes) {
            outlineHash = glowHashes[texture];
            if (hash in outlineHash) {
                return true;
            }
        }
        return false;
    }

    private static function getHash(glowColor:uint, outlineSize:Number, outlineColor:int):String {
        return int(outlineSize * 10).toString() + glowColor + outlineColor;
    }

    public function GlowRedrawer() {
        super();
    }
}
}
