package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.map.Square;
import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
import com.company.assembleegameclient.objects.particles.HealingEffect;
import com.company.assembleegameclient.objects.particles.LevelUpEffect;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.sound.SoundEffectLibrary;
import com.company.assembleegameclient.tutorial.Tutorial;
import com.company.assembleegameclient.tutorial.doneAction;
import com.company.assembleegameclient.util.AnimatedChar;
import com.company.assembleegameclient.util.ConditionEffect;
import com.company.assembleegameclient.util.FameUtil;
import com.company.assembleegameclient.util.FreeList;
import com.company.assembleegameclient.util.MaskedImage;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.redrawers.GlowRedrawer;
import com.company.ui.SimpleText;
import com.company.util.CachingColorTransformer;
import com.company.util.ConversionUtil;
import com.company.util.GraphicsUtil;
import com.company.util.IntPoint;
import com.company.util.MoreColorUtil;
import com.company.util.PointUtil;
import com.company.util.Trig;

import flash.display.BitmapData;
import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import kabam.rotmg.assets.services.CharacterFactory;
import kabam.rotmg.constants.ActivationType;
import kabam.rotmg.constants.GeneralConstants;
import kabam.rotmg.constants.UseType;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.game.model.AddTextLineVO;
import kabam.rotmg.game.model.PotionInventoryModel;
import kabam.rotmg.game.signals.AddTextLineSignal;
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.stage3D.GraphicsFillExtra;
import kabam.rotmg.ui.model.TabStripModel;

import org.swiftsuspenders.Injector;

public class Player extends Character {

    public static const MS_BETWEEN_TELEPORT:int = 10000;

    private static const MOVE_THRESHOLD:Number = 0.4;

    private static const NEARBY:Vector.<Point> = new <Point>[new Point(0, 0), new Point(1, 0), new Point(0, 1), new Point(1, 1)];
    private static const RANK_OFFSET_MATRIX:Matrix = new Matrix(1, 0, 0, 1, 2, 4);
    private static const NAME_OFFSET_MATRIX:Matrix = new Matrix(1, 0, 0, 1, 20, 0);
    private static const MIN_MOVE_SPEED:Number = 0.004;
    private static const MAX_MOVE_SPEED:Number = 0.0096;
    private static const MIN_ATTACK_FREQ:Number = 0.0015;
    private static const MAX_ATTACK_FREQ:Number = 0.008;
    private static const MIN_ATTACK_MULT:Number = 0.5;
    private static const MAX_ATTACK_MULT:Number = 2;
    private static const LOW_HEALTH_CT_OFFSET:int = 128;
    public static const SEARCH_LOOT_FREQ:int = 20;
    public static const MAX_LOOT_DIST:Number = 1;
    public static const VAULT_CHEST:int = 1284;
    public static const HEALTH_POT:int = 2594;
    public static const MAGIC_POT:int = 2595;
    public static const MAX_STACK_POTS:int = 6;
    public static const LOOT_EVERY_MS:int = 550;
    public static const WEAP_ARMOR_MIN_TIER:int = 10;
    public static const HEALTH_SLOT:int = 254;
    public static const MAGIC_SLOT:int = 255;
    public static var wantedList:Vector.<int> = null;
    public static var lastSearchTime:int = 0;
    public static var lastLootTime:int = 0;
    public static var nextLootSlot:int = -1;
    private static var newP:Point = new Point();
    private static var lowHealthCT:Dictionary = new Dictionary();
    public var followTarget:GameObject;

    public static function fromPlayerXML(name:String, playerXML:XML):Player {
        var objectType:int = int(playerXML.ObjectType);
        var objXML:XML = ObjectLibrary.xmlLibrary_[objectType];
        var player:Player = new Player(objXML);
        player.name_ = name;
        player.level_ = int(playerXML.Level);
        player.exp_ = int(playerXML.Exp);
        player.equipment_ = ConversionUtil.toIntVector(playerXML.Equipment);
        player.maxHP_ = int(playerXML.MaxHitPoints);
        player.hp_ = int(playerXML.HitPoints);
        player.maxMP_ = int(playerXML.MaxMagicPoints);
        player.mp_ = int(playerXML.MagicPoints);
        player.attack_ = int(playerXML.Attack);
        player.defense_ = int(playerXML.Defense);
        player.speed_ = int(playerXML.Speed);
        player.dexterity_ = int(playerXML.Dexterity);
        player.vitality_ = int(playerXML.HpRegen);
        player.wisdom_ = int(playerXML.MpRegen);
        player.tex1Id_ = int(playerXML.Tex1);
        player.tex2Id_ = int(playerXML.Tex2);
        player.hasBackpack_ = Boolean(playerXML.HasBackpack == 1);
        return player;
    }

    public function Player(objectXML:XML) {
        this.ip_ = new IntPoint();
        var injector:Injector = StaticInjectorContext.getInjector();
        this.addTextLine = injector.getInstance(AddTextLineSignal);
        this.factory = injector.getInstance(CharacterFactory);
        super(objectXML);
        this.attackMax_ = int(objectXML.Attack.@max);
        this.defenseMax_ = int(objectXML.Defense.@max);
        this.speedMax_ = int(objectXML.Speed.@max);
        this.dexterityMax_ = int(objectXML.Dexterity.@max);
        this.vitalityMax_ = int(objectXML.HpRegen.@max);
        this.wisdomMax_ = int(objectXML.MpRegen.@max);
        this.maxHPMax_ = int(objectXML.MaxHitPoints.@max);
        this.maxMPMax_ = int(objectXML.MaxMagicPoints.@max);
        texturingCache_ = new Dictionary();
    }
    public var skinId:int;
    public var skin:AnimatedChar;
    public var accountId_:int = -1;
    public var credits_:int = 0;
    public var numStars_:int = 0;
    public var fame_:int = 0;
    public var nameChosen_:Boolean = false;
    public var currFame_:int = 0;
    public var nextClassQuestFame_:int = -1;
    public var legendaryRank_:int = -1;
    public var guildName_:String = null;
    public var guildRank_:int = -1;
    public var isFellowGuild_:Boolean = false;
    public var isPartyMember_:Boolean = false;
    public var breath_:int = -1;
    public var maxMP_:int = 200;
    public var mp_:Number = 0;
    public var nextLevelExp_:int = 1000;
    public var exp_:int = 0;
    public var attack_:int = 0;
    public var speed_:int = 0;
    public var dexterity_:int = 0;
    public var vitality_:int = 0;
    public var wisdom_:int = 0;
    public var maxHPBoost_:int = 0;
    public var maxMPBoost_:int = 0;
    public var attackBoost_:int = 0;
    public var defenseBoost_:int = 0;
    public var speedBoost_:int = 0;
    public var vitalityBoost_:int = 0;
    public var wisdomBoost_:int = 0;
    public var dexterityBoost_:int = 0;
    public var healthPotionCount_:int = 0;
    public var magicPotionCount_:int = 0;
    public var attackMax_:int = 0;
    public var defenseMax_:int = 0;
    public var speedMax_:int = 0;
    public var dexterityMax_:int = 0;
    public var vitalityMax_:int = 0;
    public var wisdomMax_:int = 0;
    public var maxHPMax_:int = 0;
    public var maxMPMax_:int = 0;
    public var dropBoost:int = 0;
    public var xpTimer:int;
    public var rank:int;
    public var chatColor:int;
    public var nameChatColor:int;
    public var xpBoost_:int = 0;
    public var baseStat:int = 0;
    public var points:int = 0;
    public var maxedLife:Boolean = false;
    public var maxedMana:Boolean = false;
    public var maxedAtt:Boolean = false;
    public var maxedDef:Boolean = false;
    public var maxedSpd:Boolean = false;
    public var maxedDex:Boolean = false;
    public var maxedVit:Boolean = false;
    public var maxedWis:Boolean = false;
    public var smallSkill1:int = 0;
    public var smallSkill2:int = 0;
    public var smallSkill3:int = 0;
    public var smallSkill4:int = 0;
    public var smallSkill5:int = 0;
    public var smallSkill6:int = 0;
    public var smallSkill7:int = 0;
    public var smallSkill8:int = 0;
    public var smallSkill9:int = 0;
    public var smallSkill10:int = 0;
    public var smallSkill11:int = 0;
    public var smallSkill12:int = 0;
    public var bigSkill1:Boolean = false;
    public var bigSkill2:Boolean = false;
    public var bigSkill3:Boolean = false;
    public var bigSkill4:Boolean = false;
    public var bigSkill5:Boolean = false;
    public var bigSkill6:Boolean = false;
    public var bigSkill7:Boolean = false;
    public var bigSkill8:Boolean = false;
    public var bigSkill9:Boolean = false;
    public var bigSkill10:Boolean = false;
    public var bigSkill11:Boolean = false;
    public var bigSkill12:Boolean = false;
    public var hasBackpack_:Boolean = false;
    public var starred_:Boolean = false;
    public var ignored_:Boolean = false;
    public var upgraded_:Boolean = false;
    public var partyId_:int = 0;
    public var distSqFromThisPlayer_:Number = 0;
    public var attackPeriod_:int = 0;
    public var nextAltAttack_:int = 0;
    public var nextTeleportAt_:int = 0;
    public var isDefaultAnimatedChar:Boolean = true;
    protected var rotate_:Number = 0;
    protected var relMoveVec_:Point = null;
    protected var moveMultiplier_:Number = 1;
    protected var healingEffect_:HealingEffect = null;
    protected var nearestMerchant_:Merchant = null;
    private var addTextLine:AddTextLineSignal;
    private var factory:CharacterFactory;
    private var ip_:IntPoint;
    private var breathBackFill_:GraphicsSolidFill = null;
    private var breathBackPath_:GraphicsPath = null;
    private var breathFill_:GraphicsSolidFill = null;
    private var breathPath_:GraphicsPath = null;
    public var tq:Boolean = false;

    override public function moveTo(x:Number, y:Number):Boolean {
        var ret:Boolean = super.moveTo(x, y);
        if (map_.gs_.isNexus_) {
            this.nearestMerchant_ = this.getNearbyMerchant();
        }
        return ret;
    }

    override public function update(time:int, dt:int):Boolean {
        var playerAngle:Number = NaN;
        var moveSpeed:Number = NaN;
        var moveVecAngle:Number = NaN;
        var d:int = 0;
        if (this == map_.player_ && wantedList == null)
            wantedList = this.genWantedList();
        if (Parameters.data.autoLoot && lookForLoot()) {
            autoLoot();
        }
        if (Parameters.data.permaFollow != "" && followTarget == null) {
            for each (var go:GameObject in this.map_.goDict_)
                if (go.name_ && go.name_.toLowerCase()
                        == Parameters.data.permaFollow.toLowerCase()) {
                    followTarget = go;
                    break;
                }
        }
        if (this.dropBoost && !isPaused()) {
            this.dropBoost = this.dropBoost - dt;
            if (this.dropBoost < 0) {
                this.dropBoost = 0;
            }
        }
        if (this.xpTimer && !isPaused()) {
            this.xpTimer = this.xpTimer - dt;
            if (this.xpTimer < 0) {
                this.xpTimer = 0;
            }
        }
        if (isHealing() && !isPaused() && Parameters.data.reduceParticles != 0) {
            if (this.healingEffect_ == null) {
                this.healingEffect_ = new HealingEffect(this);
                map_.addObj(this.healingEffect_, x_, y_);
            }
        } else if (this.healingEffect_ != null) {
            map_.removeObj(this.healingEffect_.objectId_);
            this.healingEffect_ = null;
        }
        if (map_.player_ == this && isPaused()) {
            return true;
        }
        if (this == this.map_.player_ && !this.relMoveVec_ && followTarget)
            setRelativeMovement(0, 1, 1);
        if (this.relMoveVec_ != null) {
            playerAngle = Parameters.data.cameraAngle;
            if (this.rotate_ != 0) {
                playerAngle = playerAngle + dt * Parameters.PLAYER_ROTATE_SPEED * this.rotate_;
                Parameters.data.cameraAngle = playerAngle;
            }
            if (followTarget != null) {
                moveSpeed = this.getMoveSpeed();
                var dist:Number = (followTarget.y_ - y_) * (followTarget.y_ - y_) + (followTarget.x_ - x_) * (followTarget.x_ - x_);
                if (dist > 30 * 30)
                    this.map_.gs_.gsc_.teleportId(followTarget.objectId_);
                if (dist < 0.01) { //make smaller?
                    moveVec_.x = 0;
                    moveVec_.y = 0;
                } else {
                    dist = Math.atan2(followTarget.y_ - y_, followTarget.x_ - x_); //angle
                    moveVec_.x = moveSpeed * Math.cos(dist);
                    moveVec_.y = moveSpeed * Math.sin(dist);
                }
            }
            else if (this.relMoveVec_.x != 0 || this.relMoveVec_.y != 0) {
                moveSpeed = this.getMoveSpeed();
                moveVecAngle = Math.atan2(this.relMoveVec_.y, this.relMoveVec_.x);
                moveVec_.x = moveSpeed * Math.cos(playerAngle + moveVecAngle);
                moveVec_.y = moveSpeed * Math.sin(playerAngle + moveVecAngle);
            } else {
                moveVec_.x = 0;
                moveVec_.y = 0;
            }
            if (square_ != null && square_.props_.push_) {
                moveVec_.x = moveVec_.x - square_.props_.animate_.dx_ / 1000;
                moveVec_.y = moveVec_.y - square_.props_.animate_.dy_ / 1000;
            }
            if (this.tq || this != this.map_.player_) {
                this.walkTo(x_ + dt * moveVec_.x,y_ + dt * moveVec_.y);
                if (this.tq)
                    this.tq = false;
            }
        } else if (!super.update(time, dt)) {
            return false;
        }
        if (map_.player_ == this && square_.props_.maxDamage_ > 0
                && square_.lastDamage_ + 500 < time && !isInvincible()
                && (square_.obj_ == null || !square_.obj_.props_.protectFromGroundDamage_)
                && !Parameters.data.godmode) {
            d = map_.gs_.gsc_.getNextDamage(square_.props_.minDamage_, square_.props_.maxDamage_);
            damage(-1, d, null, hp_ <= d, null);
            map_.gs_.gsc_.groundDamage(time, x_, y_);
            square_.lastDamage_ = time;
        }
        return true;
    }

    override protected function generateNameBitmapData(nameText:SimpleText):BitmapData {
        if(this.isPartyMember_) {
            nameText.setColor(Parameters.PARTY_MEMBER_COLOR);
        } else if (this.isFellowGuild_) {
            nameText.setColor(Parameters.FELLOW_GUILD_COLOR);
        } else if (this.nameChosen_) {
            nameText.setColor(Parameters.NAME_CHOSEN_COLOR);
        }
        var nameBitmapData:BitmapData = new BitmapData(nameText.width + 20, 64, true, 0);
        nameBitmapData.draw(nameText, NAME_OFFSET_MATRIX);
        nameBitmapData.applyFilter(nameBitmapData, nameBitmapData.rect, PointUtil.ORIGIN, new GlowFilter(0, 1, 3, 3, 2, 1));
        var rankIcon:Sprite = FameUtil.numStarsToIcon(this.numStars_);
        nameBitmapData.draw(rankIcon, RANK_OFFSET_MATRIX);
        return nameBitmapData;
    }

    private var prevTime:int = -1;
    override public function draw(graphicsData:Vector.<IGraphicsData>, camera:Camera, time:int):void {
        switch (Parameters.data.hideList) {
            case 1:
                if (this != map_.player_ && !this.starred_) {
                    return;
                }
                break;
            case 2:
                if (this != map_.player_ && !this.isFellowGuild_) {
                    return;
                }
                break;
            case 3:
                if(this != map_.player_ && !this.isPartyMember_) {
                    return;
                }
                break;
            case 4:
                if(this != map_.player_ && !this.starred_ && !this.isFellowGuild_ && !this.isPartyMember_) {
                    return;
                }
                break;
        }

        if (this.prevTime != -1 && this == this.map_.player_)
            if (!this.tq)
                this.walkTo(x_ + (time - this.prevTime) * moveVec_.x,
                    y_ + (time - this.prevTime) * moveVec_.y);
            else {
                this.moveTo(x_, y_);
                this.tq = false;
            }
        this.prevTime = time;

        super.draw(graphicsData, camera, time);
        if (this != map_.player_) {
            drawName(graphicsData, camera);
        } else if (this.breath_ >= 0) {
            this.drawBreathBar(graphicsData, time);
        }
    }

    override protected function getTexture(camera:Camera, time:int):BitmapData {
        var ct:ColorTransform = null;
        var image:MaskedImage = null;
        var walkPer:int = 0;
        var dict:Dictionary = null;
        var rv:Number = NaN;
        var p:Number = 0;
        var action:int = AnimatedChar.STAND;
        if (time < attackStart_ + this.attackPeriod_) {
            facing_ = attackAngle_;
            p = (time - attackStart_) % this.attackPeriod_ / this.attackPeriod_;
            action = AnimatedChar.ATTACK;
        } else if (moveVec_.x != 0 || moveVec_.y != 0) {
            walkPer = 3.5 / this.getMoveSpeed();
            if (moveVec_.y != 0 || moveVec_.x != 0) {
                facing_ = Math.atan2(moveVec_.y, moveVec_.x);
            }
            p = time % walkPer / walkPer;
            action = AnimatedChar.WALK;
        }
        if (this.isHexed()) {
            this.isDefaultAnimatedChar && this.setToRandomAnimatedCharacter();
        } else if (!this.isDefaultAnimatedChar) {
            this.makeSkinTexture();
        }
        if (camera.isHallucinating_) {
            image = new MaskedImage(getHallucinatingTexture(), null);
        } else {
            image = animatedChar_.imageFromFacing(facing_, camera, action, p);
        }
        var tex1Id:int = tex1Id_;
        var tex2Id:int = tex2Id_;
        var texture:BitmapData = null;
        if (this.nearestMerchant_ != null) {
            dict = texturingCache_[this.nearestMerchant_];
            if (dict == null) {
                texturingCache_[this.nearestMerchant_] = new Dictionary();
            } else {
                texture = dict[image];
            }
            tex1Id = this.nearestMerchant_.getTex1Id(tex1Id_);
            tex2Id = this.nearestMerchant_.getTex2Id(tex2Id_);
        } else {
            texture = texturingCache_[image];
        }
        if (texture == null) {
            texture = TextureRedrawer.resize(image.image_, image.mask_, size_, false, tex1Id, tex2Id);
            if (this.nearestMerchant_ != null) {
                texturingCache_[this.nearestMerchant_][image] = texture;
            } else {
                texturingCache_[image] = texture;
            }
        }
        if (hp_ < maxHP_ * 0.2) {
            rv = int(Math.abs(Math.sin(time / 200)) * 10) / 10;
            ct = lowHealthCT[rv];
            if (ct == null) {
                ct = new ColorTransform(1, 1, 1, 1, rv * LOW_HEALTH_CT_OFFSET, -rv * LOW_HEALTH_CT_OFFSET, -rv * LOW_HEALTH_CT_OFFSET);
                lowHealthCT[rv] = ct;
            }
            texture = CachingColorTransformer.transformBitmapData(texture, ct);
        }
        var filteredTexture:BitmapData = texturingCache_[texture];
        if (filteredTexture == null) {
            filteredTexture = GlowRedrawer.outlineGlow(texture, this.glowColor_);
            texturingCache_[texture] = filteredTexture;
        }
        if (this.isCursed() && !this.isCurseImmune()) {
            filteredTexture = CachingColorTransformer.filterBitmapData(filteredTexture, CURSED_FILTER);
        }
        if (isPaused() || isStasis() || isPetrified()) {
            filteredTexture = CachingColorTransformer.filterBitmapData(filteredTexture, PAUSED_FILTER);
        } else if (isInvisible()) {
            filteredTexture = CachingColorTransformer.alphaBitmapData(filteredTexture, 40);
        }
        return filteredTexture;
    }

    override public function getPortrait():BitmapData {
        var image:MaskedImage = null;
        var size:int = 0;
        if (portrait_ == null) {
            image = animatedChar_.imageFromDir(AnimatedChar.RIGHT, AnimatedChar.STAND, 0);
            size = 4 / image.image_.width * 100;
            portrait_ = TextureRedrawer.resize(image.image_, image.mask_, size, true, tex1Id_, tex2Id_);
            portrait_ = GlowRedrawer.outlineGlow(portrait_, 0);
        }
        return portrait_;
    }

    override public function setAttack(containerType:int, attackAngle:Number):void {
        var weaponXML:XML = ObjectLibrary.xmlLibrary_[containerType];
        if (weaponXML == null || !weaponXML.hasOwnProperty("RateOfFire")) {
            return;
        }
        var bigSkill:Number = this.bigSkill11?Number(0.3):Number(0);
        if (this.smallSkill11 > 0) {
            bigSkill = bigSkill + this.smallSkill11 * 0.02;
        }
        if(this.bigSkill1) {
            bigSkill = bigSkill - 0.1;
        }
        if(this.bigSkill4) {
            bigSkill = bigSkill - 0.05;
        }

        var rateSkill:Number = bigSkill * Number(weaponXML.RateOfFire);
        var rateOfFire:Number = Number(weaponXML.RateOfFire) + rateSkill;
        this.attackPeriod_ = 1 / this.attackFrequency() * (1 / rateOfFire);
        super.setAttack(containerType, attackAngle);
    }

    public function setRelativeMovement(rotate:Number, relMoveVecX:Number, relMoveVecY:Number):void {
        var temp:Number = NaN;
        if (this.relMoveVec_ == null) {
            this.relMoveVec_ = new Point();
        }
        this.rotate_ = rotate;
        this.relMoveVec_.x = relMoveVecX;
        this.relMoveVec_.y = relMoveVecY;
        if (isConfused()) {
            temp = this.relMoveVec_.x;
            this.relMoveVec_.x = -this.relMoveVec_.y;
            this.relMoveVec_.y = -temp;
            this.rotate_ = -this.rotate_;
        }
    }

    public function setCredits(credits:int):void {
        this.credits_ = credits;
    }

    public function setParty() : void {
        var go:GameObject = null;
        var player:Player = null;
        var isPartyMember:Boolean = false;
        var myPlayer:Player = map_.player_;
        if(myPlayer == this) {
            for each(go in map_.goDict_) {
                player = go as Player;
                if(player != null && player != this) {
                    player.setParty();
                }
            }
        } else {
            isPartyMember = myPlayer != null && myPlayer.partyId_ != 0 && myPlayer.partyId_ == this.partyId_;
            if(isPartyMember != this.isPartyMember_) {
                this.isPartyMember_ = isPartyMember;
                nameBitmapData_ = null;
            }
        }
    }

    public function setGuildName(guildName:String):void {
        var go:GameObject = null;
        var player:Player = null;
        var isFellowGuild:Boolean = false;
        this.guildName_ = guildName;
        var myPlayer:Player = map_.player_;
        if (myPlayer == this) {
            for each(go in map_.goDict_) {
                player = go as Player;
                if (player != null && player != this) {
                    player.setGuildName(player.guildName_);
                }
            }
        } else {
            isFellowGuild = myPlayer != null && myPlayer.guildName_ != null && myPlayer.guildName_ != "" && myPlayer.guildName_ == this.guildName_;
            if (isFellowGuild != this.isFellowGuild_) {
                this.isFellowGuild_ = isFellowGuild;
                nameBitmapData_ = null;
            }
        }
    }

    public function isTeleportEligible(player:Player):Boolean {
        return !(player.isPaused() || player.isInvisible());
    }

    public function msUtilTeleport():int {
        var time:int = getTimer();
        return Math.max(0, this.nextTeleportAt_ - time);
    }

    public function teleportTo(player:Player):Boolean {
        if (isPaused()) {
            this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME, "Can not teleport while paused."));
            return false;
        }
        var msUtil:int = this.msUtilTeleport();
        if (msUtil > 0) {
            this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME, "You can not teleport for another " + int(msUtil / 1000 + 1) + " seconds."));
            return false;
        }
        if (!this.isTeleportEligible(player)) {
            if (player.isInvisible()) {
                this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME, "Can not teleport to " + player.name_ + " while they are invisible."));
            }
            this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME, "Can not teleport to " + player.name_));
            return false;
        }
        map_.gs_.gsc_.teleportId(player.objectId_);
        this.nextTeleportAt_ = getTimer() + MS_BETWEEN_TELEPORT;
        return true;
    }

    public function levelUpEffect(text:String):void {
        this.levelUpParticleEffect();
        map_.mapOverlay_.addStatusText(new CharacterStatusText(this, text, 65280, 2000));
    }

    public function handleLevelUp(isUnlock:Boolean):void {
        SoundEffectLibrary.play("level_up");
        if (isUnlock) {
            this.levelUpEffect("New Class Unlocked!");
        } else {
            this.levelUpEffect("Level Up!");
        }
    }

    public function levelUpParticleEffect():void {
        map_.addObj(new LevelUpEffect(this, 4278255360, 20), x_, y_);
    }

    public function handleExpUp(exp:int):void {
        if (level_ == 20) {
            return;
        }
        map_.mapOverlay_.addStatusText(new CharacterStatusText(this, "+" + exp + " EXP", 65280, 1000));
    }

    public function handleFameUp(fame:int):void {
        if (level_ != 20) {
            return;
        }
        if (fame > 0) {
            map_.mapOverlay_.addStatusText(new CharacterStatusText(this, "+" + fame + " Fame", 14835456, 1000));
        }
    }

    public function walkTo(x:Number, y:Number):Boolean {
        this.modifyMove(x, y, newP);
        return this.moveTo(newP.x, newP.y);
    }

    public function modifyMove(x:Number, y:Number, newP:Point):void {
        if (isParalyzed() || isPetrified()) {
            newP.x = x_;
            newP.y = y_;
            return;
        }
        var dx:Number = x - x_;
        var dy:Number = y - y_;
        if (dx < MOVE_THRESHOLD && dx > -MOVE_THRESHOLD && dy < MOVE_THRESHOLD && dy > -MOVE_THRESHOLD) {
            this.modifyStep(x, y, newP);
            return;
        }
        var stepSize:Number = MOVE_THRESHOLD / Math.max(Math.abs(dx), Math.abs(dy));
        var d:Number = 0;
        newP.x = x_;
        newP.y = y_;
        var done:Boolean = false;
        while (!done) {
            if (d + stepSize >= 1) {
                stepSize = 1 - d;
                done = true;
            }
            this.modifyStep(newP.x + dx * stepSize, newP.y + dy * stepSize, newP);
            d = d + stepSize;
        }
    }

    public function modifyStep(x:Number, y:Number, newP:Point):void {
        var nextXBorder:Number = NaN;
        var nextYBorder:Number = NaN;
        var xCross:Boolean = x_ % 0.5 == 0 && x != x_ || int(x_ / 0.5) != int(x / 0.5);
        var yCross:Boolean = y_ % 0.5 == 0 && y != y_ || int(y_ / 0.5) != int(y / 0.5);
        if (!xCross && !yCross || this.isValidPosition(x, y)) {
            newP.x = x;
            newP.y = y;
            return;
        }
        if (xCross) {
            nextXBorder = x > x_ ? Number(Number(int(x * 2) / 2)) : Number(Number(int(x_ * 2) / 2));
            if (int(nextXBorder) > int(x_)) {
                nextXBorder = nextXBorder - 0.01;
            }
        }
        if (yCross) {
            nextYBorder = y > y_ ? Number(Number(int(y * 2) / 2)) : Number(Number(int(y_ * 2) / 2));
            if (int(nextYBorder) > int(y_)) {
                nextYBorder = nextYBorder - 0.01;
            }
        }
        if (!xCross) {
            newP.x = x;
            newP.y = nextYBorder;
            return;
        }
        if (!yCross) {
            newP.x = nextXBorder;
            newP.y = y;
            return;
        }
        var xBorderDist:Number = x > x_ ? Number(Number(x - nextXBorder)) : Number(Number(nextXBorder - x));
        var yBorderDist:Number = y > y_ ? Number(Number(y - nextYBorder)) : Number(Number(nextYBorder - y));
        if (xBorderDist > yBorderDist) {
            if (this.isValidPosition(x, nextYBorder)) {
                newP.x = x;
                newP.y = nextYBorder;
                return;
            }
            if (this.isValidPosition(nextXBorder, y)) {
                newP.x = nextXBorder;
                newP.y = y;
                return;
            }
        } else {
            if (this.isValidPosition(nextXBorder, y)) {
                newP.x = nextXBorder;
                newP.y = y;
                return;
            }
            if (this.isValidPosition(x, nextYBorder)) {
                newP.x = x;
                newP.y = nextYBorder;
                return;
            }
        }
        newP.x = nextXBorder;
        newP.y = nextYBorder;
    }

    public function isValidPosition(x:Number, y:Number):Boolean {
        var square:Square = map_.getSquare(x, y);
        if (Parameters.data.noClip && square)
            return true;
        if (square_ != square && (square == null || !square.isWalkable()))
            return false;
        var xFrac:Number = x - int(x);
        var yFrac:Number = y - int(y);
        if (xFrac < 0.5) {
            if (this.isFullOccupy(x - 1, y)) {
                return false;
            }
            if (yFrac < 0.5) {
                if (this.isFullOccupy(x, y - 1) || this.isFullOccupy(x - 1, y - 1)) {
                    return false;
                }
            } else if (yFrac > 0.5) {
                if (this.isFullOccupy(x, y + 1) || this.isFullOccupy(x - 1, y + 1)) {
                    return false;
                }
            }
        } else if (xFrac > 0.5) {
            if (this.isFullOccupy(x + 1, y)) {
                return false;
            }
            if (yFrac < 0.5) {
                if (this.isFullOccupy(x, y - 1) || this.isFullOccupy(x + 1, y - 1)) {
                    return false;
                }
            } else if (yFrac > 0.5) {
                if (this.isFullOccupy(x, y + 1) || this.isFullOccupy(x + 1, y + 1)) {
                    return false;
                }
            }
        } else if (yFrac < 0.5) {
            if (this.isFullOccupy(x, y - 1)) {
                return false;
            }
        } else if (yFrac > 0.5) {
            if (this.isFullOccupy(x, y + 1)) {
                return false;
            }
        }
        return true;
    }

    public function isFullOccupy(x:Number, y:Number):Boolean {
        var square:Square = map_.lookupSquare(x, y);
        return square == null || square.tileType_ == 255 || square.obj_ != null && square.obj_.props_.fullOccupy_;
    }

    public function onMove():void {
        var square:Square = (x_ < 0 || y_ < 0) ? null : map_.getSquare(x_, y_);
        if (square && square.props_.sinking_ && !Parameters.data.noSink) {
            sinkLevel_ = Math.min(sinkLevel_ + 1, Parameters.MAX_SINK_LEVEL);
            this.moveMultiplier_ = 0.1 + (1 - sinkLevel_ / Parameters.MAX_SINK_LEVEL) * (square.props_.speed_ - 0.1) * Parameters.data.sMult;
        } else {
            sinkLevel_ = 0;
            this.moveMultiplier_ = Parameters.data.sMult;
        }
    }

    public function attackFrequency():Number {
        if (isDazed()) {
            return MIN_ATTACK_FREQ;
        }
        var attFreq:Number = MIN_ATTACK_FREQ + this.dexterity_ / 75 * (MAX_ATTACK_FREQ - MIN_ATTACK_FREQ);
        if (isBerserk() || isNinjaBerserk()) {
            attFreq = attFreq * 1.5;
        }
        return attFreq;
    }

    public function lootNotif(param1:String, param2:GameObject, param3:uint = 65535) : void {
        var _loc4_:CharacterStatusText = new CharacterStatusText(param2, param1, param3,4000);
        map_.mapOverlay_.addStatusText(_loc4_);
    }

    public function notWanted(param1:XML) : Boolean
    {
        var _loc2_:Boolean = false;
        var _loc3_:String = null;
        var _loc4_:String = null;
        for each(_loc4_ in Parameters.data.NoLoot)
        {
            if(String(param1.@id).toLowerCase().search(_loc4_) != -1)
            {
                return true;
            }
        }
        return false;
    }

    public function genWantedList() : Vector.<int> {
        var _loc1_:XML = null;
        var _loc3_:String = null;
        var _loc2_:Vector.<int> = new Vector.<int>();
        for each(_loc1_ in ObjectLibrary.xmlLibrary_) {
            if(_loc1_.hasOwnProperty("Item") && !notWanted(_loc1_)) {
                if(_loc1_.hasOwnProperty("Activate")) {
                    for each(_loc3_ in _loc1_.Activate) {
                        if (_loc3_ == "IncrementStat") {
                            var attr:int = _loc1_.Activate.@stat;
                            switch (attr) {
                                case 21:
                                case 20:
                                case 0:
                                case 3:
                                    if (Parameters.data.potsMajor) {
                                        _loc2_.push(ObjectLibrary.idToType_[String(_loc1_.@id)]);
                                    }
                                    break;
                                case 22:
                                case 26:
                                case 27:
                                case 28:
                                    if (Parameters.data.potsMinor) {
                                        _loc2_.push(ObjectLibrary.idToType_[String(_loc1_.@id)]);
                                    }
                                    break;
                            }
                        }
                        if(_loc3_ == "UpgradeStat") {
                            _loc2_.push(ObjectLibrary.idToType_[String(_loc1_.@id)]);
                        }
                    }
                }
                if(!_loc1_.hasOwnProperty("Tier")) {
                    _loc2_.push(ObjectLibrary.idToType_[String(_loc1_.@id)]);
                } else if(_loc1_.hasOwnProperty("Eternal")) {
                    _loc2_.push(ObjectLibrary.idToType_[String(_loc1_.@id)]);
                } else if(_loc1_.hasOwnProperty("Revenge")) {
                    _loc2_.push(ObjectLibrary.idToType_[String(_loc1_.@id)]);
                } else if(_loc1_.hasOwnProperty("Legendary")) {
                    _loc2_.push(ObjectLibrary.idToType_[String(_loc1_.@id)]);
                } else if(_loc1_.hasOwnProperty("Usable") && _loc1_.Tier >= Parameters.data.LNAbility) {
                    _loc2_.push(ObjectLibrary.idToType_[String(_loc1_.@id)]);
                } else if(_loc1_.hasOwnProperty("SlotType") && _loc1_.SlotType == 9 && _loc1_.Tier >= Parameters.data.LNRing) {
                    _loc2_.push(ObjectLibrary.idToType_[String(_loc1_.@id)]);
                } else if(!_loc1_.hasOwnProperty("Usable") && _loc1_.Tier >= Parameters.data.LNWeap && _loc1_.hasOwnProperty("Projectile")) {
                    _loc2_.push(ObjectLibrary.idToType_[String(_loc1_.@id)]);
                } else if(!_loc1_.hasOwnProperty("Usable") && _loc1_.Tier >= Parameters.data.LNArmor) {
                    _loc2_.push(ObjectLibrary.idToType_[String(_loc1_.@id)]);
                }
            }
        }
        return _loc2_;
    }

    public function bagDist(param1:GameObject, param2:Container) : Number
    {
        var _loc3_:Number = param1.x_ - param2.x_;
        var _loc4_:Number = param1.y_ - param2.y_;
        return Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
    }

    public function getLootableBags(param1:Vector.<Container>, param2:Number) : Vector.<Container>
    {
        var _loc3_:Container = null;
        var _loc4_:Vector.<Container> = new Vector.<Container>();
        for each(_loc3_ in param1)
        {
            if(bagDist(map_.player_,_loc3_) <= param2)
            {
                _loc4_.push(_loc3_);
            }
        }
        return _loc4_;
    }

    public function getLootBags() : Vector.<Container>
    {
        var _loc1_:GameObject = null;
        var _loc2_:Vector.<Container> = new Vector.<Container>();
        for each(_loc1_ in map_.goDict_)
        {
            if(_loc1_ is Container && _loc1_.objectType_ != VAULT_CHEST && _loc1_.objectType_ != 1860) //gift chest
            {
                _loc2_.push(_loc1_);
            }
        }
        return _loc2_;
    }

    public function lookForLoot() : Boolean {
        var _loc1_:int = getTimer();
        var _loc2_:int = 1000 / SEARCH_LOOT_FREQ;
        if (this == map_.player_ && _loc1_ - lastSearchTime > _loc2_) {
            lastSearchTime = _loc1_;
            return true;
        }
        return false;
    }

    public static var Potions:Vector.<int> = new <int>[0xa35,0xa4c,0xae9,0xaea,
        0xa34,0xa21,0xa20,0xa1f,
        0x2369,0x236A,0x236B,0x236C,
        0x236D,0x236E,0x236F,0x2368];
    public function isWantedItem(itemId:int) : Boolean {
        var id:int;
        for each (id in Parameters.data.lootIgnore)
            if (itemId == id)
                return false;

        for each (id in wantedList)
            if (itemId == id)
                return true;

        return false;
    }

    public function lootItem(putToSlot:int, bag:Container, slot1:int, lootedItemtype:int) : void
    {
        var dontPutToPotSlot:Boolean = (putToSlot != HEALTH_SLOT && putToSlot != MAGIC_SLOT);
        var weLootedPotion:Boolean = (lootedItemtype == HEALTH_POT || lootedItemtype == MAGIC_POT);
        if ((healthPotionCount_ < MAX_STACK_POTS && lootedItemtype == HEALTH_POT) || (magicPotionCount_ < MAX_STACK_POTS && lootedItemtype == MAGIC_POT))
        { //loot potion to potion slot
            map_.gs_.gsc_.invSwapPotion(this,bag,slot1,lootedItemtype,this,lootedItemtype-2340,-1);
        }
        else if (dontPutToPotSlot && weLootedPotion && !(nextLootSlot == HEALTH_POT || nextLootSlot == MAGIC_POT))
        { //loot potion to inv
            if ((lootedItemtype == 2594 && !Parameters.data.lootHP) || (lootedItemtype == 2595 && !Parameters.data.lootMP)) {
                return;
            }
            map_.gs_.gsc_.invSwap(this,this,putToSlot,nextLootSlot,bag,slot1,lootedItemtype);
        }
        else if (dontPutToPotSlot && !weLootedPotion)
        { //loot item
            if (nextLootSlot == -1) { //loot item on empty slot
                map_.gs_.gsc_.invSwap(this,bag,slot1,lootedItemtype,this,putToSlot,-1);
            }
            else { //loot item on potion
                if (Parameters.data.drinkPot) {
                    map_.gs_.gsc_.useItem(getTimer(), this.objectId_, putToSlot, nextLootSlot, this.x_, this.y_, 0); //use the unneeded potion
                    map_.gs_.gsc_.invSwap(this,bag,slot1,lootedItemtype,this,putToSlot,-1);
                }
                else {
                    map_.gs_.gsc_.invSwap(this,bag,slot1,lootedItemtype,this,putToSlot,equipment_[putToSlot]);
                }
            }
        }
        lastLootTime = getTimer();
    }

    public function nextAvailableInventorySlotMod():int { //-1 = no slots; 0-11 = this slot
        var _local_1:int = this.hasBackpack_ ? equipment_.length : (equipment_.length - GeneralConstants.NUM_INVENTORY_SLOTS);
        var _local_2:uint = 4;
        while (_local_2 < _local_1) { //see if slot is open
            if (equipment_[_local_2] == -1) {
                nextLootSlot = equipment_[_local_2];
                return (_local_2);
            }
            _local_2++;
        }
        _local_2 = 4;
        while (_local_2 < _local_1) { //see if slot has a potion
            if (equipment_[_local_2] == HEALTH_POT || equipment_[_local_2] == MAGIC_POT) {
                nextLootSlot = equipment_[_local_2];
                return (_local_2);
            }
            _local_2++;
        }
        return (-1);
    }

    public function okToLoot(item:int) : Boolean
    {
        var _loc2_:int = getTimer();
        var _loc3_:int = _loc2_ - lastLootTime;
        if (Parameters.data.autoDrink
                && (Potions.indexOf(item) != -1 || item == 0x4995))
            return false;
        if (_loc3_ < LOOT_EVERY_MS) {
            return false; //too early to loot
        }
        if (nextAvailableInventorySlotMod() != -1 || (item == HEALTH_POT && healthPotionCount_ < 6) || (item == MAGIC_POT && magicPotionCount_ < 6)) {
            return true; //we have slots
        }
        return false; //we have no slots
    }

    public function autoLoot() : void {
        var _loc1_:Container = null;
        var _loc2_:int = 0;
        var _loc3_:Player = null;
        var _loc4_:int = 0;
        var _loc5_:Vector.<Container> = getLootBags();
        _loc5_ = getLootableBags(_loc5_,MAX_LOOT_DIST);
        for each(_loc1_ in _loc5_) {
            _loc4_ = 0;
            for each(_loc2_ in _loc1_.equipment_) {
                if (isWantedItem(_loc2_) && okToLoot(_loc2_)) { //is item wanted?
                    if (_loc1_.objectId_ != GameServerConnection.ignoredBag) {
                        //addTextLine.dispatch(ChatMessage.make("", "Looting bag id "+_loc1_.objectId_));
                        lootItem(nextAvailableInventorySlotMod(),_loc1_,_loc4_,_loc2_);
                    }
                    return;
                }
                _loc4_ = _loc4_ + 1;
            }
        }
    }

    public function useAltWeapon(xS:Number, yS:Number, useType:int):Boolean {
        var activateXML:XML = null;
        var now:int = 0;
        var angle:Number = NaN;
        var mpCost:int = 0;
        var cooldown:int = 0;
        if (map_ == null || isPaused()) {
            return false;
        }
        var itemType:int = equipment_[1];
        if (itemType == -1) {
            return false;
        }
        var objectXML:XML = ObjectLibrary.xmlLibrary_[itemType];
        if (objectXML == null || !objectXML.hasOwnProperty("Usable")) {
            return false;
        }
        var pW:Point = map_.pSTopW(xS, yS);
        if (pW == null) {
            SoundEffectLibrary.play("error");
            return false;
        }
        for each(activateXML in objectXML.Activate) {
            if (activateXML.toString() == ActivationType.TELEPORT) {
                if (!this.isValidPosition(pW.x, pW.y)) {
                    SoundEffectLibrary.play("error");
                    return false;
                }
            }
        }
        now = getTimer();
        if (useType == UseType.START_USE) {
            if (now < this.nextAltAttack_) {
                SoundEffectLibrary.play("error");
                return false;
            }
            mpCost = int(objectXML.MpCost);
            if (mpCost > this.mp_) {
                SoundEffectLibrary.play("no_mana");
                return false;
            }
            cooldown = 500;
            if (objectXML.hasOwnProperty("Cooldown")) {
                cooldown = Number(objectXML.Cooldown) * 1000;
            }
            this.nextAltAttack_ = now + cooldown;
            map_.gs_.gsc_.useItem(now, objectId_, 1, itemType, pW.x, pW.y, useType);
            if (objectXML.Activate == ActivationType.SHOOT) {
                angle = Math.atan2(yS, xS);
                this.doShoot(now, itemType, objectXML, Parameters.data.cameraAngle + angle, false);
            }
        } else if (objectXML.hasOwnProperty("MultiPhase")) {
            map_.gs_.gsc_.useItem(now, objectId_, 1, itemType, pW.x, pW.y, useType);
            mpCost = int(objectXML.MpEndCost);
            if (mpCost <= this.mp_) {
                angle = Math.atan2(yS, xS);
                this.doShoot(now, itemType, objectXML, Parameters.data.cameraAngle + angle, false);
            }
        }
        return true;
    }

    public function attemptAttackAngle(_arg_1:Number):void { //this is used to shoot
        //this.shoot((Parameters.data_.cameraAngle + _arg_1));
        aim_(_arg_1);
    }

    //AIM BEGIN
    public function autoAim_(param1:Vector3D, param2:Vector3D, param3:ProjectileProperties) : Vector3D {
        var _loc4_:Vector3D;
        var _loc5_:GameObject;
        var _loc6_:Boolean = false;
        var _loc7_:int = 0;
        var _loc8_:Boolean = false;
        var _loc9_:Vector3D;
        var _loc10_:* = undefined;
        var _loc11_:Number;
        var _loc12_:Number;
        var _loc13_:int = Parameters.data.aimMode;
        var _loc14_:Number = param3.speed_ / 10000;
        var range:Number = _loc14_ * param3.lifetime_ + (Parameters.data.AAAddOne ? 0.5 : 0);
        if (Parameters.data.killAura)
            range = Parameters.data.kaRangeSqr == -1 ? 9000
                        : Math.sqrt(Parameters.data.kaRangeSqr);

        var _loc16_:Number = 0;
        var _loc17_:Number = int.MAX_VALUE;
        var _loc18_:Number = int.MAX_VALUE;
        var i:int;
        aimAssistTarget = null;
        for each(_loc5_ in map_.goDict_) {
            if (_loc5_.props_.isEnemy_) {
                _loc6_ = false;
                for each(_loc7_ in Parameters.data.AAException) { //get exceptions
                    if (_loc7_ == _loc5_.props_.type_) {
                        _loc6_ = true;
                        break;
                    }
                }
                if (!Parameters.data.tombHack && _loc5_.props_.type_ >= 3366 && _loc5_.props_.type_ <= 3368) { //tomb hack off -> don't shoot shielded bosses
                    _loc6_ = false;
                }
                if (_loc6_ || _loc5_ is Character) {
                    if (!(!_loc6_ && (_loc5_.isStasis() || _loc5_.isInvulnerable() || _loc5_.isInvincible()))) {
                        _loc8_ = false;
                        for each(_loc7_ in Parameters.data.AAIgnore) {
                            if (_loc7_ == _loc5_.props_.type_) {
                                _loc8_ = true;
                                break;
                            }
                        }
                        if (!_loc8_) {
                            if (_loc5_.jittery || !Parameters.data.AATargetLead || _loc5_.objectType_ == 3334) {
                                _loc9_ = new Vector3D(_loc5_.x_,_loc5_.y_);
                            }
                            else {
                                _loc9_ = leadPos(param1,new Vector3D(_loc5_.x_,_loc5_.y_),new Vector3D(_loc5_.moveVec_.x,_loc5_.moveVec_.y),_loc14_);
                            }
                            if (_loc9_ != null) {
                                _loc10_ = getDist(param1.x,param1.y,_loc9_.x,_loc9_.y);
                                if (_loc10_ <= range) {
                                    if(_loc13_ == 1) { //aimmode: highest hp
                                        _loc12_ = _loc5_.maxHP_;
                                        switch (_loc5_.objectType_) {
                                            case 1625: //ghost god
                                                _loc12_ = 3000;
                                            case 3369: //sarc
                                                _loc12_ = 7500;
                                            case 3371: //fem priest
                                                _loc12_ = 8000;
                                        }
                                        for each(i in Parameters.data.AAPriority) { //prioritize list
                                            if (i == _loc5_.objectType_) {
                                                _loc12_ = int.MAX_VALUE;
                                            }
                                        }
                                        if (Parameters.data.tombHack && ((_loc5_.objectType_ >= 3366 && _loc5_.objectType_ <= 3368) || (_loc5_.objectType_ >= 32692 && _loc5_.objectType_ <= 32694))) { //tomb bosses
                                            if (_loc5_.objectType_ != Parameters.data.curBoss && _loc5_.objectType_ != Parameters.data.curBoss + 29326) {
                                                //_loc12_ = 10000;
                                                continue;
                                            }
                                        }
                                        if (_loc12_ >= _loc16_) {
                                            if (_loc12_ == _loc16_) {
                                                if (_loc5_.hp_ > _loc17_) {
                                                    continue;
                                                }
                                                if (_loc5_.hp_ == _loc17_ && _loc10_ > _loc18_) {
                                                    continue;
                                                }
                                                _loc17_ = _loc5_.hp_;
                                                _loc4_ = _loc9_;
                                                _loc18_ = _loc10_;
                                                aimAssistTarget = _loc5_;
                                            }
                                            else {
                                                _loc4_ = _loc9_;
                                                _loc17_ = _loc5_.hp_;
                                                _loc16_ = _loc12_;
                                                _loc18_ = _loc10_;
                                                aimAssistTarget = _loc5_;
                                            }
                                        }
                                    }
                                    else if (_loc13_ == 2) { //aimmode: closest
                                        if (_loc10_ < _loc18_) {
                                            _loc4_ = _loc9_;
                                            _loc17_ = _loc5_.hp_;
                                            _loc16_ = _loc5_.maxHP_;
                                            _loc18_ = _loc10_;
                                            aimAssistTarget = _loc5_;
                                        }
                                    }
                                    else { //aimmode: closest to cursor
                                        _loc11_ = Parameters.data.AABoundingDist;
                                        _loc10_ = getDist(param2.x,param2.y,_loc5_.x_,_loc5_.y_);
                                        if (Math.abs(param2.x - _loc9_.x) <= _loc11_ && Math.abs(param2.y - _loc9_.y) <= _loc11_) {
                                            if (_loc10_ <= _loc18_) {
                                                _loc4_ = _loc9_;
                                                _loc17_ = _loc5_.hp_;
                                                _loc16_ = _loc5_.maxHP_;
                                                _loc18_ = _loc10_;
                                                aimAssistTarget = _loc5_;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return _loc4_;
    }

    public function getDist(param1:Number, param2:Number, param3:Number, param4:Number):Number {
        var _loc5_:* = param1 - param3;
        var _loc6_:* = param2 - param4;
        return Math.sqrt(_loc6_ * _loc6_ + _loc5_ * _loc5_);
    }

    public function leadPos(param1:Vector3D, param2:Vector3D, param3:Vector3D, param4:Number):Vector3D {
        var _loc5_:Vector3D = param2.subtract(param1);
        var _loc6_:* = param3.dotProduct(param3) - param4 * param4;
        var _loc7_:* = 2 * _loc5_.dotProduct(param3);
        var _loc8_:* = _loc5_.dotProduct(_loc5_);
        var _loc9_:* = (-_loc7_ + Math.sqrt(_loc7_ * _loc7_ - 4 * _loc6_ * _loc8_)) / (2 * _loc6_);
        var _loc10_:* = (-_loc7_ - Math.sqrt(_loc7_ * _loc7_ - 4 * _loc6_ * _loc8_)) / (2 * _loc6_);
        if (_loc9_ < _loc10_ && _loc9_ >= 0) {
            param3.scaleBy(_loc9_);
        }
        else if (_loc10_ >= 0) {
            param3.scaleBy(_loc10_);
        }
        else {
            return null;
        }
        return param2.add(param3);
    }

    public function getAimAngle():Number {
        if (equipment_[0] <= 0)
            return 0;
        var _loc1_:Vector3D = null;
        var _loc2_:Vector3D = null;
        var _loc3_:Point = null;
        var _loc4_:ProjectileProperties = null;
        var _loc5_:Vector3D = null;
        _loc3_ = sToW(map_.mouseX,map_.mouseY);
        if(_loc3_ == null)
        {
            _loc3_ = new Point(x_,y_);
        }
        _loc2_ = new Vector3D(_loc3_.x,_loc3_.y);
        _loc1_ = new Vector3D(x_,y_);
        _loc4_ = ObjectLibrary.propsLibrary_[equipment_[0]].projectiles_[0];
        aimAssistPoint = autoAim_(_loc1_,_loc2_,_loc4_);
        if(aimAssistPoint != null)
        {
            return Math.atan2(aimAssistPoint.y - y_,aimAssistPoint.x - x_);
        }
        return Number.MAX_VALUE;
    }

    public function pSTopW(param1:Number, param2:Number):Point { //inaccurate
        var po:Point = sToW(param1, param2);
        po.x = int(po.x) + 1 / 2;
        po.y = int(po.y) + 1 / 2;
        return po;
    }

    public function sToW(param1:Number, param2:Number):Point { //accurate
        var _loc3_:* = Parameters.data.cameraAngle;
        var _loc4_:* = Math.cos(_loc3_);
        var _loc5_:* = Math.sin(_loc3_);
        param1 = param1 / 50.5;
        param2 = param2 / 50.5;
        var _loc6_:* = param1 * _loc4_ - param2 * _loc5_;
        var _loc7_:* = param1 * _loc5_ + param2 * _loc4_;
        return new Point(map_.player_.x_ + _loc6_,map_.player_.y_ + _loc7_);
    }

    public function aim_(param1:Number) : void
    {
        var _loc5_:Number = NaN;
        var _loc2_:Boolean = map_.gs_.mui_.mouseDown_;
        var _loc3_:Boolean = map_.gs_.mui_.autofire_;
        var _loc4_:Boolean = Parameters.data.AAOn;
        if(_loc4_ && !_loc2_)
        {
            _loc5_ = getAimAngle();
            if(_loc5_ != Number.MAX_VALUE && !isUnstable())
            {
                shoot(_loc5_);
                return;
            }
            if(!_loc3_)
            {
                return;
            }
        }
        shoot(Parameters.data.cameraAngle + param1);
    }

    public function isHexed():Boolean {
        return (condition_[0] & ConditionEffect.HEXED_BIT) != 0;
    }

    public function isInventoryFull():Boolean {
        var len:int = equipment_.length;
        for (var i:uint = 4; i < len; i++) {
            if (equipment_[i] <= 0) {
                return false;
            }
        }
        return true;
    }

    public function nextAvailableInventorySlot() : int {
        var len:int = this.hasBackpack_ ? equipment_.length :
                equipment_.length + GeneralConstants.NUM_INVENTORY_SLOTS;
        for (var i:uint = 4; i < len; i++)
            if (equipment_[i] <= 0)
                return i;

        return -1;
    }

    public function swapInventoryIndex(current:String):int {
        var start:int = 0;
        var end:int = 0;
        if (!this.hasBackpack_) {
            return -1;
        }
        if (current == TabStripModel.BACKPACK) {
            start = GeneralConstants.NUM_EQUIPMENT_SLOTS;
            end = GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS;
        } else {
            start = GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS;
            end = equipment_.length;
        }
        for (var i:uint = start; i < end; i++) {
            if (equipment_[i] <= 0) {
                return i;
            }
        }
        return -1;
    }

    public function getPotionCount(objectType:int):int {
        switch (objectType) {
            case PotionInventoryModel.HEALTH_POTION_ID:
                return this.healthPotionCount_;
            case PotionInventoryModel.MAGIC_POTION_ID:
                return this.magicPotionCount_;
            default:
                return 0;
        }
    }

    protected function drawBreathBar(graphicsData:Vector.<IGraphicsData>, time:int):void {
        var b:Number = NaN;
        var bw:Number = NaN;
        if (this.breathPath_ == null) {
            this.breathBackFill_ = new GraphicsSolidFill();
            this.breathBackPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
            this.breathFill_ = new GraphicsSolidFill(2542335);
            this.breathPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
        }
        if (this.breath_ <= Parameters.BREATH_THRESH) {
            b = (Parameters.BREATH_THRESH - this.breath_) / Parameters.BREATH_THRESH;
            this.breathBackFill_.color = MoreColorUtil.lerpColor(5526612, 16711680, Math.abs(Math.sin(time / 300)) * b);
        } else {
            this.breathBackFill_.color = 5526612;
        }
        var w:int = DEFAULT_HP_BAR_WIDTH;
        var yOffset:int = DEFAULT_HP_BAR_Y_OFFSET + DEFAULT_HP_BAR_HEIGHT;
        var h:int = DEFAULT_HP_BAR_HEIGHT;
        this.breathBackPath_.data.length = 0;
        this.breathBackPath_.data.push(posS_[0] - w, posS_[1] + yOffset, posS_[0] + w, posS_[1] + yOffset, posS_[0] + w, posS_[1] + yOffset + h, posS_[0] - w, posS_[1] + yOffset + h);
        graphicsData.push(this.breathBackFill_);
        graphicsData.push(this.breathBackPath_);
        graphicsData.push(GraphicsUtil.END_FILL);
        if (this.breath_ > 0) {
            bw = this.breath_ / 100 * 2 * w;
            this.breathPath_.data.length = 0;
            this.breathPath_.data.push(posS_[0] - w, posS_[1] + yOffset, posS_[0] - w + bw, posS_[1] + yOffset, posS_[0] - w + bw, posS_[1] + yOffset + h, posS_[0] - w, posS_[1] + yOffset + h);
            graphicsData.push(this.breathFill_);
            graphicsData.push(this.breathPath_);
            graphicsData.push(GraphicsUtil.END_FILL);
        }
        GraphicsFillExtra.setSoftwareDrawSolid(this.breathFill_, true);
        GraphicsFillExtra.setSoftwareDrawSolid(this.breathBackFill_, true);
    }

    private function getNearbyMerchant():Merchant {
        var p:Point = null;
        var m:Merchant = null;
        var dx:int = x_ - int(x_) > 0.5 ? int(int(1)) : int(int(-1));
        var dy:int = y_ - int(y_) > 0.5 ? int(int(1)) : int(int(-1));
        for each(p in NEARBY) {
            this.ip_.x_ = x_ + dx * p.x;
            this.ip_.y_ = y_ + dy * p.y;
            m = map_.merchLookup_[this.ip_];
            if (m != null) {
                return PointUtil.distanceSquaredXY(m.x_, m.y_, x_, y_) < 1 ? m : null;
            }
        }
        return null;
    }

    private function getMoveSpeed():Number {
        if (isSlowed()) {
            return MIN_MOVE_SPEED * this.moveMultiplier_;
        }
        var speed:int = Parameters.data.forcedSpeed != -1 ? Parameters.data.forcedSpeed : this.speed_;
        var moveSpeed:Number = MIN_MOVE_SPEED + speed / 75 * (MAX_MOVE_SPEED - MIN_MOVE_SPEED);
        if (isSpeedy() || isNinjaSpeedy()) {
            moveSpeed = moveSpeed * 1.5;
        }
        moveSpeed = moveSpeed * this.moveMultiplier_;
        return moveSpeed;
    }

    private function attackMultiplier():Number {
        if (isWeak()) {
            return MIN_ATTACK_MULT;
        }
        var attMult:Number = MIN_ATTACK_MULT + this.attack_ / 75 * (MAX_ATTACK_MULT - MIN_ATTACK_MULT);
        if (isDamaging() || isNinjaDamaging()) {
            attMult = attMult * 1.5;
        }
        return attMult;
    }

    private function makeSkinTexture():void {
        var image:MaskedImage = this.skin.imageFromAngle(0, AnimatedChar.STAND, 0);
        animatedChar_ = this.skin;
        texture_ = image.image_;
        mask_ = image.mask_;
        this.isDefaultAnimatedChar = true;
    }

    private function setToRandomAnimatedCharacter():void {
        var hexTransformList:Vector.<XML> = ObjectLibrary.hexTransforms_;
        var randIndex:uint = Math.floor(Math.random() * hexTransformList.length);
        var randomPetType:int = hexTransformList[randIndex].@type;
        var textureData:TextureData = ObjectLibrary.typeToTextureData_[randomPetType];
        texture_ = textureData.texture_;
        mask_ = textureData.mask_;
        animatedChar_ = textureData.animatedChar_;
        this.isDefaultAnimatedChar = false;
    }

    private function shoot(attackAngle:Number):void {
        if (map_ == null || isStunned() || isPaused() || isPetrified()) {
            return;
        }
        var weaponType:int = equipment_[0];
        if (weaponType == -1) {
            this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME, "You do not have a weapon equipped!"));
            return;
        }
        var weaponXML:XML = ObjectLibrary.xmlLibrary_[weaponType];
        var time:int = getTimer();
        var bigSkill:Number = this.bigSkill11?Number(0.3):Number(0);
        if (this.smallSkill11 > 0) {
            bigSkill = bigSkill + this.smallSkill11 * 0.02;
        }
        if(this.bigSkill1) {
            bigSkill = bigSkill - 0.1;
        }
        if(this.bigSkill4) {
            bigSkill = bigSkill - 0.05;
        }
        var rateSkill:Number = bigSkill * Number(weaponXML.RateOfFire);
        var rateOfFire:Number = Number(weaponXML.RateOfFire) + rateSkill;
        if (!Parameters.data.ROFHack)
            this.attackPeriod_ = 1 / this.attackFrequency() * (1 / rateOfFire);
        else
            this.attackPeriod_ = 0;
        if (time < attackStart_ + this.attackPeriod_) {
            return;
        }
        doneAction(map_.gs_, Tutorial.ATTACK_ACTION);
        attackAngle_ = attackAngle;
        attackStart_ = time;
        this.doShoot(attackStart_, weaponType, weaponXML, attackAngle_, true);
    }

    private function doShoot(time:int, weaponType:int, weaponXML:XML, attackAngle:Number, useMult:Boolean):void {
        var bulletId:uint = 0;
        var proj:Projectile = null;
        var minDamage:int = 0;
        var maxDamage:int = 0;
        var attMult:Number = NaN;
        var damage:int = 0;
        var numProjs:int = Boolean(weaponXML.hasOwnProperty("NumProjectiles")) ? int(int(int(weaponXML.NumProjectiles))) : int(int(1));
        var arcGap:Number = (Boolean(weaponXML.hasOwnProperty("ArcGap")) ? Number(weaponXML.ArcGap) : 11.25) * Trig.toRadians;
        var totalArc:Number = arcGap * (numProjs - 1);
        var angle:Number = attackAngle - totalArc / 2;
        for (var i:int = 0; i < numProjs; i++) {
            bulletId = getBulletId();
            proj = FreeList.newObject(Projectile) as Projectile;
            proj.reset(weaponType, 0, objectId_, bulletId, angle, time);
            minDamage = int(proj.projProps_.minDamage_);
            maxDamage = int(proj.projProps_.maxDamage_);
            attMult = !!useMult ? Number(Number(this.attackMultiplier())) : Number(Number(1));
            damage = map_.gs_.gsc_.getNextDamage(minDamage, maxDamage) * attMult;
            if (time > map_.gs_.moveRecords_.lastClearTime_ + 600) {
                damage = 0;
            }
            proj.setDamage(damage);
            if (i == 0 && proj.sound_ != null) {
                SoundEffectLibrary.play(proj.sound_, 0.75, false);
            }
            map_.addObj(proj, x_ + Math.cos(attackAngle) * 0.3, y_ + Math.sin(attackAngle) * 0.3);
            map_.gs_.gsc_.playerShoot(time, proj);
            angle = angle + arcGap;
        }
    }
}
}
