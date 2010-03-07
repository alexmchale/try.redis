# SDIFFSTORE *dstkey key1 key2 ... keyN*

**TIME COMPLEXITY**:
O(N) where N is the total number of elements in all the provided sets

**DESCRIPTION**:
This command works exactly like SDIFF but instead of being returned the
resulting set is stored in dstkey.

**RETURN VALUE**:
Status code reply
