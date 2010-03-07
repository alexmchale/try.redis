# SADD *key* *member*

**TIME COMPLEXITY**:
O(1)

**DESCRIPTION**:
Add the specified member to the set value stored at key. If member is already a
member of the set no operation is performed. If key does not exist a new set
with the specified member as sole member is created. If the key exists but does
not hold a set value an error is returned.

**RETURN VALUE**:
Integer reply, specifically:

* 1 if the new element was added
* 0 if the element was already a member of the set

