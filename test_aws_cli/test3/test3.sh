#!/bin/bash

set -e
set -o pipefail

echo "get current ACL"
aws s3api get-bucket-acl --bucket test-bucket-acl > get-acl-before.json

echo "put new ACL from test3-acl.json"
aws s3api put-bucket-acl --bucket test-bucket-acl --access-control-policy file://test3-acl.json  > put-acl.json

echo "The ACL was accepted ... with response:"

cat  put-acl.json | jq

echo "get updated ACL:"

aws s3api get-bucket-acl --bucket test-bucket-acl > get-acl-after.json

cat get-acl-after.json | jq

echo "Test if we (the owner mentioned in the ACL with FULL_CONTROL) can still access the bucket contents:"

aws s3 ls s3://test-bucket-acl --recursive --human-readable --summarize > s3-ls.txt   2>&1 || true
cat s3-ls.txt

echo "checking if other users are denied access "

aws --profile de s3 ls s3://test-bucket-acl/ > should-fail.txt 2>&1
cat should-fail.txt