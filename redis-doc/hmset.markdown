# HMSET key field1 value1 ... fieldN valueN #

**TIME COMPLEXITY**:
O(N) (with N being the number of fields)

**DESCRIPTION**:
Set the respective fields to the respective values. HMSET replaces old values
with new values.

If key does not exist, a new key holding a hash is created.

**RETURN VALUE**:
Status code reply Always +OK because HMSET can't fail
