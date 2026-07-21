

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
}

fn Fs::ConvertPath(qpath)
{
    static 4096 ~ bpath;
    Str::ToBytes(bpath, qpath);
    return bpath;
}



fn FS::Sys::OpenRead(path)
{
    return Sys::TryCall(
        "FS::Sys::OpenRead",
        SYSCALL::OPEN, 
        Fs::ConvertPath(path),
        FS::ENUM::MODE::RDONLY,
        0  // irrelevent for open
    );
}

fn FS::Sys::OpenWrite(path)
{
    return Sys::TryCall(
        "FS::Sys::OpenWrite",
        SYSCALL::OPEN, 
        Fs::ConvertPath(path),
        FS::ENUM::MODE::WRONLY,
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





