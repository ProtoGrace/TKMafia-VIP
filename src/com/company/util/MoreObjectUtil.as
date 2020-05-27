package com.company.util {
public class MoreObjectUtil {


    public static function addToObject(dest:Object, source:Object):void {
        var key:* = null;
        for (key in source) {
            dest[key] = source[key];
        }
    }

    public function MoreObjectUtil() {
        super();
    }
}
}
