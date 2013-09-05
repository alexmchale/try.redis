# TTL key #

**DESCRIPTION**:
The TTL command returns the remaining time to live in seconds of a key that
has an EXPIRE set. This introspection capability allows a Redis client to
check how many seconds a given key will continue to be part of the dataset.
If the Key does not have an associated expire, -1 is returned.
If the Key does not exists, -2 is returned.

**RETURN VALUE**:
Integer reply

