package kabam.rotmg.StatNPC {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.company.ui.SimpleText;

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import io.decagames.rotmg.ui.buttons.SliceScalingButton;
import io.decagames.rotmg.ui.defaults.DefaultLabelFormat;
import io.decagames.rotmg.ui.popups.header.PopupHeader;
import io.decagames.rotmg.ui.popups.modal.ModalPopup;
import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;
import io.decagames.rotmg.ui.texture.TextureParser;

import kabam.rotmg.assets.services.IconFactory;
import kabam.rotmg.classes.model.ClassesModel;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.game.model.GameModel;

import org.osflash.signals.Signal;

public class StatNPCModal extends ModalPopup {


    public const upgrade:Signal = new Signal();
    public const close:Signal = new Signal();
    public const info:Signal = new Signal();

    public function StatNPCModal(gameSprite:GameSprite) {
        var filter:DropShadowFilter = null;
        this.gs_ = gameSprite;
        super(400, 400, "Magician");
        this.x = 110;
        this.y = 70;
        filter = new DropShadowFilter(0, 0, 0, 1, 8, 8);
        this.player = StaticInjectorContext.getInjector().getInstance(GameModel).player;
        this.quitButton = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI", "close_button"));
        this.header.addButton(this.quitButton, PopupHeader.RIGHT_BUTTON);
        this.quitButton.addEventListener(MouseEvent.CLICK, this.onClose);
        this.infoButton = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI", "info_button"));
        this.header.addButton(this.infoButton, PopupHeader.LEFT_BUTTON);
        this.infoButton.addEventListener(MouseEvent.CLICK, this.onInfo);
        this.yourStats = new SimpleText(35, 16777215, false, 200, 0);
        this.yourStats.wordWrap = false;
        this.yourStats.setText("Your Stats: ");
        this.yourStats.setBold(true);
        this.yourStats.filters = [new DropShadowFilter(0, 0, 0)];
        this.yourStats.x = 25;
        this.yourStats.y = 25;
        addChild(this.yourStats);
        this.stats = new SimpleText(17, 16777215, false, 200);
        this.stats.setBold(true).setText("Set Base Stat: +" + this.player.baseStat);
        this.stats.x = 25;
        this.stats.y = 65;
        addChild(this.stats);
        this.nextPrice = new SimpleText(17, 16777215, false, 200);
        this.nextPrice.setText("Next Price: " + this.checkNextCost());
        this.nextPrice.x = 25;
        this.nextPrice.y = 95;
        this.fameIcon = new Bitmap(IconFactory.makeFame());
        this.fameIcon.filters = [filter];
        this.fameIcon.x = this.nextPrice.x + 132;
        this.fameIcon.y = this.nextPrice.y;
        if (this.player.baseStat >= 10) {
            this.nextPrice.setText("Next Price: Maxed!").setColor(16777215).setSize(17);
            this.fameIcon.alpha = 0;
        }
        addChild(this.nextPrice);
        addChild(this.fameIcon);
        this.upgradeButton = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI", SliceScalingBitmap.greenButton), null, null, false);
        this.upgradeButton.width = 180;
        this.upgradeButton.x = 100;
        this.upgradeButton.y = 350;
        this.upgradeButton.setLabel("Upgrade " + this.checkNextCost(), DefaultLabelFormat.defaultModalTitle);
        this.upgradeButton.label.y = this.upgradeButton.label.y + 8;
        this.upgradeButton.label.x = this.upgradeButton.label.x + 13;
        this.fameButtonIcon = new Bitmap(IconFactory.makeFame());
        this.fameButtonIcon.filters = [filter];
        this.fameButtonIcon.x = this.upgradeButton.x + 142.5;
        this.fameButtonIcon.y = this.upgradeButton.y + 7;
        if (this.player.baseStat >= 10) {
            this.upgradeButton.disabled = true;
            this.upgradeButton.setLabel("Maxed!", DefaultLabelFormat.defaultModalTitle);
            this.upgradeButton.label.x = this.upgradeButton.label.x + 48;
            this.fameButtonIcon.alpha = 0;
        }
        this.upgradeButton.addEventListener(MouseEvent.CLICK, this.onUpgrade);
        addChild(this.upgradeButton);
        addChild(this.fameButtonIcon);
        this.statsPlayer = new SimpleText(17, 16777215, false, 200, 400);
        this.statsPlayer.setText("Life: " + this.player.hp_ + " (+" + this.player.baseStat * 5 + ")\n" + "Mana: " + this.player.mp_ + " (+" + this.player.baseStat * 5 + ")\n" + "Attack: " + this.player.attack_ + " (+" + this.player.baseStat + ")\n" + "Defense: " + this.player.defense_ + " (+" + this.player.baseStat + ")\n" + "Speed: " + this.player.speed_ + " (+" + this.player.baseStat + ")\n" + "Dexterity: " + this.player.dexterity_ + " (+" + this.player.baseStat + ")\n" + "Vitality: " + this.player.vitality_ + " (+" + this.player.baseStat + ")\n" + "Wisdom: " + this.player.wisdom_ + " (+" + this.player.baseStat + ")");
        this.statsPlayer.x = 250;
        this.statsPlayer.y = 65;
        addChild(this.statsPlayer);
    }
    var yourStats:SimpleText;
    var stats:SimpleText;
    var nextPrice:SimpleText;
    var statsPlayer:SimpleText;
    var gs_:GameSprite;
    var player:Player;
    var classesmodel:ClassesModel;
    var infoButton:SliceScalingButton;
    var quitButton:SliceScalingButton;
    var upgradeButton:SliceScalingButton;
    var fameIcon:Bitmap;
    var fameButtonIcon:Bitmap;

    public function checkNextCost():int {
        var _local1:* = undefined;
        var playerbaseStat:* = this.player.baseStat;
        switch (playerbaseStat) {
            case 0:
                _local1 = 10000;
                break;
            case 1:
                _local1 = 20000;
                break;
            case 2:
                _local1 = 30000;
                break;
            case 3:
                _local1 = 40000;
                break;
            case 4:
                _local1 = 50000;
                break;
            case 5:
                _local1 = 60000;
                break;
            case 6:
                _local1 = 70000;
                break;
            case 7:
                _local1 = 80000;
                break;
            case 8:
                _local1 = 90000;
                break;
            case 9:
                _local1 = 100000;
                break;
            case 10:
                _local1 = "Maxed";
        }
        return _local1;
    }

    private function onUpgrade(arg1:Event):void {
        this.upgrade.dispatch();
    }

    private function onInfo(arg1:Event):void {
        this.info.dispatch();
    }

    private function onClose(arg1:Event):void {
        this.close.dispatch();
    }
}
}
