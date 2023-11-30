package {
    import flash.display.Sprite;
    import org.agera.util.*;

    public class Main extends Sprite {
        public function Main() {
            this.testChain();
        }

        private function testChain(): void {
            Promise.resolve(10)
                .then(function(value: Number): String {
                    return value.toString() + " foo";
                })
                .then(function(value: String): void {
                    assert(value == "10 foo");
                });
        }
    }
}