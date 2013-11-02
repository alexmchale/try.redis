# MULTI

Marks the start of a [transaction][tt] block.
Subsequent commands will be queued for atomic execution using `EXEC`.

[tt]: http://redis.io/topics/transactions

** RETURN VALUE**

Status code reply: always OK.
