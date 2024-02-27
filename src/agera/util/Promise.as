package agera.util {
    import flash.utils.setTimeout;
    import agera.errors.*;

    /**
     * The Promise object represents the eventual completion (or failure)
     * of an asynchronous operation and its resulting value.
     * 
     * <p>The Promise class is based on the ECMA-262 Promise object.
     * Consult www.developer.mozilla.org for more information on Promise.</p>
     *
     * <p><b>Examples</b></p>
     * 
     * <listing version="3.0">
     * const promise: Promise = new Promise(function(resolve: Function, reject: Function): void {
     *     //
     * });
     * 
     * promise
     *     .then(function(value: *): * {
     *         // then
     *     })
     *     .otherwise(function(error: *): * {
     *         // catch
     *     })
     *     .always(function():void {
     *         // finally
     *     });
     * </listing>
     */
    public final class Promise {
        // Implementation based on
        // https://github.com/taylorhakes/promise-polyfill

        private var mState: Number = 0;
        private var mHandled: Boolean = false;
        private var mValue: * = undefined;
        private var mDeferreds: Vector.<PromiseHandler> = new Vector.<PromiseHandler>;

        private static function bindFunction(fn: Function, thisArg: *): Function {
            return function(...argumentsList): void {
                fn.apply(thisArg, argumentsList);
            };
        }

        public function Promise(fn: Function) {
            doResolve(fn, this);
        }

        private static function handle(self:Promise, deferred:PromiseHandler):void {
            while (self.mState === 3) {
                self = self.mValue;
            }
            if (self.mState === 0) {
                self.mDeferreds.push(deferred);
                return;
            }
            self.mHandled = true;
            Promise._immediateFn(function():void {
                var cb:Function = self.mState === 1 ? deferred.onFulfilled : deferred.onRejected;
                if (cb === null) {
                    (self.mState === 1 ? Promise.privateResolve : Promise.privateReject)(deferred.promise, self.mValue);
                    return;
                }
                var ret: * = undefined;
                try {
                    ret = cb(self.mValue);
                } catch (e: *) {
                    Promise.privateReject(deferred.promise, e);
                    return;
                }
                Promise.privateResolve(deferred.promise, ret);
            });
        }

        private static function privateResolve(self:Promise, newValue: *):void {
            try {
                // Promise Resolution Procedure: https://github.com/promises-aplus/promises-spec#the-promise-resolution-procedure
                if (newValue === self) {
                    throw new TypeError('A promise cannot be resolved with itself.');
                }
                if (newValue is Promise) {
                    self.mState = 3;
                    self.mValue = newValue;
                    Promise.finale(self);
                    return;
                }
                self.mState = 1;
                self.mValue = newValue;
                Promise.finale(self);
            } catch (e: *) {
                Promise.privateReject(self, e);
            }
        }

        private static function privateReject(self:Promise, newValue: *):void {
            self.mState = 2;
            self.mValue = newValue;
            Promise.finale(self);
        }

        private static function finale(self:Promise):void {
            if (self.mState === 2 && self.mDeferreds.length === 0) {
                Promise._immediateFn(function():void {
                    if (!self.mHandled) {
                        Promise._unhandledRejectionFn(self.mValue);
                    }
                });
            }

            for (var i: Number = 0, len: Number = self.mDeferreds.length; i < len; i++) {
                handle(self, self.mDeferreds[i]);
            }
            self.mDeferreds = null;
        }

        /**
         * Takes a potentially misbehaving resolver function and make sure
         * `onFulfilled` and `onRejected` are only called once.
         *
         * Makes no guarantees about asynchrony.
         */
        private static function doResolve(fn:Function, self:Promise):void {
            var done:Boolean = false;
            try {
                fn(
                    function(value: *): * {
                        if (done) {
                            return;
                        }
                        done = true;
                        Promise.privateResolve(self, value);
                    },
                    function(reason: *): * {
                        if (done) {
                            return;
                        }
                        done = true;
                        Promise.privateReject(self, reason);
                    }
                );
            } catch (exception: *) {
                if (done) {
                    return;
                }
                done = true;
                Promise.privateReject(self, exception);
            }
        }

        /**
         * The <code>Promise.allSettled()</code> static method takes an iterable of promises
         * as input and returns a single Promise.
         * This returned promise fulfills when all of the input's promises settle
         * (including when an empty iterable is passed), with an array of objects that
         * describe the outcome of each promise.
         * <p><b>Example:</b></p>
         * <listing version="3.0">
         * const promise1: Promise = Promise.resolve(3);
         * const promise2: Promise = new Promise(function(resolve: Function, reject: Function): void {
         *     setTimeout(reject, 100, 'foo');
         * });
         * Promise.allSettled([promise1, promise2])
         *     .then(function(results: Array): void {
         *         for each (var result: * in results) {
         *             trace(result.status);
         *         }
         *     });
         * // expected output:
         * // 'fulfilled'
         * // 'rejected'
         * </listing>
         * 
         * @return A <code>Promise</code> that is:
         * <ul>
         * <li><b>Already fulfilled,</b> if the iterable passed is empty.</li>
         * <li><b>Asynchronously fulfilled,</b> when all promises in the given
         * iterable have settled (either fulfilled or rejected).
         * The fulfillment value is an array of objects, each describing the
         * outcome of one promise in the iterable, in the order of the promises passed,
         * regardless of completion order. Each outcome object has the following properties:
         *   <ul>
         *     <li><code>status</code>: A string, either <code>"fulfilled"</code> or <code>"rejected"</code>, indicating the eventual state of the promise.</li>
         *     <li><code>value</code>: Only present if <code>status</code> is <code>"fulfilled"</code>. The value that the promise was fulfilled with.</li>
         *     <li><code>reason</code>: Only present if <code>status</code> is <code>"rejected"</code>. The reason that the promise was rejected with.</li>
         *   </ul>
         * </li>
         * <p>If the iterable passed is non-empty but contains no pending promises,
         *    the returned promise is still asynchronously (instead of synchronously) fulfilled.</p>
         * </ul>
         */
        public static function allSettled(promises:Array):Promise {
            return new Promise(function(resolve:Function, reject:Function):void {
                var args:Array = promises.slice(0);
                if (args.length === 0) {
                    resolve([]);
                    return;
                }
                var remaining: Number = args.length;
                function res(i: Number, val: *):void {
                    if (val is Promise) {
                        Promise(val).then(
                            function(val: *): * {
                                res(i, val);
                            },
                            function(e: *): * {
                                args[i] = { status: 'rejected', reason: e };
                                if (--remaining === 0) {
                                    resolve(args);
                                }
                            }
                        );
                        return;
                    }
                    args[i] = { status: 'fulfilled', value: val };
                    if (--remaining === 0) {
                        resolve(args);
                    }
                }
                for (var i: Number = 0; i < args.length; ++i) {
                    res(i, args[i]);
                }
            });
        } // allSettled

        public static function any(promises:Array):Promise {
            return new Promise(function(resolve:Function, reject:Function):void {
                var args:Array = promises.slice(0);
                if (args.length === 0) {
                    reject(undefined);
                    return;
                }
                var rejectionReasons:Array = [];
                for (var i: Number = 0; i < args.length; ++i) {
                    try {
                        Promise.resolve(args[i])
                            .then(resolve)
                            .$catch(function(error: *): * {
                                rejectionReasons.push(error);
                                if (rejectionReasons.length === args.length) {
                                    reject(
                                        new AggregateError(
                                            rejectionReasons,
                                            'All promises were rejected'
                                        )
                                    );
                                }
                            });
                    } catch (exception: *) {
                        reject(exception);
                    }
                }
            });
        } // any

        public function always(callback:Function):Promise {
            return $finally(callback);
        }

        public function $finally(callback:Function):Promise {
            return this.then(
                function(value: *): * {
                    return Promise.resolve(callback()).then(function(_: *): * {
                        return value;
                    });
                },
                function(reason: *): * {
                    return Promise.resolve(callback()).then(function(_: *): * {
                        return Promise.reject(reason);
                    });
                }
            );
        } // $finally

        public function otherwise(onRejected:Function):Promise {
            return this.$catch(onRejected);
        }

        public function $catch(onRejected:Function):Promise {
            return this.then(null, onRejected);
        }

        public function then(onFulfilled:Function, onRejected:Function = null):Promise {
            var prom:Promise = new Promise(function(_a: *, _b: *):void {});
            Promise.handle(this, new PromiseHandler(onFulfilled, onRejected, prom));
            return prom;
        }

        public static function all(promises:Array):Promise {
            return new Promise(function(resolve:Function, reject:Function):void {
                var args:Array = promises.slice(0);
                if (args.length === 0) {
                    resolve([]);
                    return;
                }
                var remaining: Number = args.length;

                function res(i: Number, val: *):void {
                    try {
                        if (val is Promise) {
                            Promise(val).then(
                                function(val: *): * {
                                    res(i, val);
                                },
                                reject
                            );
                            return;
                        }
                        args[i] = val;
                        if (--remaining === 0) {
                            resolve(args);
                        }
                    } catch (exception: *) {
                        reject(exception);
                    }
                }

                for (var i: Number = 0; i < args.length; i++) {
                    res(i, args[i]);
                }
            });
        } // all

        public static function resolve(value: *):Promise {
            if (value is Promise) {
                return Promise(value);
            }

            return new Promise(function(resolve:Function, reject:Function):void {
                resolve(value);
            });
        }

        public static function reject(value: *):Promise {
            return new Promise(function(resolve:Function, reject:Function):void {
                reject(value);
            });
        }

        public static function race(promises:Array):Promise {
            return new Promise(function(resolve:Function, reject:Function):void {
                for each (var arg: * in promises) {
                    Promise.resolve(arg).then(resolve, reject);
                }
            });
        }

        private static function _immediateFn(fn:Function):void {
            setTimeout(fn, 0);
        }

        private static function _unhandledRejectionFn(err: *):void {
            trace('Possible Unhandled Promise Rejection:', err);
        }
    }
}