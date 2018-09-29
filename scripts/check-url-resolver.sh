#!/bin/bash
#
# This script returns current stats from URL resolver.
#
curl 'http://localhost:4000/' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: http://localhost:4000' --data-binary '{"query":"{\n  browserStats {\n    pageCount\n    pages {\n      title\n      url\n      metrics {\n        JSHeapUsedSize\n        Nodes\n        Timestamp\n      }\n    }\n  }\n}\n"}' --compressed
