package kabam.rotmg.application.impl {
import com.company.assembleegameclient.parameters.Parameters;

import kabam.rotmg.application.api.ApplicationSetup;

public class LocalhostSetup implements ApplicationSetup {


    private const SERVER:String = "http://127.0.0.1:2000";

    public function LocalhostSetup() {
        super();
    }

    public function getAppEngineUrl(_arg1:Boolean = false):String {
        return this.SERVER;
    }

    public function getBuildLabel():String {
        return "TK1* - build: " + Parameters.data.customVersion.toString();
    }

    public function useProductionDialogs():Boolean {
        return false;
    }

    public function areErrorsReported():Boolean {
        return true;
    }

    public function isDebug():Boolean {
        return true;
    }
}
}
