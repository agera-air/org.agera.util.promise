package agera.util {
    import flash.display.DisplayObject;

    /**
     * Provides static functions for positioning and rotating display objects
     * around a registration point.
     */
    public final class DisplayListOrientation {
        /**
         * Positions and rotates a display object around its center registration
         * point. This function updates the <code>x</code>, <code>y</code> and <code>rotation</code>
         * properties of the display object.
         */
        public static function center(object: DisplayObject, x: Number, y: Number, rotation: Number): void {
            var w: Number = object.width;
            var h: Number = object.height;
            x -= w / 2;
            y -= h / 2;
            object.rotation = rotation;

            // Based on https://community.openfl.org/t/rotation-around-center/8751/9
            {
                const hypotenuse: Number = Math.sqrt(w / 2 * w / 2 + h / 2 * h / 2);
                const newX: Number = hypotenuse * Math.cos(degreesToRadians(rotation + 45.0));
                const newY: Number = hypotenuse * Math.sin(degreesToRadians(rotation + 45.0));
                x -= newX;
                y -= newY;
            }

            object.x = x;
            object.y = y;
        }
    }
}