# Common Linux Error Codes (errno)

Common error codes found during agent debugging in sandbox environments.

| Number | Name | Description |
|--------|------|-------------|
| 1 | EPERM | Operation not permitted |
| 2 | ENOENT | No such file or directory |
| 3 | ESRCH | No such process |
| 4 | EINTR | Interrupted system call |
| 5 | EIO | I/O error |
| 6 | ENXIO | No such device or address |
| 7 | E2BIG | Argument list too long |
| 8 | ENOEXEC | Exec format error |
| 9 | EBADF | Bad file number |
| 10 | ECHILD | No child processes |
| 11 | EAGAIN | Try again |
| 12 | ENOMEM | Out of memory |
| 13 | EACCES | Permission denied |
| 14 | EFAULT | Bad address |
| 16 | EBUSY | Device or resource busy |
| 17 | EEXIST | File exists |
| 18 | EXDEV | Cross-device link |
| 19 | ENODEV | No such device |
| 20 | ENOTDIR | Not a directory |
| 21 | EISDIR | Is a directory |
| 22 | EINVAL | Invalid argument |
| 23 | ENFILE | File table overflow |
| 24 | EMFILE | Too many open files |
| 28 | ENOSPC | No space left on device |
| 32 | EPIPE | Broken pipe |

Note: These are standard POSIX error codes. For a full list, refer to `man errno` or `/usr/include/asm-generic/errno-base.h`.
