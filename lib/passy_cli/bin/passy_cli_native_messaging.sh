#!/bin/bash
cd $(dirname $0)
eval "\"$(./passy_cli install temp)\" native_messaging start" < "/dev/stdin"
