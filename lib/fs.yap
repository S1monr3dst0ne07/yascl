

use "lib/syscall.yap"
use "lib/chunk.yap"
use "lib/bool.yap"

seq FS::STRUCT::__old_kernel_stat
{
    dev     = 0,
    ino     = 8,
    mode    = 24,
    nlink   = 16,
    uid     = 28,
    gid     = 32,
    rdev    = 40,
    size    = 48,
    blksize = 56,
    blocks  = 64,
    atim    = 72,
    mtim    = 88,
    ctim    = 104,
}

seq FS::ENUM::MODE // (fcntl.h)
{
    RDONLY = 0,
    WRONLY = 1,
    WRDR   = 2,
    CREATE = 64,
    TRUNC  = 512,
}

fn FS::ConvertPath(qpath)
{
    static 4096 ~ bpath;
    Str::ToBytes(bpath, qpath);
    return bpath;
}



fn FS::Sys::Open(path, mode)
{
    return Sys::TryCall(
        "FS::Sys::Open",
        SYSCALL::OPEN, 
        FS::ConvertPath(path),
        mode,
        0  // irrelevent for open
    );
}

fn FS::Sys::Stat(fd)
{
    put stat = Chunk::New(FS::STRUCT::__old_kernel_stat);
    Sys::TryCall("FS::Sys::Stat", SYSCALL::FSTAT, fd, stat);

    return stat;
}

fn FS::Sys::Size(fd)
{
    put stat = FS::Sys::Stat(fd);
    put size = (stat + FS::STRUCT::__old_kernel_stat::size).0;
    Chunk::Void(stat);
    return size;
}

fn FS::Sys::Close(fd)
{
    return Sys::TryCall(
        "FS::Sys::Close",
        SYSCALL::CLOSE, 
        fd,
    );
}


fn FS::Read(path)
{
    put fd = FS::Sys::Open(path, FS::ENUM::MODE::RDONLY);
    put size = FS::Sys::Size(fd) + 1;

        // 8 times too big. doesn't matter, will get deallocated anyways.
    put bfile = Chunk::New(size); 
    put qfile = Chunk::New(size);

    Sys::TryCall(
        "FS::Read",
        SYSCALL::READ,
        fd,
        bfile,
        size,
    );

    Mem::FromBytes(qfile, bfile, size);
    Chunk::Void(bfile);
    FS::Sys::Close(fd);
    put qfile.(size - 1) = 0;
    return qfile;
}


fn FS::Write(path, qfile)
{
    put fd = FS::Sys::Open(path, 
        FS::ENUM::MODE::WRONLY |
        FS::ENUM::MODE::CREATE |
        FS::ENUM::MODE::TRUNC
    );

    put size = Str::Len(qfile);
    put bfile = Chunk::New(size);

    Mem::ToBytes(bfile, qfile, size);

    put retval = Sys::TryCall(
        "FS::Write",
        SYSCALL::WRITE,
        fd,
        bfile,
        size,
    );

    Chunk::Void(bfile);
    FS::Sys::Close(fd);
}




