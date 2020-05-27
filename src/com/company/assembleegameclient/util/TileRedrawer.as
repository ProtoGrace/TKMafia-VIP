package com.company.assembleegameclient.util {
import com.company.assembleegameclient.map.GroundLibrary;
import com.company.assembleegameclient.map.GroundLibrary;
import com.company.assembleegameclient.map.GroundProperties;
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.map.Square;
import com.company.util.AssetLibrary;
import com.company.util.BitmapUtil;
import com.company.util.ImageSet;
import com.company.util.PointUtil;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public class TileRedrawer {

    private static const rect0:Rectangle = new Rectangle(0, 0, 4, 4);

    private static const p0:Point = new Point(0, 0);

    private static const rect1:Rectangle = new Rectangle(4, 0, 4, 4);

    private static const p1:Point = new Point(4, 0);

    private static const rect2:Rectangle = new Rectangle(0, 4, 4, 4);

    private static const p2:Point = new Point(0, 4);

    private static const rect3:Rectangle = new Rectangle(4, 4, 4, 4);

    private static const p3:Point = new Point(4, 4);

    private static const INNER:int = 0;

    private static const SIDE0:int = 1;

    private static const SIDE1:int = 2;

    private static const OUTER:int = 3;

    private static const INNERP1:int = 4;

    private static const INNERP2:int = 5;

    private static const mlist_:Vector.<Vector.<ImageSet>> = getMasks();
    private static const RECT01:Rectangle = new Rectangle(0, 0, 8, 4);
    private static const RECT13:Rectangle = new Rectangle(4, 0, 4, 8);
    private static const RECT23:Rectangle = new Rectangle(0, 4, 8, 4);
    private static const RECT02:Rectangle = new Rectangle(0, 0, 4, 8);
    private static const RECT0:Rectangle = new Rectangle(0, 0, 4, 4);
    private static const RECT1:Rectangle = new Rectangle(4, 0, 4, 4);
    private static const RECT2:Rectangle = new Rectangle(0, 4, 4, 4);
    private static const RECT3:Rectangle = new Rectangle(4, 4, 4, 4);
    private static const POINT0:Point = new Point(0, 0);
    private static const POINT1:Point = new Point(4, 0);
    private static const POINT2:Point = new Point(0, 4);
    private static const POINT3:Point = new Point(4, 4);
    private static var cache__:Dictionary = new Dictionary();
    private static var cache_:Vector.<Object> = new <Object>[null, {}];

    public static function clearCache() : void {
        var _loc3_:int = 0;
        var _loc2_:* = cache__;
        for each(var _loc1_ in cache__) {
            _loc1_ && _loc1_.dispose();
        }
        cache__ = new Dictionary();
    }

    public static function redraw(param1:Square, param2:Boolean) : BitmapData {
        var _loc4_:Boolean = false;
        var _loc9_:Boolean = false;
        var _loc3_:Boolean = false;
        var _loc7_:* = null;
        var _loc6_:* = null;
        var _loc5_:* = param1.tileType_ == 253;
        if(_loc5_) {
            _loc7_ = getCompositeSig(param1);
        } else if(param1.props_.hasEdge_) {
            _loc7_ = getEdgeSig(param1);
        } else {
            _loc7_ = getSig(param1);
        }
        if(_loc7_ == null) {
            return null;
        }
        if(_loc7_ in cache__) {
            return cache__[_loc7_];
        }
        if(_loc5_) {
            _loc6_ = buildComposite(_loc7_);
            cache__[_loc7_] = _loc6_;
            return _loc6_;
        }
        if(param1.props_.hasEdge_) {
            _loc6_ = drawEdges(_loc7_);
            cache__[_loc7_] = _loc6_;
            return _loc6_;
        }
        var _loc10_:uint = _loc7_[4];
        if(_loc7_[1] != _loc10_) {
            _loc5_ = true;
            _loc4_ = true;
        }
        if(_loc7_[3] != _loc10_) {
            _loc5_ = true;
            _loc9_ = true;
        }
        if(_loc7_[5] != _loc10_) {
            _loc4_ = true;
            _loc3_ = true;
        }
        if(_loc7_[7] != _loc10_) {
            _loc9_ = true;
            _loc3_ = true;
        }
        if(!_loc5_ && _loc7_[0] != _loc10_) {
            _loc5_ = true;
        }
        if(!_loc4_ && _loc7_[2] != _loc10_) {
            _loc4_ = true;
        }
        if(!_loc9_ && _loc7_[6] != _loc10_) {
            _loc9_ = true;
        }
        if(!_loc3_ && _loc7_[8] != _loc10_) {
            _loc3_ = true;
        }
        if(!_loc5_ && !_loc4_ && !_loc9_ && !_loc3_) {
            cache__[_loc7_] = null;
            return null;
        }
        var _loc8_:BitmapData = GroundLibrary.getBitmapData(param1.tileType_);
        if(param2) {
            _loc6_ = _loc8_.clone();
        } else {
            _loc6_ = new BitmapData(_loc8_.width,_loc8_.height,true,0);
        }
        if(_loc5_) {
            redrawRect(_loc6_,rect0,p0,mlist_[0],_loc10_,_loc7_[3],_loc7_[0],_loc7_[1]);
        }
        if(_loc4_) {
            redrawRect(_loc6_,rect1,p1,mlist_[1],_loc10_,_loc7_[1],_loc7_[2],_loc7_[5]);
        }
        if(_loc9_) {
            redrawRect(_loc6_,rect2,p2,mlist_[2],_loc10_,_loc7_[7],_loc7_[6],_loc7_[3]);
        }
        if(_loc3_) {
            redrawRect(_loc6_,rect3,p3,mlist_[3],_loc10_,_loc7_[5],_loc7_[8],_loc7_[7]);
        }
        cache__[_loc7_] = _loc6_;
        _loc7_.length = 0;
        return _loc6_;
    }

    private static function redrawRect(bitmapData:BitmapData, rect:Rectangle, p:Point, masks:Vector.<ImageSet>, base:uint, n0:uint, n1:uint, n2:uint):void {
        var blend:BitmapData = null;
        var mask:BitmapData = null;
        if (base == n0 && base == n2) {
            mask = masks[OUTER].random();
            blend = GroundLibrary.getBitmapData(n1);
        } else if (base != n0 && base != n2) {
            if (n0 != n2) {
                bitmapData.copyPixels(GroundLibrary.getBitmapData(n0), rect, p, masks[INNERP1].random(), p0, true);
                bitmapData.copyPixels(GroundLibrary.getBitmapData(n2), rect, p, masks[INNERP2].random(), p0, true);
                return;
            }
            mask = masks[INNER].random();
            blend = GroundLibrary.getBitmapData(n0);
        } else if (base != n0) {
            mask = masks[SIDE0].random();
            blend = GroundLibrary.getBitmapData(n0);
        } else {
            mask = masks[SIDE1].random();
            blend = GroundLibrary.getBitmapData(n2);
        }
        bitmapData.copyPixels(blend, rect, p, mask, p0, true);
    }

    private static function getSig(square:Square):ByteArray {
        var x:int = 0;
        var n:Square = null;
        var sig:ByteArray = new ByteArray();
        var map:Map = square.map_;
        var baseType:uint = square.tileType_;
        for (var y:int = square.y_ - 1; y <= square.y_ + 1; y++) {
            for (x = square.x_ - 1; x <= square.x_ + 1; x++) {
                if (x < 0 || x >= map.width_ || y < 0 || y >= map.height_ || x == square.x_ && y == square.y_) {
                    sig.writeByte(baseType);
                } else {
                    n = map.squares_[x + y * map.width_];
                    if (n == null || n.props_.blendPriority_ <= square.props_.blendPriority_) {
                        sig.writeByte(baseType);
                    } else {
                        sig.writeByte(n.tileType_);
                    }
                }
            }
        }
        return sig;
    }

    private static function getMasks():Vector.<Vector.<ImageSet>> {
        var mlist:Vector.<Vector.<ImageSet>> = new Vector.<Vector.<ImageSet>>();
        addMasks(mlist, AssetLibrary.getImageSet("inner_mask"), AssetLibrary.getImageSet("sides_mask"), AssetLibrary.getImageSet("outer_mask"), AssetLibrary.getImageSet("innerP1_mask"), AssetLibrary.getImageSet("innerP2_mask"));
        return mlist;
    }

    private static function addMasks(mlist:Vector.<Vector.<ImageSet>>, inner:ImageSet, side:ImageSet, outer:ImageSet, innerP1:ImageSet, innerP2:ImageSet):void {
        var i:int = 0;
        for each(i in [-1, 0, 2, 1]) {
            mlist.push(new <ImageSet>[rotateImageSet(inner, i), rotateImageSet(side, i - 1), rotateImageSet(side, i), rotateImageSet(outer, i), rotateImageSet(innerP1, i), rotateImageSet(innerP2, i)]);
        }
    }

    private static function rotateImageSet(imageSet:ImageSet, clockwiseTurns:int):ImageSet {
        var bitmapData:BitmapData = null;
        var newImageSet:ImageSet = new ImageSet();
        for each(bitmapData in imageSet.images_) {
            newImageSet.add(BitmapUtil.rotateBitmapData(bitmapData, clockwiseTurns));
        }
        return newImageSet;
    }

    private static function getCompositeSig(square:Square):ByteArray {
        var n0:Square = null;
        var n2:Square = null;
        var n6:Square = null;
        var n8:Square = null;
        var sig:ByteArray = new ByteArray();
        sig.length = 4;
        var map:Map = square.map_;
        var x:int = square.x_;
        var y:int = square.y_;
        var n1:Square = map.lookupSquare(x, y - 1);
        var n3:Square = map.lookupSquare(x - 1, y);
        var n5:Square = map.lookupSquare(x + 1, y);
        var n7:Square = map.lookupSquare(x, y + 1);
        var p1:int = n1 != null ? int(int(n1.props_.compositePriority_)) : int(int(-1));
        var p3:int = n3 != null ? int(int(n3.props_.compositePriority_)) : int(int(-1));
        var p5:int = n5 != null ? int(int(n5.props_.compositePriority_)) : int(int(-1));
        var p7:int = n7 != null ? int(int(n7.props_.compositePriority_)) : int(int(-1));
        if (p1 < 0 && p3 < 0) {
            n0 = map.lookupSquare(x - 1, y - 1);
            sig[0] = n0 == null || n0.props_.compositePriority_ < 0 ? 255 : n0.tileType_;
        } else if (p1 < p3) {
            sig[0] = n3.tileType_;
        } else {
            sig[0] = n1.tileType_;
        }
        if (p1 < 0 && p5 < 0) {
            n2 = map.lookupSquare(x + 1, y - 1);
            sig[1] = n2 == null || n2.props_.compositePriority_ < 0 ? 255 : n2.tileType_;
        } else if (p1 < p5) {
            sig[1] = n5.tileType_;
        } else {
            sig[1] = n1.tileType_;
        }
        if (p3 < 0 && p7 < 0) {
            n6 = map.lookupSquare(x - 1, y + 1);
            sig[2] = n6 == null || n6.props_.compositePriority_ < 0 ? 255 : n6.tileType_;
        } else if (p3 < p7) {
            sig[2] = n7.tileType_;
        } else {
            sig[2] = n3.tileType_;
        }
        if (p5 < 0 && p7 < 0) {
            n8 = map.lookupSquare(x + 1, y + 1);
            sig[3] = n8 == null || n8.props_.compositePriority_ < 0 ? 255 : n8.tileType_;
        } else if (p5 < p7) {
            sig[3] = n7.tileType_;
        } else {
            sig[3] = n5.tileType_;
        }
        return sig;
    }

    private static function buildComposite(sig:ByteArray):BitmapData {
        var neighbor:BitmapData = null;
        var newBitmapData:BitmapData = new BitmapData(8, 8, false, 0);
        if (sig[0] != 255) {
            neighbor = GroundLibrary.getBitmapData(sig[0]);
            newBitmapData.copyPixels(neighbor, RECT0, POINT0);
        }
        if (sig[1] != 255) {
            neighbor = GroundLibrary.getBitmapData(sig[1]);
            newBitmapData.copyPixels(neighbor, RECT1, POINT1);
        }
        if (sig[2] != 255) {
            neighbor = GroundLibrary.getBitmapData(sig[2]);
            newBitmapData.copyPixels(neighbor, RECT2, POINT2);
        }
        if (sig[3] != 255) {
            neighbor = GroundLibrary.getBitmapData(sig[3]);
            newBitmapData.copyPixels(neighbor, RECT3, POINT3);
        }
        return newBitmapData;
    }

    private static function getEdgeSig(square:Square):ByteArray {
        var x:int = 0;
        var n:Square = null;
        var b:Boolean = false;
        var sig:ByteArray = new ByteArray();
        var map:Map = square.map_;
        var hasEdge:Boolean = false;
        var sameTypeEdgeMode:Boolean = square.props_.sameTypeEdgeMode_;
        for (var y:int = square.y_ - 1; y <= square.y_ + 1; y++) {
            for (x = square.x_ - 1; x <= square.x_ + 1; x++) {
                n = map.lookupSquare(x, y);
                if (x == square.x_ && y == square.y_) {
                    sig.writeByte(n.tileType_);
                } else {
                    if (sameTypeEdgeMode) {
                        b = n == null || n.tileType_ == square.tileType_;
                    } else {
                        b = n == null || n.tileType_ != 255;
                    }
                    sig.writeBoolean(b);
                    hasEdge = hasEdge || !b;
                }
            }
        }
        return !!hasEdge ? sig : null;
    }

    private static function drawEdges(sig:ByteArray):BitmapData {
        var orig:BitmapData = GroundLibrary.getBitmapData(sig[4]);
        var newBitmapData:BitmapData = orig.clone();
        var props:GroundProperties = GroundLibrary.propsLibrary_[sig[4]];
        var edges:Vector.<BitmapData> = props.getEdges();
        var innerCorners:Vector.<BitmapData> = props.getInnerCorners();
        for (var i:int = 1; i < 8; i = i + 2) {
            if (!sig[i]) {
                newBitmapData.copyPixels(edges[i], edges[i].rect, PointUtil.ORIGIN, null, null, true);
            }
        }
        if (edges[0] != null) {
            if (sig[3] && sig[1] && !sig[0]) {
                newBitmapData.copyPixels(edges[0], edges[0].rect, PointUtil.ORIGIN, null, null, true);
            }
            if (sig[1] && sig[5] && !sig[2]) {
                newBitmapData.copyPixels(edges[2], edges[2].rect, PointUtil.ORIGIN, null, null, true);
            }
            if (sig[5] && sig[7] && !sig[8]) {
                newBitmapData.copyPixels(edges[8], edges[8].rect, PointUtil.ORIGIN, null, null, true);
            }
            if (sig[3] && sig[7] && !sig[6]) {
                newBitmapData.copyPixels(edges[6], edges[6].rect, PointUtil.ORIGIN, null, null, true);
            }
        }
        if (innerCorners != null) {
            if (!sig[3] && !sig[1]) {
                newBitmapData.copyPixels(innerCorners[0], innerCorners[0].rect, PointUtil.ORIGIN, null, null, true);
            }
            if (!sig[1] && !sig[5]) {
                newBitmapData.copyPixels(innerCorners[2], innerCorners[2].rect, PointUtil.ORIGIN, null, null, true);
            }
            if (!sig[5] && !sig[7]) {
                newBitmapData.copyPixels(innerCorners[8], innerCorners[8].rect, PointUtil.ORIGIN, null, null, true);
            }
            if (!sig[3] && !sig[7]) {
                newBitmapData.copyPixels(innerCorners[6], innerCorners[6].rect, PointUtil.ORIGIN, null, null, true);
            }
        }
        return newBitmapData;
    }

    public function TileRedrawer() {
        super();
    }
}
}
