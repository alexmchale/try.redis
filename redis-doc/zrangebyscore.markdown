# ZRANGEBYSCORE *key min max [LIMIT offset count] (Redis >= 1.1)*
# ZRANGEBYSCORE *key min max [LIMIT offset count] [WITHSCORES] (Redis >= 1.3.4)*

**TIME COMPLEXITY**:
O(log(N))+O(M) with N being the number of elements in the sorted set and M the
number of elements returned by the command, so if M is constant (for instance
you always ask for the first ten elements with LIMIT) you can consider it
O(log(N))

**DESCRIPTION**:
Return the all the elements in the sorted set at key with a score between min
and max (including elements with score equal to min or max).

The elements having the same score are returned sorted lexicographically as
ASCII strings (this follows from a property of Redis sorted sets and does not
involve further computation).

Using the optional LIMIT it's possible to get only a range of the matching
elements in an SQL-alike way. Note that if offset is large the commands needs
to traverse the list for offset elements and this adds up to the O(M) figure.

**RETURN VALUE**:
Multi bulk reply, specifically a list of elements in the specified score range.
