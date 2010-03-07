# SETNX key value #

**TIME COMPLEXITY**:
O(1)

**DESCRIPTION**:
SETNX works exactly like SET with the only difference that if the key already
exists no operation is performed. SETNX actually means "SET if Not eXists".

**RETURN VALUE**:
Integer reply, specifically:

* 1 if the key was set
* 0 if the key was not set

