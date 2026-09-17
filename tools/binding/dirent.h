
// this stuff is not part of uAPI for some reason.
// i don't know. i'm not a kernel wizard.

// TODO: look into why this is like this

// https://www.man7.org/linux/man-pages/man2/getdents.2.html
struct linux_dirent 
{
    unsigned long  d_ino;     /* Inode number */
    unsigned long  d_off;     /* Not an offset; see below */
    unsigned short d_reclen;  /* Length of this linux_dirent */
    char           d_name[];  /* Filename (null-terminated) */
                              /* length is actually (d_reclen - 2 -
                                 offsetof(struct linux_dirent, d_name)) */
    /*
    char           pad;       // Zero padding byte
    char           d_type;    // File type (only since Linux
                              // 2.6.4); offset is (d_reclen - 1)
    */
};

#define sizeof_linux_dirent (sizeof(struct linux_dirent) + 2)

// from /usr/include/dirent.h
enum
{
    DT_UNKNOWN = 0,
    DT_FIFO = 1,
    DT_CHR = 2,
    DT_DIR = 4,
    DT_BLK = 6,
    DT_REG = 8,
    DT_LNK = 10,
    DT_SOCK = 12,
    DT_WHT = 14
};


