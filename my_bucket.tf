data "scaleway_iam_group" "iam_admins_group" {
  name = "iam_admins_group"
}

# NOTE
# 2f03da12-1e45-42fa-894d-fd4ce195fb09 = the project ID (and the org ID)
# 8208f6a4-08d6-4e59-bd40-770b45ff4192 = the ID of the OWNER of the Scaleway account


resource "scaleway_object_bucket" "test-bucket-acl" {
  name = "test-bucket-acl"
}

## First try: project id twice as in the terraform example: does not work
## format should be 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' (36) and contains valid hexadecimal characters

# resource "scaleway_object_bucket_acl" "my-test-bucket" {
#   bucket = scaleway_object_bucket.test-bucket-acl.id
#   access_control_policy {
#     grant {
#       grantee {
#         id   = "2f03da12-1e45-42fa-894d-fd4ce195fb09:2f03da12-1e45-42fa-894d-fd4ce195fb09"
#         type = "CanonicalUser"
#       }
#       permission = "FULL_CONTROL"
#     }
#     owner {
#       id = data.scaleway_account_project.default.id
#     }
#   }
# }

## Second try: project id and a user id:

# It does not work.
# format should be 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' (36) and contains valid hexadecimal characters

# resource "scaleway_object_bucket_acl" "my-test-bucket" {
#   bucket = scaleway_object_bucket.test-bucket-acl.id
#   access_control_policy {
#     grant {
#       grantee {
#         id   = "2f03da12-1e45-42fa-894d-fd4ce195fb09:8208f6a4-08d6-4e59-bd40-770b45ff4192"
#         type = "CanonicalUser"
#       }
#       permission = "FULL_CONTROL"
#     }
#     owner {
#       id = data.scaleway_account_project.default.id
#     }
#   }
# }

# Third try: only user ID
# tofu is able to apply the plan.

# But can the specified user now access the bucket?
# No :-(
# aws s3 ls s3://test-bucket-acl
# => An error occurred (AccessDenied) when calling the ListObjectsV2 operation: Access Denied

# Run tofu plan again, it complains:
#  Warning: Cannot read bucket objects: Forbidden
#│
#│   with scaleway_object_bucket.test-bucket-acl,
#│   on my_bucket.tf line 10, in resource "scaleway_object_bucket" "test-bucket-acl":
#│   10: resource "scaleway_object_bucket" "test-bucket-acl" {
#│
#│ Got 403 error while reading bucket objects, please check your IAM permissions and your bucket policy

resource "scaleway_object_bucket_acl" "my-test-bucket" {
  bucket = scaleway_object_bucket.test-bucket-acl.id
  access_control_policy {
    grant {
      grantee {
        id   = "8208f6a4-08d6-4e59-bd40-770b45ff4192"
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    grant {
      grantee {
        id   = "8208f6a4-08d6-4e59-bd40-770b45ff4192"
        type = "CanonicalUser"
      }
      permission = "READ_ACP"
    }
    grant {
      grantee {
        id   = "8208f6a4-08d6-4e59-bd40-770b45ff4192"
        type = "CanonicalUser"
      }
      permission = "WRITE_ACP"
    }
    grant {
      grantee {
        id   = "8208f6a4-08d6-4e59-bd40-770b45ff4192"
        type = "CanonicalUser"
      }
      permission = "READ"
    }
    grant {
      grantee {
        id   = "8208f6a4-08d6-4e59-bd40-770b45ff4192"
        type = "CanonicalUser"
      }
      permission = "WRITE"
    }
    owner {
      # id = data.scaleway_account_project.default.id
      id = "2f03da12-1e45-42fa-894d-fd4ce195fb09"
    }
  }
}

# This what the CLI says after doing scw object  bucket update test-bucket-acl acl=private

# Acl:
# GRANTEE                               PERMISSION
# 2f03da12-1e45-42fa-894d-fd4ce195fb09  FULL_CONTROL
