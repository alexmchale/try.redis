# LSET *key* *index* *value*

**TIME COMPLEXITY**:
O(N) (with N being the length of the list)

**DESCRIPTION**:
Set the list element at *index* (see LINDEX for information about the *index*
argument) with the new *value*. Out of range indexes will generate an error.
Note that setting the first or last elements of the list is O(1).

Similarly to other list commands accepting indexes, the index can be negative
to access elements starting from the end of the list. So -1 is the last element,
-2 is the penultimate, and so forth.

**RETURN VALUE**:
Status code reply.
