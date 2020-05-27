package com.company.assembleegameclient.map {
import com.company.assembleegameclient.background.Background;
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.map.mapoverlay.MapOverlay;
import com.company.assembleegameclient.map.partyoverlay.PartyOverlay;
import com.company.assembleegameclient.objects.BasicObject;
import com.company.assembleegameclient.objects.Container;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Party;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.ConditionEffect;

import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.display.Sprite;
import flash.display3D.Context3D;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.stage3D.GraphicsFillExtra;
import kabam.rotmg.stage3D.Object3D.Object3DStage3D;
import kabam.rotmg.stage3D.Render3D;
import kabam.rotmg.stage3D.Renderer;
import kabam.rotmg.stage3D.Stage3DConfig;
import kabam.rotmg.stage3D.graphic3D.Program3DFactory;
import kabam.rotmg.stage3D.graphic3D.TextureFactory;

import org.osflash.signals.Signal;

public class Map extends Sprite {

    public static const NEXUS:String = "Nexus";

    private static const VISIBLE_SORT_FIELDS:Array = ["sortVal_", "objectId_"];

    private static const VISIBLE_SORT_PARAMS:Array = [Array.NUMERIC, Array.NUMERIC];

    protected static const BLIND_FILTER:ColorMatrixFilter = new ColorMatrixFilter([0.05, 0.05, 0.05, 0, 0, 0.05, 0.05, 0.05, 0, 0, 0.05, 0.05, 0.05, 0, 0, 0.05, 0.05, 0.05, 1, 0]);

    protected static var BREATH_CT:ColorTransform = new ColorTransform(255 / 255, 55 / 255, 0 / 255, 0);

    public function Map(gs:GameSprite) {
        this.map_ = new Sprite();
        this.squareList_ = new Vector.<Square>();
        this.squares_ = new Vector.<Square>();
        this.goDict_ = new Dictionary();
        this.boDict_ = new Dictionary();
        this.merchLookup_ = {};
        this.objsToAdd_ = new Vector.<BasicObject>();
        this.idsToRemove_ = new Vector.<int>();
        this.graphicsData_ = new Vector.<IGraphicsData>();
        this.graphicsDataStageSoftware_ = new Vector.<IGraphicsData>();
        this.graphicsData3d_ = new Vector.<Object3DStage3D>();
        this.visible_ = [];
        this.visibleUnder_ = [];
        this.visibleSquares_ = new Vector.<Square>();
        this.topSquares_ = new Vector.<Square>();
        super();
        this.gs_ = gs;
        this.hurtOverlay_ = new HurtOverlay();
        this.gradientOverlay_ = new GradientOverlay();
        this.mapOverlay_ = new MapOverlay();
        this.partyOverlay_ = new PartyOverlay(this);
        this.party_ = new Party(this);
        this.quest_ = new Quest(this);
        this.signalRenderSwitch = new Signal();
        this.visibleEnemies = new Vector.<GameObject>();
        this.visiblePlayers = new Vector.<GameObject>();
        this.consumableContainers = new Vector.<GameObject>();
        this.nonConsumableContainers = new Vector.<GameObject>();
        this.wasLastFrameGpu = Parameters.isGpuRender();
        Parameters.GPURenderFrame = this.wasLastFrameGpu;
    }
    public var gs_:GameSprite;

    public var width_:int;

    public var height_:int;

    public var name_:String;

    public var back_:int;

    public var allowPlayerTeleport_:Boolean;

    public var showDisplays_:Boolean;

    public var background_:Background = null;

    public var map_:Sprite;

    public var hurtOverlay_:HurtOverlay = null;

    public var gradientOverlay_:GradientOverlay = null;

    public var mapOverlay_:MapOverlay = null;

    public var partyOverlay_:PartyOverlay = null;

    public var squareList_:Vector.<Square>;

    public var squares_:Vector.<Square>;

    public var goDict_:Dictionary;

    public var boDict_:Dictionary;

    public var merchLookup_:Object;

    public var player_:Player = null;

    public var party_:Party = null;

    public var quest_:Quest = null;
    public var visible_:Array;
    public var visibleUnder_:Array;
    public var visibleSquares_:Vector.<Square>;
    public var topSquares_:Vector.<Square>;
    public var signalRenderSwitch:Signal;
    public var wasLastFrameGpu:Boolean = false;
    public var visibleEnemies:Vector.<GameObject>;
    public var visiblePlayers:Vector.<GameObject>;
    public var consumableContainers:Vector.<GameObject>;
    public var nonConsumableContainers:Vector.<GameObject>;
    private var inUpdate_:Boolean = false;
    private var objsToAdd_:Vector.<BasicObject>;
    private var idsToRemove_:Vector.<int>;
    private var graphicsData_:Vector.<IGraphicsData>;
    private var graphicsDataStageSoftware_:Vector.<IGraphicsData>;
    private var graphicsData3d_:Vector.<Object3DStage3D>;
    private var lastSoftwareClear:Boolean = false;

    public function setProps(width:int, height:int, name:String, back:int, allowPlayerTeleport:Boolean, showDisplays:Boolean):void {
        this.width_ = width;
        this.height_ = height;
        this.name_ = name;
        this.back_ = back;
        this.allowPlayerTeleport_ = allowPlayerTeleport;
        this.showDisplays_ = showDisplays;
    }

    public function initialize():void {
        this.squares_.length = this.width_ * this.height_;
        this.background_ = Background.getBackground(this.back_);
        if (this.background_ != null) {
            addChild(this.background_);
        }
        addChild(this.map_);
        addChild(this.hurtOverlay_);
        addChild(this.gradientOverlay_);
        addChild(this.mapOverlay_);
        addChild(this.partyOverlay_);
    }

    public function dispose():void {
        var square:Square = null;
        var go:GameObject = null;
        var bo:BasicObject = null;
        this.gs_ = null;
        this.background_ = null;
        this.map_ = null;
        this.hurtOverlay_ = null;
        this.gradientOverlay_ = null;
        this.mapOverlay_ = null;
        this.partyOverlay_ = null;
        for each(square in this.squareList_) {
            square.dispose();
        }
        this.squareList_.length = 0;
        this.squareList_ = null;
        this.squares_.length = 0;
        this.squares_ = null;
        for each(go in this.goDict_) {
            go.dispose();
        }
        this.goDict_ = null;
        for each(bo in this.boDict_) {
            bo.dispose();
        }
        this.boDict_ = null;
        this.merchLookup_ = null;
        this.player_ = null;
        this.party_ = null;
        this.quest_ = null;
        this.objsToAdd_ = null;
        this.idsToRemove_ = null;
        this.visiblePlayers.length = 0;
        this.visibleEnemies.length = 0;
        this.consumableContainers.length = 0;
        this.nonConsumableContainers.length = 0;
        this.visiblePlayers = null;
        this.visibleEnemies = null;
        this.consumableContainers = null;
        this.nonConsumableContainers = null;
        TextureFactory.disposeTextures();
        GraphicsFillExtra.dispose();
        Program3DFactory.getInstance().dispose();
    }

    public function update(time:int, dt:int):void {
        var bo:BasicObject = null;
        var go:GameObject = null;
        var objId:int = 0;
        this.inUpdate_ = true;
        this.visiblePlayers.length = 0;
        this.visibleEnemies.length = 0;
        for each(go in this.goDict_) {
            if (!go.update(time, dt)) {
                this.idsToRemove_.push(go.objectId_);
            } else if (go.props_.isEnemy_) {
                if (!go.isUntargetable()) {
                    this.visibleEnemies.push(go);
                }
            } else if (go.props_.isPlayer_) {
                if (!go.isUntargetable()) {
                    this.visiblePlayers.push(go);
                }
            } else if (go is Container) {
                if (this.consumableContainers.indexOf(go) != -1
                        || this.nonConsumableContainers.indexOf(go) != -1)
                    continue;

                var equip:Vector.<int> = (go as Container).equipment_;
                var cont:Boolean = false;
                for each (var i:int in equip) {
                    var xml:XML = ObjectLibrary.xmlLibrary_[i];
                    if (!cont && xml && (xml.hasOwnProperty("Consumable")
                            || xml.hasOwnProperty("Activate") &&
                            (xml.Activate == "ItemDust"
                                    || xml.Activate == "MiscellaneousDust"
                                    || xml.Activate == "PotionDust"
                                    || xml.Activate == "SpecialDust"))) {
                        this.consumableContainers.push(go);
                        cont = true;
                    }
                }

                if (cont) continue;

                this.nonConsumableContainers.push(go);
            }
        }
        for each(bo in this.boDict_) {
            if (!bo.update(time, dt)) {
                this.idsToRemove_.push(bo.objectId_);
            }
        }
        this.inUpdate_ = false;
        for each(bo in this.objsToAdd_) {
            this.internalAddObj(bo);
        }
        this.objsToAdd_.length = 0;
        for each(objId in this.idsToRemove_) {
            this.internalRemoveObj(objId);
        }
        this.idsToRemove_.length = 0;
        this.party_.update(time, dt);
    }

    public function pSTopW(xS:Number, yS:Number):Point {
        var square:Square = null;
        var p:Point = null;
        for each(square in this.visibleSquares_) {
            if (square.faces_.length != 0 && square.faces_[0].face_.contains(xS, yS)) {
                return new Point(square.center_.x, square.center_.y);
            }
        }
        return null;
    }

    public function setGroundTile(x:int, y:int, tileType:uint):void {
        var yi:int = 0;
        var ind:int = 0;
        var n:Square = null;
        var square:Square = this.getSquare(x, y);
        square.setTileType(tileType);
        var xend:int = x < this.width_ - 1 ? int(int(x + 1)) : int(int(x));
        var yend:int = y < this.height_ - 1 ? int(int(y + 1)) : int(int(y));
        for (var xi:int = x > 0 ? int(int(x - 1)) : int(int(x)); xi <= xend; xi++) {
            for (yi = y > 0 ? int(int(y - 1)) : int(int(y)); yi <= yend; yi++) {
                ind = xi + yi * this.width_;
                n = this.squares_[ind];
                if (n != null && (n.props_.hasEdge_ || n.tileType_ != tileType)) {
                    n.faces_.length = 0;
                }
            }
        }
    }

    public function addObj(bo:BasicObject, posX:Number, posY:Number):void {
        if (bo == null)
            return;

        bo.x_ = posX;
        bo.y_ = posY;
        if (this.inUpdate_) {
            this.objsToAdd_.push(bo);
        } else {
            this.internalAddObj(bo);
        }
    }

    public function internalAddObj(bo:BasicObject):void {
        if (!bo.addTo(this, bo.x_, bo.y_)) {
            trace("ERROR: adding: " + bo);
            return;
        }
        var dict:Dictionary = bo is GameObject ? this.goDict_ : this.boDict_;
        if (dict[bo.objectId_] != null)
            return;

        dict[bo.objectId_] = bo;
    }

    public function removeObj(objectId:int):void {
        if (this.inUpdate_) {
            this.idsToRemove_.push(objectId);
        } else {
            this.internalRemoveObj(objectId);
        }
    }

    public function internalRemoveObj(objectId:int):void {
        var dict:Dictionary = this.goDict_;
        var bo:BasicObject = dict[objectId];
        if (bo == null) {
            dict = this.boDict_;
            bo = dict[objectId];
            if (bo == null) {
                return;
            }
        }
        bo.removeFromMap();
        delete dict[objectId];
    }

    public function getSquare(posX:Number, posY:Number):Square {
        if (posX < 0 || posX >= this.width_ || posY < 0 || posY >= this.height_) {
            return null;
        }
        var ind:int = int(posX) + int(posY) * this.width_;
        var square:Square = this.squares_[ind];
        if (square == null) {
            square = new Square(this, int(posX), int(posY));
            this.squares_[ind] = square;
            this.squareList_.push(square);
        }
        return square;
    }

    public function lookupSquare(x:int, y:int):Square {
        if (x < 0 || x >= this.width_ || y < 0 || y >= this.height_) {
            return null;
        }
        return this.squares_[x + y * this.width_];
    }

    public function correctMapView(camera:Camera):Point {
        var clipRect:Rectangle = camera.clipRect_;
        if (Parameters.data.FS) {
            x = -clipRect.x * 800 / (WebMain.sWidth / Number(Parameters.data.mscale));
            y = -clipRect.y * 600 / (WebMain.sHeight / Number(Parameters.data.mscale));
        } else {
            x = -clipRect.x * Number(Parameters.data.mscale);
            y = -clipRect.y * Number(Parameters.data.mscale);
        }
        var clipWidth:Number = (-clipRect.x - clipRect.width / 2) / 50;
        var clipHeight:Number = (-clipRect.y - clipRect.height / 2) / 50;
        var clipSqrt:Number = Math.sqrt(clipWidth * clipWidth + clipHeight * clipHeight);
        var clipAngle:Number = camera.angleRad_ - Math.PI / 2 - Math.atan2(clipWidth, clipHeight);
        return new Point(camera.x_ + clipSqrt * Math.cos(clipAngle), camera.y_ + clipSqrt * Math.sin(clipAngle));
    }

    public function draw(camera:Camera, time:int):void {
        var context:Context3D = null;
        var filters:Array = null;
        var isGpuRender:Boolean = Parameters.isGpuRender();
        Parameters.GPURenderFrame = isGpuRender;
        if (this.wasLastFrameGpu != isGpuRender) {
            context = WebMain.STAGE.stage3Ds[0].context3D;
            if (this.wasLastFrameGpu && context != null) {
                context.clear();
                context.present();
            } else {
                this.map_.graphics.clear();
            }
            this.signalRenderSwitch.dispatch(this.wasLastFrameGpu);
            this.wasLastFrameGpu = isGpuRender;
        }
        var screenRect:Rectangle = camera.clipRect_;
        x = -screenRect.x * 800 / WebMain.STAGE.stageWidth * Number(Parameters.data.mscale);
        y = -screenRect.y * 600 / WebMain.STAGE.stageHeight * Number(Parameters.data.mscale);
        if (Parameters.GPURenderFrame) {
            WebMain.STAGE.stage3Ds[0].x = 400 - WebMain.STAGE.stageWidth / 2;
            WebMain.STAGE.stage3Ds[0].y = 300 - WebMain.STAGE.stageHeight / 2;
        }
        var filter:uint = 0;
        var render3D:Render3D = null;
        var i:int = 0;
        var square:Square = null;
        var go:GameObject = null;
        var bo:BasicObject = null;
        var yi:int = 0;
        var b:Number = NaN;
        var t:Number = NaN;
        var d:Number = NaN;
        if (this.background_ != null) {
            this.background_.draw(camera, time);
        }
        this.visible_.length = 0;
        this.visibleUnder_.length = 0;
        this.visibleSquares_.length = 0;
        this.topSquares_.length = 0;
        this.graphicsData_.length = 0;
        this.graphicsDataStageSoftware_.length = 0;
        this.graphicsData3d_.length = 0;
        for (var xi:int = -15; xi <= 15; xi++) {
            for (yi = -15; yi <= 15; yi++) {
                if (xi * xi + yi * yi <= 225) {
                    square = this.lookupSquare(xi + this.player_.x_, yi + this.player_.y_);
                    if (square != null) {
                        square.lastVisible_ = time;
                        square.draw(this.graphicsData_, camera, time);
                        this.visibleSquares_.push(square);
                        if (square.topFace_ != null) {
                            this.topSquares_.push(square);
                        }
                    }
                }
            }
        }
        for each(go in this.goDict_) {
            go.drawn_ = false;
            if (!go.dead_) {
                square = go.square_;
                if (!(square == null || square.lastVisible_ != time)) {
                    go.drawn_ = true;
                    go.computeSortVal(camera);
                    if (go.props_.drawUnder_) {
                        if (go.props_.drawOnGround_) {
                            go.draw(this.graphicsData_, camera, time);
                        } else {
                            this.visibleUnder_.push(go);
                        }
                    } else {
                        this.visible_.push(go);
                    }
                }
            }
        }
        for each(bo in this.boDict_) {
            bo.drawn_ = false;
            square = bo.square_;
            if (!(square == null || square.lastVisible_ != time)) {
                bo.drawn_ = true;
                bo.computeSortVal(camera);
                this.visible_.push(bo);
            }
        }
        if (this.visibleUnder_.length > 0) {
            this.visibleUnder_.sortOn(VISIBLE_SORT_FIELDS, VISIBLE_SORT_PARAMS);
            for each(bo in this.visibleUnder_) {
                bo.draw(this.graphicsData_, camera, time);
            }
        }
        this.visible_.sortOn(VISIBLE_SORT_FIELDS, VISIBLE_SORT_PARAMS);
        if (Parameters.data.drawShadows) {
            for each(bo in this.visible_) {
                if (bo.hasShadow_) {
                    bo.drawShadow(this.graphicsData_, camera, time);
                }
            }
        }
        for each(bo in this.visible_) {
            bo.draw(this.graphicsData_, camera, time);
            if (isGpuRender) {
                bo.draw3d(this.graphicsData3d_);
            }
        }
        if (this.topSquares_.length > 0) {
            for each(square in this.topSquares_) {
                square.drawTop(this.graphicsData_, camera, time);
            }
        }
        if (this.player_ != null && this.player_.breath_ >= 0 && this.player_.breath_ < Parameters.BREATH_THRESH) {
            b = (Parameters.BREATH_THRESH - this.player_.breath_) / Parameters.BREATH_THRESH;
            t = Math.abs(Math.sin(time / 300)) * 0.75;
            BREATH_CT.alphaMultiplier = b * t;
            this.hurtOverlay_.transform.colorTransform = BREATH_CT;
            this.hurtOverlay_.visible = true;
            this.hurtOverlay_.x = screenRect.left;
            this.hurtOverlay_.y = screenRect.top;
        } else {
            this.hurtOverlay_.visible = false;
        }
        if (this.player_ != null) {
            this.gradientOverlay_.visible = true;
            this.gradientOverlay_.x = screenRect.right - 10;
            this.gradientOverlay_.y = screenRect.top;
        } else {
            this.gradientOverlay_.visible = false;
        }
        if (isGpuRender && Renderer.inGame) {
            filter = this.getFilterIndex();
            render3D = StaticInjectorContext.getInjector().getInstance(Render3D);
            render3D.dispatch(this.graphicsData_, filter);
            for (i = 0; i < this.graphicsData_.length; i++) {
                if (this.graphicsData_[i] is GraphicsBitmapFill && GraphicsFillExtra.isSoftwareDraw(GraphicsBitmapFill(this.graphicsData_[i]))) {
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 1]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 2]);
                } else if (this.graphicsData_[i] is GraphicsSolidFill && GraphicsFillExtra.isSoftwareDrawSolid(GraphicsSolidFill(this.graphicsData_[i]))) {
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 1]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[i + 2]);
                }
            }
            if (this.graphicsDataStageSoftware_.length > 0) {
                this.map_.graphics.clear();
                this.map_.graphics.drawGraphicsData(this.graphicsDataStageSoftware_);
                if (this.lastSoftwareClear) {
                    this.lastSoftwareClear = false;
                }
            } else if (!this.lastSoftwareClear) {
                this.map_.graphics.clear();
                this.lastSoftwareClear = true;
            }
            if (time % 149 == 0) {
                GraphicsFillExtra.manageSize();
            }
        } else {
            this.map_.graphics.clear();
            this.map_.graphics.drawGraphicsData(this.graphicsData_);
        }

        if (!Parameters.isGpuRender()) {
            this.map_.filters.length = 0;
            if (this.player_ != null && (this.player_.condition_[0] & ConditionEffect.MAP_FILTER_BITMASK) != 0) {
                filters = [];
                if (this.player_.isDrunk()) {
                    d = 20 + 10 * Math.sin(time / 1000);
                    filters.push(new BlurFilter(d, d));
                }
                if (this.player_.isBlind()) {
                    filters.push(BLIND_FILTER);
                }
                this.map_.filters = filters;
            } else if (this.map_.filters.length > 0) {
                this.map_.filters = [];
            }
        }

        this.mapOverlay_.draw(camera, time);
        this.partyOverlay_.draw(camera, time);
    }

    private function getFilterIndex():uint {
        var filterIndex:uint = 0;
        if (this.player_ != null && (this.player_.condition_[0] & ConditionEffect.MAP_FILTER_BITMASK) != 0) {
            if (this.player_.isPaused()) {
                filterIndex = Renderer.STAGE3D_FILTER_PAUSE;
            } else if (this.player_.isBlind()) {
                filterIndex = Renderer.STAGE3D_FILTER_BLIND;
            } else if (this.player_.isDrunk()) {
                filterIndex = Renderer.STAGE3D_FILTER_DRUNK;
            }
        }
        return filterIndex;
    }
}
}
