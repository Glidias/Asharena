package util.ds;

/**
 * ...
 * @author Glenn Ko
 */
/**
 *  HaXe version of AlphabeticID
 *  Author: Andy Li &lt;andy@onthewings.net>
 *  ported from...
 *
 *  Javascript AlphabeticID class
 *  Author: Even Simon &lt;even.simon@gmail.com>
 *  which is based on a script by Kevin van Zonneveld &lt;kevin@vanzonneveld.net>)
 *
 *  Description: Translates a numeric identifier into a short string and backwords.
 *  http://kevin.vanzonneveld.net/techblog/article/create_short_ids_with_php_like_youtube_or_tinyurl/
 **/

class AlphaID {
    static public var index:String = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    static public function encode(_number:Int):String {
        var strBuf = new StringBuf();

        var i = 0;
        var end = Math.floor(Math.log(_number)/Math.log(index.length));
        while(i <= end) {
            strBuf.add(index.charAt((Math.floor(_number / bcpow(index.length, i++)) % index.length)));
        }

        return strBuf.toString();
    }

    static public function decode(_string:String):Int {
        var str = reverseString(_string);
        var ret = 0;

        var i = 0;
        var end = str.length - 1;
        while(i <= end) {
            ret += Std.int(index.indexOf(str.charAt(i)) * (bcpow(index.length, end-i)));
            ++i;
        }

        return ret;
    }

    inline static private function bcpow(_a:Float, _b:Float):Float {
        return Math.floor(Math.pow(_a, _b));
    }

    inline static private function reverseString(inStr:String):String {
        var ary = inStr.split("");
        ary.reverse();
        return ary.join("");
    }
}
