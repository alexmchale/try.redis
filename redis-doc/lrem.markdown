# LREM <i>key</i> <i>count</i> <i>value</i>

**TIME COMPLEXITY**:
O(N) (with N being the length of the list)

**DESCRIPTION**:
Remove the first *count* occurrences of the *value* element from the list. If
*count* is zero all the elements are removed. If *count* is negative elements
are removed from tail to head, instead to go from head to tail that is the
normal behaviour. So for example LREM with count -2 and *hello* as value to
remove against the list (a,b,c,hello,x,hello,hello) will lave the list
(a,b,c,hello,x). The number of removed elements is returned as an integer, see
below for more information about the returned value. Note that non existing
keys are considered like empty lists by LREM, so LREM against non existing
keys will always return 0.

**RETURN VALUE**:
An integer reply containing the number of removed elements if the operation succeeded.
