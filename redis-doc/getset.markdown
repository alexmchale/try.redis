# GETSET key value #

**TIME COMPLEXITY**:
O(1)

**DESCRIPTION**:
GETSET is an atomic set this value and return the old value command. Set key
to the string value and return the old value stored at key. The string can't
be longer than 1073741824 bytes (1 GB).

**RETURN VALUE**:
Bulk reply

**DESIGN PATTERNS**:
GETSET can be used together with INCR for counting with atomic reset when a
given condition arises. For example a process may call INCR against the key
mycounter every time some event occurred, but from time to time we need to get
the value of the counter and reset it to zero atomically using GETSET
mycounter 0.

