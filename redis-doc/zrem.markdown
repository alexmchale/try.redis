# ZREM *key member*

**TIME COMPLEXITY**:
O(log(N)) with N being the number of elements in the sorted set

**DESCRIPTION**:
Remove the specified member from the sorted set value stored at key. If
member was not a member of the set no operation is performed. If key does not
not hold a set value an error is returned.

**RETURN VALUE**:
Integer reply, specifically:

* 1 if the new element was removed
* 0 if the new element was not a member of the set
