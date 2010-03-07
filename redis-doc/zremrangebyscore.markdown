# ZREMRANGEBYSCORE *key min max*

**TIME COMPLEXITY**:
O(log(N))+O(M) with N being the number of elements in the sorted set and M the
number of elements removed by the operation

**DESCRIPTION**:
Remove all the elements in the sorted set at key with a score between min and
max (including elements with score equal to min or max).

**RETURN VALUE**:
Integer reply, specifically the number of elements removed.
