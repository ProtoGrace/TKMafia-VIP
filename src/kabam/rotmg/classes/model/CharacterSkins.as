package kabam.rotmg.classes.model {
public class CharacterSkins {


    private const skins:Vector.<CharacterSkin> = new Vector.<CharacterSkin>(0);

    private const map:Object = {};

    public function CharacterSkins() {
        super();
    }
    private var defaultSkin:CharacterSkin;
    private var selectedSkin:CharacterSkin;
    private var maxLevelAchieved:int;

    public function getCount():int {
        return this.skins.length;
    }

    public function getDefaultSkin():CharacterSkin {
        return this.defaultSkin;
    }

    public function getSelectedSkin():CharacterSkin {
        return this.selectedSkin;
    }

    public function getSkinAt(index:int):CharacterSkin {
        return this.skins[index];
    }

    public function addSkin(skin:CharacterSkin, isDefault:Boolean = false):void {
        skin.changed.add(this.onSkinChanged);
        this.skins.push(skin);
        this.map[skin.id] = skin;
        this.updateSkinState(skin);
        if (isDefault) {
            this.defaultSkin = skin;
            if (!this.selectedSkin) {
                this.selectedSkin = skin;
                skin.setIsSelected(true);
            }
        } else if (skin.getIsSelected()) {
            this.selectedSkin = skin;
        }
    }

    public function updateSkins(maxLevelAchieved:int):void {
        var skin:CharacterSkin = null;
        this.maxLevelAchieved = maxLevelAchieved;
        for each(skin in this.skins) {
            this.updateSkinState(skin);
        }
    }

    public function getSkin(id:int):CharacterSkin {
        return this.map[id] || this.defaultSkin;
    }

    private function onSkinChanged(skin:CharacterSkin):void {
        if (skin.getIsSelected() && this.selectedSkin != skin) {
            this.selectedSkin && this.selectedSkin.setIsSelected(false);
            this.selectedSkin = skin;
        }
    }

    private function updateSkinState(skin:CharacterSkin):void {
        if (skin.getState() != CharacterSkinState.OWNED) {
            skin.setState(this.getSkinState(skin));
        }
    }

    private function getSkinState(skin:CharacterSkin):CharacterSkinState {
        if (this.maxLevelAchieved >= skin.unlockLevel) {
            return CharacterSkinState.PURCHASABLE;
        }
        return CharacterSkinState.LOCKED;
    }
}
}
