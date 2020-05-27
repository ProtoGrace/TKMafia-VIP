package kabam.rotmg.ui.view {
import com.company.assembleegameclient.mapeditor.MapEditor;
import com.company.assembleegameclient.screens.CreditsScreen;
import com.company.assembleegameclient.screens.ServersScreen;

import kabam.rotmg.account.core.signals.OpenAccountInfoSignal;
import kabam.rotmg.account.core.signals.OpenVerChangeSignal;
import kabam.rotmg.application.api.ApplicationSetup;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.core.signals.SetScreenSignal;
import kabam.rotmg.core.signals.SetScreenWithValidDataSignal;
import kabam.rotmg.dialogs.control.OpenDialogSignal;
import kabam.rotmg.legends.view.LegendsView;
import kabam.rotmg.ui.model.EnvironmentData;
import kabam.rotmg.ui.signals.EnterGameSignal;

import robotlegs.bender.bundles.mvcs.Mediator;

public class TitleMediator extends Mediator {


    public function TitleMediator() {
        super();
    }
    [Inject]
    public var view:TitleView;
    [Inject]
    public var playerModel:PlayerModel;
    [Inject]
    public var setScreen:SetScreenSignal;
    [Inject]
    public var setScreenWithValidData:SetScreenWithValidDataSignal;
    [Inject]
    public var enterGame:EnterGameSignal;
    [Inject]
    public var openAccountInfo:OpenAccountInfoSignal;
    [Inject]
    public var openVerChange:OpenVerChangeSignal;
    [Inject]
    public var openDialog:OpenDialogSignal;
    [Inject]
    public var setup:ApplicationSetup;

    override public function initialize():void {
        this.view.initialize(this.makeEnvironmentData());
        this.view.playClicked.add(this.handleIntentionToPlay);
        this.view.serversClicked.add(this.showServersScreen);
        this.view.creditsClicked.add(this.showCreditsScreen);
        this.view.accountClicked.add(this.handleIntentionToReviewAccount);
        this.view.legendsClicked.add(this.showLegendsScreen);
        this.view.editorClicked.add(this.showMapEditor);
        this.view.verClicked.add(this.showVerChangeDialog);
    }

    override public function destroy():void {
        this.view.playClicked.remove(this.handleIntentionToPlay);
        this.view.serversClicked.remove(this.showServersScreen);
        this.view.creditsClicked.remove(this.showCreditsScreen);
        this.view.accountClicked.remove(this.handleIntentionToReviewAccount);
        this.view.legendsClicked.remove(this.showLegendsScreen);
        this.view.editorClicked.remove(this.showMapEditor);
        this.view.verClicked.remove(this.showVerChangeDialog);
    }

    private function makeEnvironmentData():EnvironmentData {
        var data:EnvironmentData = new EnvironmentData();
        data.isAdmin = this.playerModel.isAdmin();
        data.buildLabel = this.setup.getBuildLabel();
        return data;
    }

    private function handleIntentionToPlay():void {
        this.enterGame.dispatch();
    }

    private function showCreditsScreen():void {
        this.setScreen.dispatch(new CreditsScreen());
    }

    private function showServersScreen():void {
        this.setScreen.dispatch(new ServersScreen());
    }

    private function handleIntentionToReviewAccount():void {
        this.openAccountInfo.dispatch(false);
    }

    private function showLegendsScreen():void {
        this.setScreen.dispatch(new LegendsView());
    }

    private function showMapEditor():void {
        this.setScreen.dispatch(new MapEditor());
    }

    private function showVerChangeDialog():void {
        this.openVerChange.dispatch();
    }
}
}
