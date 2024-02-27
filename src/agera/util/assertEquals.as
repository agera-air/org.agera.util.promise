package agera.util {
    import agera.errors.*;

    /**
     * Asserts that two values are strictly equal.
     * @throws agera.errors.AssertionError Thrown if left and right are not strictly equal.
     */
    public function assertEquals(left: *, right: *, message: String = ""): void {
        if (left !== right) {
            if (message == "") {
                message = "Operands must be strictly equal: got (left = " + left + ", right = " + right + ")";
            }
            throw new AssertionError(message);
        }
    }
}