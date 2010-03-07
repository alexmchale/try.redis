# MGET key1 key2 ... keyN #

**TIME COMPLEXITY**:
O(1) for every key

**DESCRIPTION**:
Get the values of all the specified keys. If one or more keys dont exist or is
not of type String, a 'nil' value is returned instead of the value of the
specified key, but the operation never fails.

**RETURN VALUE**:
Multi bulk reply
