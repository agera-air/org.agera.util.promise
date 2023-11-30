package org.agera.util {
    /**
     * @private
     */
    internal class FormatRegexps {
        public static const SEQUENCES: RegExp = /\{\s*([a-z_$][a-z$_0-9\-]*)|("[^"]*")|('[^']*')\s*\}/gi;
    }
}