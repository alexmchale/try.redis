# HMGET key field [field ...]

**TIME COMPLEXITY**
O(N) where N is the number of fields being requested.

**DESCRIPTION**

Returns the values associated with the specified `fields` in the hash stored at
`key`.

For every `field` that does not exist in the hash, a `nil` value is returned.
Because a non-existing keys are treated as empty hashes, running `HMGET`
against a non-existing `key` will return a list of `nil` values.

**RETURN VALUE**

Multi-bulk reply: list of values associated with the given fields, in the same
order as they are requested.
