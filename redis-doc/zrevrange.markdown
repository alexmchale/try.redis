# ZREVRANGE *key start end [WITHSCORES]*

**TIME COMPLEXITY**:
O(log(N))+O(M) (with N being the number of elements in the sorted set and M the
number of elements requested)

**DESCRIPTION**:
Return the specified elements of the sorted set at the specified key. The
elements are considered sorted from the lowerest to the highest score when
using ZRANGE, and in the reverse order when using ZREVRANGE. Start and end are
zero-based indexes. 0 is the first element of the sorted set (the one with the
lowerest score when using ZRANGE), 1 the next element by score and so on.

start and end can also be negative numbers indicating offsets from the end of
the sorted set. For example -1 is the last element of the sorted set, -2 the
penultimate element and so on.

Indexes out of range will not produce an error: if start is over the end of the
sorted set, or start > end, an empty list is returned. If end is over the end
of the sorted set Redis will threat it just like the last element of the sorted
set.

It's possible to pass the WITHSCORES option to the command in order to return
not only the values but also the scores of the elements. Redis will return the
data as a single list composed of value1,score1,value2,score2,...,valueN,scoreN
but client libraries are free to return a more appropriate data type (what we
think is that the best return type for this command is a Array of
two-elements Array / Tuple in order to preserve sorting).

**RETURN VALUE**:
Multi bulk reply, specifically a list of elements in the specified range.
