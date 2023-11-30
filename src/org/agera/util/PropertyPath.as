package org.agera.util {
    /**
     * Resolves a property path.
     * A path consists of components delimited by forward slashes (<code>/</code>).
     */
    public final class PropertyPath {
        /**
         * @private
         */
        public function PropertyPath(path: String) {
            throw new Error("PropertyPath is a static class.");
        }

        /**
         * Gets the value of a property on an object by its path.
         */
        public static function get(object: *, path: String): * {
            for each (var component: String in path.split("/")) {
                object = object[component];
                if (object === undefined) {
                    return undefined;
                }
            }
            return object;
        }

        /**
         * Sets the value of a property on an object by its path.
         */
        public static function set(object: *, path: String, value: *): void {
            assert(!!object, "PropertyPath.set() received undefined base object.");
            var split: Array = path.split("/");
            var propertyName: String = split.pop();
            assert(propertyName != null, "Property name must be specified.");
            for each (var component: String in split) {
                object = object[component];
                assert(!!object, "Found undefined object when invoking PropertyPath.set().");
            }
            object[propertyName] = value;
        }
    }
}