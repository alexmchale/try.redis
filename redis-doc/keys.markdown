# KEYS pattern #

**TIME COMPLEXITY:**
O(n) (with n being the number of keys in the DB, and assuming keys and
pattern of limited length)

**DESCRIPTION:**
Returns all the keys matching the glob-style pattern as space separated
strings. For example if you have in the database the keys "foo" and "foobar"
the command "KEYS foo*" will return "foo foobar".

Glob style patterns examples:

* h?llo will match hello hallo hhllo
* h*llo will match hllo heeeello
* h[ae]llo will match hello and hallo, but not hillo

Use \ to escape special chars if you want to match them verbatim.

**RETURN VALUE:**
Bulk reply, specifically a string in the form of space separated list of keys.
Note that most client libraries will return an Array of keys and not a single
string with space separated keys (that is, split by " " is performed in the
client library usually).

