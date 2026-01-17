#!/bin/bash

set -e
set -o pipefail

aws s3api get-bucket-acl --bucket test-bucket-acl > get-acl-before.json

aws s3api put-bucket-acl --bucket test-bucket-acl --access-control-policy file://new-acl.json  > put-acl.json

cat  put-acl.json | jq

aws s3api get-bucket-acl --bucket test-bucket-acl > get-acl-after.json


cat get-acl-after.json | jq

aws s3 ls s3://test-bucket-acl --recursive --human-readable --summarize > s3-ls.txt
cat s3-ls.txt

echo "checking if other users are denied access "

aws --profile de s3 ls s3://test-bucket-acl/ > should-fail.txt 2>&1
cat should-fail.txt

# but it seems the other user can still access the bucket?