#!/bin/bash

set -e
set -o pipefail

aws s3api get-bucket-acl --bucket test-bucket-acl > get-acl.json

cat  get-acl.json | jq

aws s3 ls s3://test-bucket-acl --recursive --human-readable --summarize > s3-ls.txt   2>&1   || true
cat s3-ls.txt

