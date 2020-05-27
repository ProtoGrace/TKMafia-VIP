package kabam.rotmg.application.impl {
import com.company.assembleegameclient.parameters.Parameters;

import kabam.rotmg.application.api.ApplicationSetup;

public class ReleaseSetup implements ApplicationSetup {


    private const CDN_APPENGINE:String = "http://us.tkgames.gg:2000";

    private const CDN_STATICS:String = "https://tkgames.gg/assets/tk1/static";

    private const BUILD_LABEL:String = "TK1 - build: {VERSION}";

    public function ReleaseSetup() {
        super();
    }

    public function getAppEngineUrl(toStatics:Boolean = false):String {
        return !!toStatics ? this.CDN_STATICS : this.CDN_APPENGINE;
    }

    public function getBuildLabel():String {
        return this.BUILD_LABEL.replace("{VERSION}", Parameters.data.customVersion);
    }

    public function useProductionDialogs():Boolean {
        return true;
    }

    public function areErrorsReported():Boolean {
        return false;
    }

    public function isDebug():Boolean {
        return false;
    }
}
}
