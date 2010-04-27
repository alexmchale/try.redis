# HKEYS key #
# HVALS key #
# HGETALL key #

**TIME COMPLEXITY**:
O(N), where N is the total number of entries

**DESCRIPTION**:
HKEYS returns all the fields names contained into a hash, HVALS all the
associated values, while HGETALL returns both the fields and values in the form
of field1, value1, field2, value2, ..., fieldN, valueN.

**RETURN VALUE**:
Multi Bulk Reply
