package kabam.rotmg.fame.model {
public class SimpleFameVO implements FameVO {


    public function SimpleFameVO(accountId:int, characterId:int) {
        super();
        this.accountId = accountId;
        this.characterId = characterId;
    }
    private var accountId:int;
    private var characterId:int;

    public function getAccountId():int {
        return this.accountId;
    }

    public function getCharacterId():int {
        return this.characterId;
    }
}
}
