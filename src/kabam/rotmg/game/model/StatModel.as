package kabam.rotmg.game.model {
public class StatModel {


    public function StatModel(name:String, abbreviation:String, description:String, redOnZero:Boolean) {
        super();
        this.name = name;
        this.abbreviation = abbreviation;
        this.description = description;
        this.redOnZero = redOnZero;
    }
    public var name:String;
    public var abbreviation:String;
    public var description:String;
    public var redOnZero:Boolean;
}
}
