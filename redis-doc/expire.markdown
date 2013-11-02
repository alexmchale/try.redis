# EXPIRE key seconds

**TIME COMPLEXITY**
O(1)

**DESCRIPTION**
Set a timeout on `key`. After the timeout has expired, the key will
automatically be deleted. A key with an associated timeout is often said to be
volatile in Redis terminology.  For more read [the official
documentation](http://redis.io/commands/expire).

**RETURN VALUE**
integer reply, specifically:

* `1` if the timeout was set.
* `0` if `key` does not exist or the timeout could not be set.
