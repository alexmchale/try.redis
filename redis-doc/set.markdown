# SET key value #

**TIME COMPLEXITY**:
O(1)

**DESCRIPTION**:
Set key to hold the string value. If key already holds a value, it is
overwritten, regardless of its type. Any previous time to live associated with
the key is discarded on successful SET operation.

**RETURN VALUE**:
Status code reply: OK if SET was executed correctly.
