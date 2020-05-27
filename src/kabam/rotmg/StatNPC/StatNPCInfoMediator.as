package kabam.rotmg.StatNPC {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.sound.SoundEffectLibrary;

import io.decagames.rotmg.ui.popups.signals.ShowPopupSignal;

import kabam.lib.net.api.MessageProvider;
import kabam.lib.net.impl.SocketServer;
import kabam.rotmg.dialogs.control.CloseDialogsSignal;
import kabam.rotmg.dialogs.control.OpenDialogSignal;

import org.swiftsuspenders.Injector;

import robotlegs.bender.bundles.mvcs.Mediator;

public class StatNPCInfoMediator extends Mediator {


    public function StatNPCInfoMediator() {
        super();
    }
    [Inject]
    public var injector:Injector;
    [Inject]
    public var closeDialogs:CloseDialogsSignal;
    [Inject]
    public var view:StatNPCInfo;
    [Inject]
    public var socketServer:SocketServer;
    [Inject]
    public var messages:MessageProvider;
    [Inject]
    public var showPopupSignal:ShowPopupSignal;
    [Inject]
    public var openDialog:OpenDialogSignal;
    private var gameSprite:GameSprite;

    override public function initialize():void {
        this.gameSprite = this.view.gs;
        this.view.quit.add(this.onQuit);
    }

    override public function destroy():void {
    }

    private function onQuit():void {
        this.openDialog.dispatch(new StatNPCModal(this.gameSprite));
    }

    private function onCancel():void {
        SoundEffectLibrary.play("button_click");
        this.closeDialogs.dispatch();
    }
}
}
