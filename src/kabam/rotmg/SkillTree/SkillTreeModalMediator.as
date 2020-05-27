package kabam.rotmg.SkillTree {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.sound.SoundEffectLibrary;

import kabam.lib.net.api.MessageProvider;
import kabam.lib.net.impl.SocketServer;
import kabam.rotmg.dialogs.control.CloseDialogsSignal;

import org.swiftsuspenders.Injector;

import robotlegs.bender.bundles.mvcs.Mediator;

public class SkillTreeModalMediator extends Mediator {


    public function SkillTreeModalMediator() {
        super();
    }
    [Inject]
    public var injector:Injector;
    [Inject]
    public var closeDialogs:CloseDialogsSignal;
    [Inject]
    public var view:SkillTreeModal;
    [Inject]
    public var socketServer:SocketServer;
    [Inject]
    public var messages:MessageProvider;
    private var gameSprite:GameSprite;


    override public function destroy() : void {
        this.view.gs_.mui_.setEnablePlayerInput(true);
        this.view.gs_.mui_.setEnableHotKeysInput(true);
    }

    override public function initialize():void {
        this.gameSprite = this.view.gs_;
        this.view.close.add(this.onCancel);
    }

    private function onCancel():void {
        this.view.gs_.mui_.setEnablePlayerInput(true);
        this.view.gs_.mui_.setEnableHotKeysInput(true);
        SoundEffectLibrary.play("button_click");
        this.closeDialogs.dispatch();
    }
}
}
