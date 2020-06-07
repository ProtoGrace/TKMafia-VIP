package com.company.assembleegameclient.game {
import com.company.assembleegameclient.map.Square;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.tutorial.Tutorial;
import com.company.assembleegameclient.tutorial.doneAction;
import com.company.assembleegameclient.ui.options.Options;
import com.company.util.KeyCodes;

import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import kabam.rotmg.constants.GeneralConstants;
import kabam.rotmg.constants.UseType;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.core.view.Layers;
import kabam.rotmg.game.model.AddTextLineVO;
import kabam.rotmg.game.model.PotionInventoryModel;
import kabam.rotmg.game.model.UseBuyPotionVO;
import kabam.rotmg.game.signals.AddTextLineSignal;
import kabam.rotmg.game.signals.SetTextBoxVisibilitySignal;
import kabam.rotmg.game.signals.UseBuyPotionSignal;
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.minimap.control.MiniMapZoomSignal;
import kabam.rotmg.ui.model.TabStripModel;
import kabam.rotmg.ui.signals.StatsTabHotKeyInputSignal;

import net.hires.debug.Stats;

import org.swiftsuspenders.Injector;

public class MapUserInput {

    private static const MOUSE_DOWN_WAIT_PERIOD:uint = 175;

    private static var arrowWarning_:Boolean = false;

    public function MapUserInput(gs:GameSprite) {
        this.stats_ = new Stats();
        super();
        this.gs_ = gs;
        this.mouseDownTimer = new Timer(MOUSE_DOWN_WAIT_PERIOD, 1);
        this.mouseDownTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onMouseDownWaitPeriodOver);
        this.gs_.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        this.gs_.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
        var injector:Injector = StaticInjectorContext.getInjector();
        this.addTextLine = injector.getInstance(AddTextLineSignal);
        this.setTextBoxVisibility = injector.getInstance(SetTextBoxVisibilitySignal);
        this.statsTabHotKeyInputSignal = injector.getInstance(StatsTabHotKeyInputSignal);
        this.miniMapZoom = injector.getInstance(MiniMapZoomSignal);
        this.useBuyPotionSignal = injector.getInstance(UseBuyPotionSignal);
        this.potionInventoryModel = injector.getInstance(PotionInventoryModel);
        this.tabStripModel = injector.getInstance(TabStripModel);
        this.layers = injector.getInstance(Layers);
        this.gs_.map.signalRenderSwitch.add(this.onRenderSwitch);
    }
    public var gs_:GameSprite;
    public var enablePlayerInput_:Boolean = true;
    public var setHotkeysInput_:Boolean = true;
    public var layers:Layers;
    private var stats_:Stats;
    private var moveLeft_:Boolean = false;
    private var moveRight_:Boolean = false;
    private var moveUp_:Boolean = false;
    private var moveDown_:Boolean = false;
    private var rotateLeft_:Boolean = false;
    private var rotateRight_:Boolean = false;
    public var mouseDown_:Boolean = false;
    public var autofire_:Boolean = false;
    private var specialKeyDown_:Boolean = false;
    private var mouseDownTimer:Timer;
    private var mouseDownCount:uint;
    private var addTextLine:AddTextLineSignal;
    private var setTextBoxVisibility:SetTextBoxVisibilitySignal;
    private var statsTabHotKeyInputSignal:StatsTabHotKeyInputSignal;
    private var miniMapZoom:MiniMapZoomSignal;
    private var useBuyPotionSignal:UseBuyPotionSignal;
    private var potionInventoryModel:PotionInventoryModel;
    private var tabStripModel:TabStripModel;

    public function clearInput():void {
        this.moveLeft_ = false;
        this.moveRight_ = false;
        this.moveUp_ = false;
        this.moveDown_ = false;
        this.rotateLeft_ = false;
        this.rotateRight_ = false;
        this.mouseDown_ = false;
        this.autofire_ = false;
        this.setPlayerMovement();
    }

    public function onRenderSwitch(wasLastGpu:Boolean):void {
        if (wasLastGpu) {
            this.gs_.stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
            this.gs_.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
            this.gs_.map.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
            this.gs_.map.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
        } else {
            this.gs_.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
            this.gs_.map.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
            this.gs_.stage.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
            this.gs_.stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
        }
    }

    public function setEnablePlayerInput(enable:Boolean):void {
        if (this.enablePlayerInput_ != enable) {
            this.enablePlayerInput_ = enable;
            this.clearInput();
        }
    }

    public function setEnableHotKeysInput(enable:Boolean):void {
        if (this.setHotkeysInput_ != enable) {
            this.setHotkeysInput_ = enable;
            this.clearInput();
        }
    }

    private function setPlayerMovement():void {
        var player:Player = this.gs_.map.player_;
        if (player != null) {
            if (this.enablePlayerInput_) {
                player.setRelativeMovement((!!this.rotateRight_ ? 1 : 0) - (!!this.rotateLeft_ ? 1 : 0), (!!this.moveRight_ ? 1 : 0) - (!!this.moveLeft_ ? 1 : 0), (!!this.moveDown_ ? 1 : 0) - (!!this.moveUp_ ? 1 : 0));
            } else {
                player.setRelativeMovement(0, 0, 0);
            }
        }
    }

    private function useItem(slot:int):void {
        if (this.tabStripModel.currentSelection == TabStripModel.BACKPACK) {
            slot = slot + GeneralConstants.NUM_INVENTORY_SLOTS;
        }
        var slotIndex:int = ObjectLibrary.getMatchingSlotIndex(this.gs_.map.player_.equipment_[slot], this.gs_.map.player_);
        if (slotIndex != -1) {
            GameServerConnection.instance.invSwap(this.gs_.map.player_, this.gs_.map.player_, slot, this.gs_.map.player_.equipment_[slot], this.gs_.map.player_, slotIndex, this.gs_.map.player_.equipment_[slotIndex]);
        } else {
            GameServerConnection.instance.useItem_new(this.gs_.map.player_, slot);
        }
    }

    private function togglePerformanceStats():void {
        if (this.gs_.contains(this.stats_)) {
            this.gs_.removeChild(this.stats_);
            this.gs_.removeChild(this.gs_.gsc_.jitterWatcher_);
            this.gs_.gsc_.disableJitterWatcher();
        } else {
            this.gs_.addChild(this.stats_);
            this.gs_.gsc_.enableJitterWatcher();
            this.gs_.gsc_.jitterWatcher_.y = this.stats_.height;
            this.gs_.addChild(this.gs_.gsc_.jitterWatcher_);
        }
    }

    public function disableRightClick(_arg1:MouseEvent):void {
    }

    private function onAddedToStage(event:Event):void {
        var stage:Stage = this.gs_.stage;
        stage.addEventListener(Event.ACTIVATE, this.onActivate);
        stage.addEventListener(Event.DEACTIVATE, this.onDeactivate);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
        stage.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
        if (Parameters.isGpuRender()) {
            stage.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
        } else {
            this.gs_.map.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
            this.gs_.map.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
        }
        stage.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
        stage.addEventListener(MouseEvent.RIGHT_CLICK, this.disableRightClick);
    }

    private function onRemovedFromStage(event:Event):void {
        var stage:Stage = this.gs_.stage;
        stage.removeEventListener(Event.ACTIVATE, this.onActivate);
        stage.removeEventListener(Event.DEACTIVATE, this.onDeactivate);
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
        stage.removeEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
        stage.removeEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
        if (Parameters.isGpuRender()) {
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
            stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
        } else {
            this.gs_.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
            this.gs_.map.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
        }
        stage.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
        stage.removeEventListener(MouseEvent.RIGHT_CLICK, this.disableRightClick);
    }

    private function onActivate(event:Event):void {
    }

    private function onDeactivate(event:Event):void {
        this.clearInput();
    }

    private function onMouseDown(event:MouseEvent):void {
        var mouseX:Number = NaN;
        var mouseY:Number = NaN;
        var angle:Number = NaN;
        var itemType:int = 0;
        var objectXML:XML = null;
        var player:Player = this.gs_.map.player_;
        if (player == null) {
            return;
        }
        if (this.mouseDownTimer.running == false) {
            this.mouseDownCount = 1;
            this.mouseDownTimer.start();
        } else {
            this.mouseDownCount++;
        }
        if (!this.enablePlayerInput_) {
            return;
        }
        if (event.shiftKey) {
            itemType = player.equipment_[1];
            if (itemType == -1) {
                return;
            }
            objectXML = ObjectLibrary.xmlLibrary_[itemType];
            if (objectXML == null || objectXML.hasOwnProperty("EndMpCost")) {
                return;
            }
            if (player.isUnstable() && !player.isUnstableImmune()) {
                mouseX = Math.random() * 600 - 300;
                mouseY = Math.random() * 600 - 325;
            } else {
                mouseX = this.gs_.map.mouseX;
                mouseY = this.gs_.map.mouseY;
            }
            if (Parameters.isGpuRender()) {
                if (event.currentTarget == event.target || event.target == this.gs_.map || event.target == this.gs_) {
                    player.useAltWeapon(mouseX, mouseY, UseType.START_USE);
                }
            } else {
                player.useAltWeapon(mouseX, mouseY, UseType.START_USE);
            }
            return;
        }
        doneAction(this.gs_, Tutorial.ATTACK_ACTION);
        if (Parameters.isGpuRender()) {
            if (event.currentTarget == event.target || event.target == this.gs_.map || event.target == this.gs_) {
                angle = Math.atan2(this.gs_.map.mouseY, this.gs_.map.mouseX);
            } else {
                return;
            }
        } else {
            angle = Math.atan2(this.gs_.map.mouseY, this.gs_.map.mouseX);
        }
        player.attemptAttackAngle(angle);
        this.mouseDown_ = true;
    }

    private function onMouseDownWaitPeriodOver(e:TimerEvent):void {
        var pt:Point = null;
        if (this.mouseDownCount > 1) {
            pt = this.gs_.map.pSTopW(this.gs_.map.mouseX, this.gs_.map.mouseY);
        }
    }

    private function onMouseUp(event:MouseEvent):void {
        this.mouseDown_ = false;
    }

    private function onMouseWheel(event:MouseEvent):void {
        if (event.delta > 0) {
            this.miniMapZoom.dispatch(MiniMapZoomSignal.IN);
        } else {
            this.miniMapZoom.dispatch(MiniMapZoomSignal.OUT);
        }
    }

    private function onEnterFrame(event:Event):void {
        var angle:Number = NaN;
        var player:Player = null;
        doneAction(this.gs_, Tutorial.UPDATE_ACTION);
        if (this.enablePlayerInput_ && (this.mouseDown_ || this.autofire_) || Parameters.data.AAOn) {
            player = this.gs_.map.player_;
            if (player != null) {
                if (player.isUnstable() && !player.isUnstableImmune()) {
                    player.attemptAttackAngle(Math.random() * 360);
                } else {
                    angle = Math.atan2(this.gs_.map.mouseY, this.gs_.map.mouseX);
                    player.attemptAttackAngle(angle);
                }
            }
        }
    }

    private function onKeyDown(event:KeyboardEvent):void {
        var success:Boolean = false;
        var square:Square = null;
        var stage:Stage = this.gs_.stage;
        if (!this.setHotkeysInput_) {
            return;
        }
        switch (event.keyCode) {
            case KeyCodes.F1:
            case KeyCodes.F2:
            case KeyCodes.F3:
            case KeyCodes.F4:
            case KeyCodes.F5:
            case KeyCodes.F6:
            case KeyCodes.F7:
            case KeyCodes.F8:
            case KeyCodes.F9:
            case KeyCodes.F10:
            case KeyCodes.F11:
            case KeyCodes.F12:
            case KeyCodes.INSERT:
                break;
            default:
                if (stage.focus != null) {
                    return;
                }
                break;
        }
        if (event.keyCode === Parameters.data.options) {
            this.clearInput();
            this.layers.overlay.addChild(new Options(this.gs_));
        }
        var player:Player = this.gs_.map.player_;
        if (player == null || this.gs_ == null || this.gs_.map == null) {
            return;
        }
        switch (event.keyCode) {
            case Parameters.data.sMultKey:
                switch(Parameters.data.sMult) {
                    case Parameters.data.sMultDefault:
                        Parameters.data.sMult = Parameters.data.sMultSwitch;
                        this.gs_.map.player_.levelUpEffect("Speed Multiplier: Switch");
                        Parameters.save();
                        break;
                    default:
                        Parameters.data.sMult = Parameters.data.sMultDefault;
                        this.gs_.map.player_.levelUpEffect("Speed Multiplier: Default");
                        Parameters.save();
                }
                break;
            case Parameters.data.projNoClipKey:
                Parameters.data.projNoClip = !Parameters.data.projNoClip;
                Parameters.save();
                this.gs_.map.player_.levelUpEffect(Parameters.data.projNoClip?"Projectile No-Clip: On":"Projectile No-Clip: Off");
                break;
            case Parameters.data.godmodeKey:
                Parameters.data.godmode = !Parameters.data.godmode;
                Parameters.save();
                this.gs_.map.player_.levelUpEffect(Parameters.data.godmode?"Godmode: On":"Godmode: Off");
                break;
            case Parameters.data.ROFKey:
                Parameters.data.ROFHack = !Parameters.data.ROFHack;
                Parameters.save();
                this.gs_.map.player_.levelUpEffect(Parameters.data.ROFHack?"Increased ROF: On":"Increased ROF: Off");
                break;
            case Parameters.data.AAHotkey:
                Parameters.data.AAOn = !Parameters.data.AAOn;
                Parameters.save();
                this.gs_.map.player_.levelUpEffect(Parameters.data.AAOn?"Auto Aim: On":"Auto Aim: Off");
                break;
            case Parameters.data.AAModeHotkey:
                this.selectAimMode();
                break;
            case Parameters.data.killAuraKey:
                Parameters.data.killAura = !Parameters.data.killAura;
                Parameters.save();
                this.gs_.map.player_.levelUpEffect(Parameters.data.killAura?"Kill Aura: On":"Kill Aura: Off");
                break;
            case Parameters.data.tqDeathKey:
                Parameters.data.tqDeath = !Parameters.data.tqDeath;
                Parameters.save();
                this.gs_.map.player_.levelUpEffect(Parameters.data.tqDeath?"TQ on Death: On":"TQ on Death: Off");
                break;
            case Parameters.data.tqKey:
                var gameObj:GameObject = this.gs_.map.goDict_[this.gs_.map.quest_.objectId_];
                var yOffset:int = gameObj.getName() == "Hermit God" ? 5 : 0;
                this.gs_.map.player_.x_ = gameObj.x_;
                this.gs_.map.player_.y_ = gameObj.y_ + yOffset;
                this.gs_.map.player_.tq = true;
                break;
            case Parameters.data.autoDrinkKey:
                Parameters.data.autoDrink = !Parameters.data.autoDrink;
                Parameters.save();
                this.gs_.map.player_.levelUpEffect(Parameters.data.autoDrink ?
                        "Auto Consume: On" : "Auto Consume: Off");
                break;
            case Parameters.data.noClipKey:
                Parameters.data.noClip = !Parameters.data.noClip;
                Parameters.save();
                this.gs_.map.player_.levelUpEffect(Parameters.data.noClip ?
                        "No Clip: On" : "No Clip: Off");
                break;
            case Parameters.data.forgePotions:
                this.gs_.gsc_.forgePotions();
                break;
            case Parameters.data.moveUp:
                doneAction(this.gs_, Tutorial.MOVE_FORWARD_ACTION);
                this.moveUp_ = true;
                break;
            case Parameters.data.moveDown:
                doneAction(this.gs_, Tutorial.MOVE_BACKWARD_ACTION);
                this.moveDown_ = true;
                break;
            case Parameters.data.moveLeft:
                doneAction(this.gs_, Tutorial.MOVE_LEFT_ACTION);
                this.moveLeft_ = true;
                break;
            case Parameters.data.moveRight:
                doneAction(this.gs_, Tutorial.MOVE_RIGHT_ACTION);
                this.moveRight_ = true;
                break;
            case Parameters.data.rotateLeft:
                if (!Parameters.data.allowRotation) {
                    break;
                }
                doneAction(this.gs_, Tutorial.ROTATE_LEFT_ACTION);
                this.rotateLeft_ = true;
                break;
            case Parameters.data.rotateRight:
                if (!Parameters.data.allowRotation) {
                    break;
                }
                doneAction(this.gs_, Tutorial.ROTATE_RIGHT_ACTION);
                this.rotateRight_ = true;
                break;
            case Parameters.data.resetToDefaultCameraAngle:
                Parameters.data.cameraAngle = Parameters.data.defaultCameraAngle;
                Parameters.save();
                break;
            case Parameters.data.useSpecial:
                if (!this.specialKeyDown_) {
                    if (player.isUnstable() && !player.isUnstableImmune()) {
                        success = player.useAltWeapon(Math.random() * 600 - 300, Math.random() * 600 - 300, UseType.START_USE);
                    } else {
                        success = player.useAltWeapon(this.gs_.map.mouseX, this.gs_.map.mouseY, UseType.START_USE);
                    }
                    if (success) {
                        this.specialKeyDown_ = true;
                    }
                }
                break;
            case Parameters.data.autofireToggle:
                this.autofire_ = !this.autofire_;
                break;
            case Parameters.data.useInvSlot1:
                this.useItem(4);
                break;
            case Parameters.data.useInvSlot2:
                this.useItem(5);
                break;
            case Parameters.data.useInvSlot3:
                this.useItem(6);
                break;
            case Parameters.data.useInvSlot4:
                this.useItem(7);
                break;
            case Parameters.data.useInvSlot5:
                this.useItem(8);
                break;
            case Parameters.data.useInvSlot6:
                this.useItem(9);
                break;
            case Parameters.data.useInvSlot7:
                this.useItem(10);
                break;
            case Parameters.data.useInvSlot8:
                this.useItem(11);
                break;
            case Parameters.data.useHealthPotion:
                if (this.potionInventoryModel.getPotionModel(PotionInventoryModel.HEALTH_POTION_ID).available) {
                    this.useBuyPotionSignal.dispatch(new UseBuyPotionVO(PotionInventoryModel.HEALTH_POTION_ID, UseBuyPotionVO.CONTEXTBUY));
                }
                break;
            case Parameters.data.useMagicPotion:
                if (this.potionInventoryModel.getPotionModel(PotionInventoryModel.MAGIC_POTION_ID).available) {
                    this.useBuyPotionSignal.dispatch(new UseBuyPotionVO(PotionInventoryModel.MAGIC_POTION_ID, UseBuyPotionVO.CONTEXTBUY));
                }
                break;
            case Parameters.data.miniMapZoomOut:
                this.miniMapZoom.dispatch(MiniMapZoomSignal.OUT);
                break;
            case Parameters.data.miniMapZoomIn:
                this.miniMapZoom.dispatch(MiniMapZoomSignal.IN);
                break;
            case Parameters.data.togglePerformanceStats:
                this.togglePerformanceStats();
                break;
            case Parameters.data.escapeToNexus:
                if (this.gs_.map.name_ == "Nexus") {
                    this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME, "You\'re already are in the Nexus..."));
                    return;
                }
                this.gs_.gsc_.escape();
                Parameters.data.needsRandomRealm = false;
                Parameters.save();
                break;
            case Parameters.data.toggleCentering:
                Parameters.data.centerOnPlayer = !Parameters.data.centerOnPlayer;
                Parameters.save();
                break;
            case Parameters.data.switchTabs:
                this.statsTabHotKeyInputSignal.dispatch();
                break;
            case Parameters.data.reconVault:
                if (this.gs_.map.name_ == "Vault") {
                    this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME, "You\'re already are in the Vault..."));
                    return;
                }
                this.gs_.gsc_.playerText("/vault");
                break;
            case Parameters.data.reconRealm:
                if (this.gs_.map.name_ == "Realm") {
                    this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME, "You\'re already are in the Realm..."));
                    return;
                }
                this.gs_.gsc_.playerText("/realm");
                break;
            case Parameters.data.reconCloth:
                if (this.gs_.map.name_ == "Cloth Bazaar") {
                    this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME, "You\'re already are in the Cloth Bazaar..."));
                    return;
                }
                this.gs_.gsc_.playerText("/clothbazaar");
                break;
            case Parameters.data.GPURenderToggle:
                Parameters.data.GPURender = !Parameters.data.GPURender;
                break;
            case Parameters.data.uiQualityToggle:
                Parameters.data.uiQuality = !Parameters.data.uiQuality;
                Options.toggleQualityOption(Parameters.data.uiQuality);
                break;
            case Parameters.data.reconGuildHall:
                if (this.gs_.map.name_ == "GuildHall") {
                    this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME, "You\'re already are in the Guild Hall..."));
                    return;
                }
                this.gs_.gsc_.playerText("/ghall");
                break;
            case Parameters.data.reconMarket:
                if (this.gs_.map.name_ == "Marketplace") {
                    this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME, "You\'re already are in the Marketplace..."));
                    return;
                }
                this.gs_.gsc_.playerText("/marketplace");
                break;
            case Parameters.data.partyInviteWorld:
                this.gs_.gsc_.playerText("/pinviteworld");
                break;
            case Parameters.data.partyJoinWorld:
                this.gs_.gsc_.playerText("/pjoin");
        }
        this.setPlayerMovement();
    }

    private function onKeyUp(event:KeyboardEvent):void {
        var player:Player = null;
        switch (event.keyCode) {
            case Parameters.data.moveUp:
                this.moveUp_ = false;
                break;
            case Parameters.data.moveDown:
                this.moveDown_ = false;
                break;
            case Parameters.data.moveLeft:
                this.moveLeft_ = false;
                break;
            case Parameters.data.moveRight:
                this.moveRight_ = false;
                break;
            case Parameters.data.rotateLeft:
                this.rotateLeft_ = false;
                break;
            case Parameters.data.rotateRight:
                this.rotateRight_ = false;
                break;
            case Parameters.data.useSpecial:
                if (this.specialKeyDown_) {
                    this.specialKeyDown_ = false;
                    player = this.gs_.map.player_;
                    if (player.isUnstable() && !player.isUnstableImmune()) {
                        this.gs_.map.player_.useAltWeapon(Math.random() * 600 - 300, Math.random() * 600 - 325, UseType.END_USE);
                    } else {
                        this.gs_.map.player_.useAltWeapon(this.gs_.map.mouseX, this.gs_.map.mouseY, UseType.END_USE);
                    }
                }
        }
        this.setPlayerMovement();
    }

    private function selectAimMode() : void {
        var _loc1_:int = 0;
        var _loc2_:String = "";
        if(Parameters.data.aimMode == undefined) {
            _loc1_ = 1;
        } else {
            _loc1_ = (Parameters.data.aimMode + 1) % 3;
        }
        switch(_loc1_) {
            case 1:
                _loc2_ = "Aim Assist Mode: Highest HP";
                break;
            case 2:
                _loc2_ = "Aim Assist Mode: Closest";
                break;
            case 0:
                _loc2_ = "Aim Assist Mode: Closest to Cursor";
        }
        this.gs_.map.player_.levelUpEffect(_loc2_);
        Parameters.data.aimMode = _loc1_;
        Parameters.save();
    }
}
}
