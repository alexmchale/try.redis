# PEXPIRE key milliseconds

**TIME COMPLEXITY**
O(1)

**DESCRIPTION**
This command works exactly like `EXPIRE` but the time to live of the key is
specified in milliseconds instead of seconds.

**RETURN VALUE**
integer reply, specifically:

* `1` if the timeout was set.
* `0` if `key` does not exist or the timeout could not be set.
