package kabam.rotmg.application {
import flash.display.DisplayObjectContainer;
import flash.display.LoaderInfo;
import flash.system.Capabilities;

import kabam.rotmg.application.api.ApplicationSetup;
import kabam.rotmg.application.impl.LocalhostSetup;
import kabam.rotmg.application.impl.ReleaseSetup;

import org.swiftsuspenders.Injector;

import robotlegs.bender.framework.api.IConfig;

public class ApplicationConfig implements IConfig {


    public function ApplicationConfig() {
        super();
    }
    [Inject]
    public var injector:Injector;
    [Inject]
    public var root:DisplayObjectContainer;
    [Inject]
    public var loaderInfo:LoaderInfo;

    public function configure():void {
        var _local1:ApplicationSetup = null;
        _local1 = new ReleaseSetup();
        this.injector.map(ApplicationSetup).toValue(_local1);
    }
}
}
