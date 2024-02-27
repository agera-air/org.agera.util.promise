package agera.errors {
    /**
     * Represents an assertion error.
     */
    public class AssertionError extends Error {
        /**
         * Constructs <code>AssertionError</code>.
         */
        public function AssertionError(message: String) {
            super(message);
        }
    }
}