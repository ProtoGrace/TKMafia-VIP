package com.company.assembleegameclient.util {
public class RandomUtil {


    public static function plusMinus(range:Number):Number {
        return Math.random() * range * 2 - range;
    }

    public function RandomUtil() {
        super();
    }
}
}
