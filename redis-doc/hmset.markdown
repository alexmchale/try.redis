# HMSET key field value [field value ...]

**TIME COMPLEXITY**
O(N) where N is the number of fields being set.

**DESCRIPTION**
Sets the specified fields to their respective values in the hash stored at
`key`. This command overwrites any existing fields in the hash.  If `key` does
not exist, a new key holding a hash is created.

**RETURN VALUE**
Status code reply
