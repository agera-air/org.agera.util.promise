package org.agera.util {
    /**
     * Replaces parameters in a string. <code>argumentsObject</code>
     * can be either a plain object or an array.
     * 
     * <p>
     * <ul>
     *   <li>If <code>argumentsObject</code> is a plain object,
     *       it maps parameter names to values.</li>
     *   <li>If <code>argumentsObject</code> is an array, it is converted to
     *       a plain object incrementing indices by 1 and using them
     *       as stringified keys to values.</li>
     * </ul>
     * </p>
     * 
     * <p><b>String sequences</b></p>
     * 
     * <p>The following are three special sequences in a string by
     * taking braces. Whitespace is allowed between the braces.</p>
     *
     * <p>
     * <ul>
     *   <li><code>{parameterName}</code></li>
     *   <li><code>{"escaped"}</code></li>
     *   <li><code>{'escaped'}</code></li>
     * </ul>
     * </p>
     * 
     * <p>The quotes form is used for incorporating escaped sequences.</p>
     * 
     * <p>Futurely a <code>:suffix</code> part may be supported
     *    to allow numeric fine-tuning options.</p>
     * 
     * <p><b>Examples</b></p>
     * 
     * <listing version="3.0">
     * format("Formatted: {x}", { x: 10 }) // Formatted: 10
     * format("Formatted: {1}", [10])      // Formatted: 10
     * </listing>
     */
    public function format(string: String, argumentsObject: *): String {
        argumentsObject = argumentsObject === undefined || argumentsObject === null ? {} : argumentsObject;
        if (argumentsObject is Array) {
            var array: Array = argumentsObject as Array;
            argumentsObject = {};
            for (var i: uint = 0; i < array.length; i += 1) {
                argumentsObject[(i + 1).toString()] = array[i];
            }
        }
        return string.replace(FormatRegexps.SEQUENCES, function(_: String, m: String, ..._m2): String {
            var ch: uint = m.charCodeAt(0);
            if (ch == 0x22 || ch == 0x27) {
                return m.slice(1, m.length - 1);
            } else {
                return String(argumentsObject[m]);
            }
        });
    }
}