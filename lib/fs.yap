

use "lib/syscall.yap"
use "lib/chunk.yap"
use "lib/bool.yap"

seq FS::STRUCT::__old_kernel_stat
{
    dev::low,  dev::high,  //short
    ino::low,  ino::high,  //short
    mode::low, mode::high, //short
    uid::low,  uid::high,  //short
    gid::low,  gid::high,  //short
    rdev::low, rdev::high, //short

    size::low, size::lowmid, size::highmid, size::high, //long

    // time fields are to be implemented.
}

seq FS::ENUM::MODE // (fcntl.h)
{
    RDONLY,
    WRONLY,
    WRDR,
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

fn FS::Sys::Size(path)
{
    put stat = FS::Sys::Stat(path);
    put size = (stat + FS::STRUCT::__old_kernel_stat::size::low).0;
    Chunk::Void(stat);
    return size;
}





