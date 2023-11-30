package org.agera.util {
    import org.agera.errors.*;

    /**
     * Asserts that two values are strictly not equal.
     * @throws org.agera.errors.AssertionError Thrown if left and right are strictly equal.
     */
    public function assertNotEquals(left: *, right: *, message: String = ""): void {
        if (left === right) {
            if (message == "") {
                message = "Operands must be strictly not equal: got (left = " + left + ", right = " + right + ")";
            }
            throw new AssertionError(message);
        }
    }
}