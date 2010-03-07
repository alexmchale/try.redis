# LRANGE *key* *start* *end*

**TIME COMPLEXITY**:
O(n) (with n being the length of the range)

**DESCRIPTION**:
Return the specified elements of the list stored at the specified key. Start
and end are zero-based indexes. 0 is the first element of the list (the list
head), 1 the next element and so on.

For example LRANGE foobar 0 2 will return the first three elements of the list.

*start* and *end* can also be negative numbers indicating offsets from the end
of the list. For example -1 is the last element of the list, -2 the penultimate
element and so on.

Indexes out of range will not produce an error: if start is over the end of the
list, or start <tt>></tt> end, an empty list is returned. If end is over the end
of the list Redis will threat it just like the last element of the list.

**RETURN VALUE**:
A multi bulk reply of a list of elements in the specified range.
