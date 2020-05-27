package kabam.rotmg.BountyBoard.SubscriptionUI {
import com.company.assembleegameclient.sound.SoundEffectLibrary;

import kabam.lib.net.api.MessageProvider;
import kabam.lib.net.impl.SocketServer;
import kabam.rotmg.dialogs.control.CloseDialogsSignal;

import org.swiftsuspenders.Injector;

import robotlegs.bender.bundles.mvcs.Mediator;

public class SubscriptionUIMediator extends Mediator {


    public function SubscriptionUIMediator() {
        super();
    }
    [Inject]
    public var injector:Injector;
    [Inject]
    public var closeDialogs:CloseDialogsSignal;
    [Inject]
    public var view:SubscriptionUI;
    [Inject]
    public var socketServer:SocketServer;
    [Inject]
    public var messages:MessageProvider;

    override public function initialize():void {
        this.view.close.add(this.onCancel);
    }

    private function onCancel():void {
        SoundEffectLibrary.play("button_click");
        this.closeDialogs.dispatch();
    }
}
}
