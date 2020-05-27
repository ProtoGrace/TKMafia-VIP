package kabam.rotmg.assets {
import kabam.rotmg.assets.services.CharacterFactory;
import kabam.rotmg.assets.services.IconFactory;
import kabam.rotmg.startup.control.StartupSequence;

import org.swiftsuspenders.Injector;

import robotlegs.bender.framework.api.IConfig;

public class AssetsConfig implements IConfig {


    public function AssetsConfig() {
        super();
    }
    [Inject]
    public var injector:Injector;
    [Inject]
    public var startup:StartupSequence;

    public function configure():void {
        this.injector.map(CharacterFactory).asSingleton();
        this.injector.map(IconFactory).asSingleton();
    }
}
}
