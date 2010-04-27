# HSET key field value #

**TIME COMPLEXITY**:
O(1)

**DESCRIPTION**:
Set the specified hash field to the specified value.

If key does not exist, a new key holding a hash is created.

If the field already exists, and the HSET just produced an update of the value,
0 is returned, otherwise if a new field is created 1 is returned.

**RETURN VALUE**:
Integer reply
