package org.agera.util {
    import flash.display.*;
    import org.agera.util.*;

    /**
     * Indicates whether a display object is descendant of a possible ascending display object or not.
     */
    public function displayIsDescendantOf(object: DisplayObject, ascending: DisplayObject): Boolean {
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