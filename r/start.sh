#!/bin/bash

Rscript /r/start.R &

java $JVMARGS -Xrs -classpath "$GWDIR/*" com.intersystems.gateway.JavaGateway $PORT "" "R Remote" "0.0.0.0" 2>&1