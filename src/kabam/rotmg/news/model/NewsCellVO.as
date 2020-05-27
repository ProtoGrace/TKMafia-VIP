package kabam.rotmg.news.model {
public class NewsCellVO {


    public function NewsCellVO() {
        super();
    }
    public var imageURL:String;
    public var linkDetail:String;
    public var headline:String;
    public var linkType:NewsCellLinkType;
    public var priority:uint;
    public var slot:uint;
}
}
