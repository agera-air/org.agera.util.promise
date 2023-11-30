package org.agera.util {
    import org.agera.errors.*;

    /**
     * Asserts that a value is true.
     * @throws org.agera.errors.AssertionError Thrown if the given test value is not true.
     */
    public function assert(test: Boolean, message: String = "Assertion must be true."): void {
        if (!test) {
            throw new AssertionError(message);
        }
    }
}