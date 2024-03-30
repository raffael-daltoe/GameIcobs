
#include <sys/stat.h>
#include <newlib.h>
#include <unistd.h>
#include <errno.h>

#include "uart.h"

#undef errno
extern int errno;

#define STDOUT_FILENO 1

/* It turns out that older newlib versions use different symbol names which goes
 * against newlib recommendations. Anyway this is fixed in later version.
 */
#if __NEWLIB__ <= 2 && __NEWLIB_MINOR__ <= 5
#    define _sbrk sbrk
#    define _write write
#    define _close close
#    define _lseek lseek
#    define _read read
#    define _fstat fstat
#    define _isatty isatty
#endif

void unimplemented_syscall()
{
    const char *p = "Unimplemented system call called!\n";
    while (*p)
        UART1_Write(*(p++));
}

int nanosleep(const struct timespec *rqtp, struct timespec *rmtp)
{
    errno = ENOSYS;
    return -1;
}

int _access(const char *file, int mode)
{
    errno = ENOSYS;
    return -1;
}

int _chdir(const char *path)
{
    errno = ENOSYS;
    return -1;
}

int _chmod(const char *path, mode_t mode)
{
    errno = ENOSYS;
    return -1;
}

int _chown(const char *path, uid_t owner, gid_t group)
{
    errno = ENOSYS;
    return -1;
}

int _close(int file)
{
    return -1;
}

int _execve(const char *name, char *const argv[], char *const env[])
{
    errno = ENOMEM;
    return -1;
}

void _exit(int status) {
  __asm("wfi");
}

int _faccessat(int dirfd, const char *file, int mode, int flags)
{
    errno = ENOSYS;
    return -1;
}

int _fork(void)
{
    errno = EAGAIN;
    return -1;
}

int _fstat(int file, struct stat *st)
{
    st->st_mode = S_IFCHR;
    return 0;
    // errno = -ENOSYS;
    // return -1;
}

int _fstatat(int dirfd, const char *file, struct stat *st, int flags)
{
    errno = ENOSYS;
    return -1;
}

int _ftime(struct timeb *tp)
{
    errno = ENOSYS;
    return -1;
}

char *_getcwd(char *buf, size_t size)
{
    errno = -ENOSYS;
    return NULL;
}

int _getpid()
{
    return 1;
}

int _gettimeofday(struct timeval *tp, void *tzp)
{
    errno = -ENOSYS;
    return -1;
}

int _isatty(int file)
{
    return (file == STDOUT_FILENO);
}

int _kill(int pid, int sig)
{
    errno = EINVAL;
    return -1;
}

int _link(const char *old_name, const char *new_name)
{
    errno = EMLINK;
    return -1;
}

off_t _lseek(int file, off_t ptr, int dir)
{
    return 0;
}

int _lstat(const char *file, struct stat *st)
{
    errno = ENOSYS;
    return -1;
}

int _open(const char *name, int flags, int mode)
{
    return -1;
}

int _openat(int dirfd, const char *name, int flags, int mode)
{
    errno = ENOSYS;
    return -1;
}

ssize_t _read(int file, void *ptr, size_t len)
{
    return 0;
}

int _stat(const char *file, struct stat *st)
{
    st->st_mode = S_IFCHR;
    return 0;
    // errno = ENOSYS;
    // return -1;
}

long _sysconf(int name)
{

    return -1;
}

clock_t _times(struct tms *buf)
{
    return -1;
}

int _unlink(const char *name)
{
    errno = ENOENT;
    return -1;
}

int _utime(const char *path, const struct utimbuf *times)
{
    errno = ENOSYS;
    return -1;
}

int _wait(int *status)
{
    errno = ECHILD;
    return -1;
}

int _write (int file, char * ptr, int len) {
    int written = 0;

    if ((file != 1) && (file != 2) && (file != 3)) {
        return -1;
    }

    for (; len != 0; --len) {
        UART1_Write((char)*(ptr++));
        ++written;
    }
    return written;
}
