package com.company.assembleegameclient.screens {
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.events.Event;

import mx.core.MovieClipAsset;

import org.osflash.signals.Signal;

public class UnpackEmbed {


    public function UnpackEmbed(assetClass:Class) {
        super();
        this._asset = new assetClass();
        this._ready = new Signal(UnpackEmbed);
        var loader:Loader = Loader(this._asset.getChildAt(0));
        var info:LoaderInfo = loader.contentLoaderInfo;
        info.addEventListener(Event.COMPLETE, this.onLoadComplete);
    }

    private var _ready:Signal;

    public function get ready():Signal {
        return this._ready;
    }

    private var _asset:MovieClipAsset;

    public function get asset():MovieClipAsset {
        return this._asset;
    }

    private var _content:MovieClip;

    public function get content():MovieClip {
        return this._content;
    }

    private function onLoadComplete(event:Event):void {
        var info:LoaderInfo = LoaderInfo(event.target);
        info.removeEventListener(Event.COMPLETE, this.onLoadComplete);
        this._content = MovieClip(info.loader.content);
        this._ready.dispatch(this);
    }
}
}
