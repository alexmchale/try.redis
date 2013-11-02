# SET key value #

**TIME COMPLEXITY**:
O(1)

**DESCRIPTION**:
Set key to hold the string value. If key already holds a value, it is
overwritten, regardless of its type. Any previous time to live associated with
the key is discarded on successful SET operation.

#### Options

* `EX seconds` -- Set the specified expire time, in seconds.
* `PX milliseconds` -- Set the specified expire time, in milliseconds.
* `NX` -- Only set the key if it does not already exist.
* `XX` -- Only set the key if it already exist.

**RETURN VALUE**:
Status code reply: OK if `SET` was executed correctly. Null multi-bulk reply: a
Null Bulk Reply is returned if the `SET` operation was not performed becase the
user specified the `NX` or `XX` option but the condition was not met.
