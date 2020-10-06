#!/bin/bash -eu


self="${BASH_SOURCE[0]}"
selfdir="$(cd "$(dirname "${self}")"; pwd)"
selfpath="$selfdir/$(basename "$self")"


cd $selfdir


echo "Clean \"classes\" directory"
rm -rf classes
mkdir classes
echo "AOT compilation"
clojure -M:aot -e "(compile 'simple.main)"
clojure -M:uberjar --main-class "simple.main" --target target/uber.jar --aliases "uberjar/paths"
native-image \
    --report-unsupported-elements-at-runtime \
    --no-fallback \
    -H:+ReportExceptionStackTraces \
    --initialize-at-build-time \
    --initialize-at-run-time=io.netty.channel.epoll.EpollEventArray,io.netty.channel.unix.Errors,io.netty.channel.unix.IovArray,io.netty.channel.unix.Socket,io.netty.channel.epoll.Native,io.netty.channel.epoll.EpollEventLoop,io.netty.util.internal.logging.Log4JLogger \
    --allow-incomplete-classpath \
    -jar "target/uber.jar" \
    -H:Name="aleph.app"
