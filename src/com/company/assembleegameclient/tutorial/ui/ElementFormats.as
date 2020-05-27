package com.company.assembleegameclient.ui {
import flash.text.engine.CFFHinting;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;
import flash.text.engine.RenderingMode;

public class ElementFormats {

    private static var FONT_DESCRIPTION:String = "MyriadProBoldCFF,_sans";

    private static function newDefaultFormat():ElementFormat {
        var elementFormat:ElementFormat = new ElementFormat();
        elementFormat.fontDescription = new FontDescription(FONT_DESCRIPTION, FontWeight.BOLD, FontPosture.NORMAL, FontLookup.EMBEDDED_CFF, RenderingMode.CFF, CFFHinting.HORIZONTAL_STEM);
        elementFormat.fontSize = 14;
        return elementFormat;
    }

    public function ElementFormats(color:int = 16777215) {
        super();
        this.normalFormat_ = newDefaultFormat();
        this.normalFormat_.color = 16777215;
        this.serverFormat_ = newDefaultFormat();
        this.serverFormat_.color = 16776960;
        this.clientFormat_ = newDefaultFormat();
        this.clientFormat_.color = 255;
        this.helpFormat_ = newDefaultFormat();
        this.helpFormat_.color = 16734981;
        this.errorFormat_ = newDefaultFormat();
        this.errorFormat_.color = 16711680;
        this.adminFormat_ = newDefaultFormat();
        this.adminFormat_.color = 16776960;
        this.enemyFormat_ = newDefaultFormat();
        this.enemyFormat_.color = 16754688;
        this.playerFormat_ = newDefaultFormat();
        this.playerFormat_.color = 65280;
        this.sepFormat_ = newDefaultFormat();
        this.sepFormat_.color = 3552822;
        this.tellFormat_ = newDefaultFormat();
        this.tellFormat_.color = 61695;
        this.guildFormat_ = newDefaultFormat();
        this.guildFormat_.color = 10944349;
        this.partyFormat_ = newDefaultFormat();
        this.partyFormat_.color = 16761035;
        this.exportFormat_ = newDefaultFormat();
        this.exportFormat_.color = color;
    }
    public var normalFormat_:ElementFormat = null;
    public var serverFormat_:ElementFormat = null;
    public var clientFormat_:ElementFormat = null;
    public var helpFormat_:ElementFormat = null;
    public var errorFormat_:ElementFormat = null;
    public var adminFormat_:ElementFormat = null;
    public var enemyFormat_:ElementFormat = null;
    public var playerFormat_:ElementFormat = null;
    public var sepFormat_:ElementFormat = null;
    public var tellFormat_:ElementFormat = null;
    public var guildFormat_:ElementFormat = null;
    public var exportFormat_:ElementFormat = null;
    public var partyFormat_:ElementFormat = null;
}
}
