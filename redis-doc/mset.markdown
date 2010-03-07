# MSET key1 value1 key2 value2 ... keyN valueN #

**TIME COMPLEXITY**:
O(1) to set every key

**DESCRIPTION**:

Set the the respective keys to the respective values. MSET will replace old
values with new values, while MSETNX will not perform any operation at all
even if just a single key already exists.

Because of this semantic MSETNX can be used in order to set different keys
representing different fields of an unique logic object in a way that ensures
that either all the fields or none at all are set.

Both MSET and MSETNX are atomic operations. This means that for instance if
the keys A and B are modified, another client talking to Redis can either see
the changes to both A and B at once, or no modification at all.

**RETURN VALUE**: Status code reply Basically +OK as MSET can't fail
