# SINTERSTORE *dstkey key1 key2 ... keyN*

**TIME COMPLEXITY**:
O(N*M) worst case where N is the cardinality of the smallest set and M the
number of sets

**DESCRIPTION**:
This commnad works exactly like SINTER but instead of being returned the
resulting set is sotred as dstkey.

**RETURN VALUE**:
Status code reply
