# x86_64 Syscall Reference

Common syscalls for agent debugging in Linux environments.

| Number | Name | Description |
|--------|------|-------------|
| 0 | read | Read from a file descriptor |
| 1 | write | Write to a file descriptor |
| 2 | open | Open a file or directory |
| 3 | close | Close a file descriptor |
| 4 | stat | Get file status |
| 5 | fstat | Get file status (using fd) |
| 6 | lstat | Get file status (for symlinks) |
| 9 | mmap | Map files or devices into memory |
| 11 | munmap | Unmap memory |
| 16 | ioctl | Device-specific input/output operations |
| 20 | writev | Write to multiple buffers |
| 32 | dup | Duplicate a file descriptor |
| 39 | getpid | Get process identification |
| 41 | socket | Create an endpoint for communication |
| 42 | connect | Initiate a connection on a socket |
| 59 | execve | Execute program |
| 60 | exit | Terminate the calling process |
| 80 | chdir | Change working directory |
| 82 | rename | Change the name or location of a file |
| 83 | mkdir | Create a directory |
| 84 | rmdir | Remove a directory |
| 89 | readlink | Read value of a symbolic link |
| 257 | openat | Open a file relative to a directory fd |

Note: This is a subset of the most common syscalls. For a full list, refer to `man syscalls` or `/usr/include/asm/unistd_64.h`.
