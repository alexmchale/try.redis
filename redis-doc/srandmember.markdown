# SRANDMEMBER *key*

**TIME COMPLEXITY**:
O(1)

**DESCRIPTION**:
Return a random element from a Set, without removing the element. If the Set is
empty or the key does not exist, a nil object is returned.

The SPOP command does a similar work but the returned element is popped
(removed) from the Set.

**RETURN VALUE**:
Bulk reply
