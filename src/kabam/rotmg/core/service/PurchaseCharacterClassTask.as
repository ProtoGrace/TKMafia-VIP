package kabam.rotmg.core.service {
import com.company.assembleegameclient.appengine.SavedCharactersList;
import com.company.util.MoreObjectUtil;

import kabam.lib.tasks.BaseTask;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.core.model.PlayerModel;

import robotlegs.bender.framework.api.ILogger;

public class PurchaseCharacterClassTask extends BaseTask {


    public function PurchaseCharacterClassTask() {
        super();
    }
    [Inject]
    public var classType:int;
    [Inject]
    public var account:Account;
    [Inject]
    public var client:AppEngineClient;
    [Inject]
    public var playerModel:PlayerModel;
    [Inject]
    public var logger:ILogger;

    override protected function startTask():void {
        this.logger.info("PurchaseCharacterClassTask.startTask: Started ");
        this.client.complete.addOnce(this.onComplete);
        this.client.sendRequest("/char/purchaseClassUnlock", this.makeRequestPacket());
    }

    public function makeRequestPacket():Object {
        var params:Object = {};
        params.classType = this.classType;
        MoreObjectUtil.addToObject(params, this.account.getCredentials());
        return params;
    }

    private function onComplete(isOK:Boolean, data:*):void {
        this.logger.info("PurchaseCharacterClassTask.onComplete: Ended ");
        isOK && this.onReceiveResponseFromClassPurchase();
        completeTask(isOK, data);
    }

    private function onReceiveResponseFromClassPurchase():void {
        this.playerModel.setClassAvailability(this.classType, SavedCharactersList.UNRESTRICTED);
        completeTask(true);
    }
}
}
