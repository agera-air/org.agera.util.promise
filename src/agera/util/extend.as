package agera.util {
    /**
     * Assigns properties from <code>argument</code> to <code>base</code>.
     */
    public function extend(base: *, argument: *): void {
        for (var key: * in argument) {
            base[key] = argument[key];
        }
    }
}