package agera.util {
    /**
     * Unicode Code Point utility functions.
     */
    public final class UnicodeCodePoints {
        /**
         * Converts a code point into a string.
         * 
         * @throws RangeError If the given integer is not a valid code point.
         */
        public static function string(codePoint: uint): String {
            if (codePoint > 0x10FFFF) {
                throw new RangeError(format("Code point must be less than or equals 0x10FFFF; got {1}.", [codePoint.toString(16)]));
            }
            if (codePoint <= 0xFFFF) {
                return String.fromCharCode(codePoint);
            }
            codePoint -= 0x10000;
            const highSurrogate: uint = (codePoint >> 10) + 0xd800;
            const lowSurrogate: uint = (codePoint % 0x400) + 0xdc00;
            return String.fromCharCode(highSurrogate) + String.fromCharCode(lowSurrogate);
        }

        /**
         * Reads a code point from a string into the specified Code Units index.
         */
        public static function at(string: String, index: uint): uint {
            var unit1: uint = string.charCodeAt(index);
            if (unit1 >= 0xD800 && unit1 <= 0xDBFF && (index + 1) < string.length) {
                var unit2: uint = string.charCodeAt(index + 1);
                if (unit2 >= 0xDC00 && unit2 <= 0xDFFF) {
                    return (unit1 - 0xd800) * 0x400 + unit2 - 0xdc00 + 0x10000;
                }
            }
            return unit1;
        }
    }
}