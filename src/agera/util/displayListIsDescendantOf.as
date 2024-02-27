package agera.util {
    import flash.display.*;
    import agera.util.*;

    /**
     * Indicates whether a display object is descendant of a possible ascending display object or not.
     */
    public function displayListIsDescendantOf(object: DisplayObject, ascending: DisplayObject): Boolean {
        var parent: DisplayObject = object.parent;
        while (parent != null) {
            if (parent == ascending) {
                return true;
            }
            parent = parent.parent;
        }
        return false;
    }
}