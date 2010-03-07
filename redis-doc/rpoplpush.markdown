# RPOPLPUSH *srckey* *dstkey*

**TIME COMPLEXITY**:
O(1)

**DESCRIPTION**:
Atomically return and remove the last (tail) element of the *srckey* list, and
push the element as the first (head) element of the *dstkey* list. For example
if the source list contains the elements "a","b","c" and the destination list
contains the elements "foo","bar" after an RPOPLPUSH command the content of the
two lists will be "a","b" and "c","foo","bar".

If the *key* does not exist or the list is already empty the special value 'nil'
is returned. If the *srckey* and *dstkey* are the same the operation is
equivalent to removing the last element from the list and pusing it as first
element of the list, so it's a "list rotation" command.

**RETURN VALUE**:
Bulk reply.
