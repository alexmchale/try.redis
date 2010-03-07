# SUNIONSTORE *dstkey key1 key2 ... keyN*

**TIME COMPLEXITY**:
O(N) where N is the total number of elements in all the provided sets

**DESCRIPTION**:
This command works exactly like SUNION but instead of being returned the
resulting set is stored as dstkey. Any existing value in dstkey will be
over-written.

**RETURN VALUE**:
Status code reply
