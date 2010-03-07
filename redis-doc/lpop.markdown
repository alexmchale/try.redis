# LPOP *key*

**TIME COMPLEXITY**:
O(1)

**DESCRIPTION**:
Atomically return and remove the first (LPOP) or last (RPOP) element of the
list. For example if the list contains the elements "a","b","c" LPOP will
return "a" and the list will become "b","c".

If the *key* does not exist or the list is already empty the special value
'nil' is returned.

**RETURN VALUE**:
Bulk reply.
