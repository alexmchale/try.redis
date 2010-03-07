### TYPE key ###

**Time complexity**: O(1)

Return the type of the value stored at key in form of a string. The type can
be one of "none", "string", "list", "set". "none" is returned if the key
does not exist.

### RETURN VALUE ###

Status code reply, specifically:

* "none" if the key does not exist
* "string" if the key contains a String value
* "list" if the key contains a List value
* "set" if the key contains a Set value

