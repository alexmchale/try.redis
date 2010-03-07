# SDIFF *key1 key2 ... keyN*

**TIME COMPLEXITY**:
O(N) with N being the total number of elements of all the sets

**DESCRIPTION**:
Return the members of a set resulting from the difference between the first set
provided and all the successive sets. Example:

    key1 = x,a,b,c
    key2 = c
    key3 = a,d
    SDIFF key1,key2,key3 => x,b

Non existing keys are considered like empty sets.

**RETURN VALUE**:
Multi bulk reply, specifically the list of common elements.
