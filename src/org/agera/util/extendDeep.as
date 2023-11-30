package org.agera.util {
    /**
     * Assigns properties from <code>argument</code> to <code>base</code>.
     * For every property P1 in <code>base</code> whose value is an object,
     * if the <code>argument</code> property P2 being assigned to P1 has
     * an object value, the assignment is replaced by a recursive
     * <code>extendDeep(p1, p2)</code> call.
     */
    public function extendDeep(base: *, argument: *): void {
        for (var key: * in argument) {
            var baseValue: * = base[key];
            var argumentValue: * = argument[key];
            if (typeof baseValue == "object" && typeof argumentValue == "object") {
                extendDeep(baseValue, argumentValue);
            } else {
                base[key] = argumentValue;
            }
        }
    }
}