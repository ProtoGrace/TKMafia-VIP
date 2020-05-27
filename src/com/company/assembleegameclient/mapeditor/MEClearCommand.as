package com.company.assembleegameclient.mapeditor {
import com.company.assembleegameclient.editor.Command;

public class MEClearCommand extends Command {


    public function MEClearCommand(map:MEMap, x:int, y:int, oldTile:METile) {
        super();
        this.map_ = map;
        this.x_ = x;
        this.y_ = y;
        this.oldTile_ = oldTile.clone();
    }
    private var map_:MEMap;
    private var x_:int;
    private var y_:int;
    private var oldTile_:METile;

    override public function execute():void {
        this.map_.eraseTile(this.x_, this.y_);
    }

    override public function unexecute():void {
        this.map_.setTile(this.x_, this.y_, this.oldTile_);
    }
}
}
