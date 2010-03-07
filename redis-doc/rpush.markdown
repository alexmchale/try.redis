# RPUSH *key* *string*

**TIME COMPLEXITY**:
O(1)

**DESCRIPTION**:
Add the *string* value to the head (RPUSH) or tail (LPUSH) of the list stored
at *key*. If the key does not exist an empty list is created just before the
append operation. If the key exists but is not a List an error is returned.

**RETURN VALUE**:
Status code reply
