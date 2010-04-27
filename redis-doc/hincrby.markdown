# HINCRBY key field value #

**TIME COMPLEXITY**:
O(1)

**DESCRIPTION**:
Increment the number stored at field in the hash at key by value. If key does
not exist, a new key holding a hash is created. If field does not exist or
holds a string, the value is set to 0 before applying the operation.

The range of values supported by HINCRBY is limited to 64 bit signed integers.

**RETURN VALUE**:
Integer reply - The new value at field after the increment operation.
