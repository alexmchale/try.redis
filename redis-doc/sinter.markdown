# SINTER *key1 key2 ... keyN*

**TIME COMPLEXITY**:
O(N*M) worst case where N is the cardinality of the smallest set and M the number of sets

**DESCRIPTION**:
Return the members of a set resulting from the intersection of all the sets
hold at the specified keys. Like in LRANGE the result is sent to the client as
a multi-bulk reply (see the protocol specification for more information). If
just a single key is specified, then this command produces the same result as
SMEMBERS. Actually SMEMBERS is just syntax sugar for SINTERSECT.

Non existing keys are considered like empty sets, so if one of the keys is
missing an empty set is returned (since the intersection with an empty set
always is an empty set).

**RETURN VALUE**:
Multi bulk reply, specifically the list of common elements.
