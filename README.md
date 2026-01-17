# What happens

## Try literally what is documented

https://registry.terraform.io/providers/scaleway/scaleway/2.63.0/docs/resources/object_bucket_acl

The docs don't say explicitly how to construct the grantee.id 
Only this:

```
id - (Optional) The canonical user ID of the grantee. 
```

But the example seems to imply we have to specify the project id twice??

```yaml
resource "scaleway_object_bucket_acl" "main" {
  bucket = scaleway_object_bucket.main.id
  access_control_policy {
    grant {
      grantee {
          id   = "<project-id>:<project-id>"
          type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    grant {
      grantee {
          id   = "<project-id>"
          type = "CanonicalUser"
      }
      permission = "WRITE"
    }
    owner {
      id = "<project-id>"
    }
  }
} 
```

It does not work.
=> Error: invalid UUID: 2f03da12-1e45-42fa-894d-fd4ce195fb09:2f03da12-1e45-42fa-894d-fd4ce195fb09
   
## Let's try with a project id and a user id:
```
id   = "2f03da12-1e45-42fa-894d-fd4ce195fb09:8208f6a4-08d6-4e59-bd40-770b45ff4192"
```

Same error of course.

## Let's try with a user id only:

```
id   = "8208f6a4-08d6-4e59-bd40-770b45ff4192"
```
               
tofu is able to create a plan and apply it.

### But does the acl work ?

aws s3 ls s3://test-bucket-acl/

⇒ 403: An error occurred (AccessDenied) when calling the ListObjectsV2 operation: Access Denied


``` 
scw object bucket get test-bucket-acl
```

```
ID                test-bucket-acl
Region            fr-par
APIEndpoint       https://s3.fr-par.scw.cloud
BucketEndpoint    https://test-bucket-acl.s3.fr-par.scw.cloud
EnableVersioning  false
Owner             2f03da12-1e45-42fa-894d-fd4ce195fb09

Acl:
GRANTEE                               PERMISSION
8208f6a4-08d6-4e59-bd40-770b45ff4192  FULL_CONTROL 
```

But from now on, we can no longer use tofo/terraform to manager the bucket.

Even though the scw CLI can still change the acl ...

Error: error updating object bucket ACL (fr-par/test-bucket-acl): 
operation error S3: PutBucketAcl, https response error 
StatusCode: 403, 
RequestID: txg7cfa7c40ba4d493c92ff-00696bbc73, 
HostID: txg7cfa7c40ba4d493c92ff-00696bbc73, 
api error AccessDenied: Access Denied

```
scw object bucket update test-bucket-acl acl=private
```

```
✅ Success.
ID                test-bucket-acl
Region            fr-par
APIEndpoint       https://s3.fr-par.scw.cloud
BucketEndpoint    https://test-bucket-acl.s3.fr-par.scw.cloud
EnableVersioning  false
Owner             2f03da12-1e45-42fa-894d-fd4ce195fb09

Acl:
GRANTEE                               PERMISSION
2f03da12-1e45-42fa-894d-fd4ce195fb09  FULL_CONTROL
```

But this is not what we want: now all users can read the bucket.

## now we remove the acl from the terraform config and try again



```
╷
│ Warning: Deleting Object Bucket ACL resource resets ACL to private
│
│ Deleting Object Bucket ACL resource resets the bucket's ACL to its default value: private.
│ If you wish to set it to something else, you should recreate a Bucket ACL resource with the `acl` field filled accordingly.
```
                
Very funny, not.

It was already private: any IAM application/user within the project could read the bucket.

It would be nice if someone could axplan what 'with the `acl` field filled accordingly' actually means.
