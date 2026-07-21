

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



fn FS::Sys::OpenRead(path)
{
    return syscall(
        SYSCALL::OPEN, 
        path,
        0, // O_RDONLY (fcntl.h)
        0  // irrelevent for open
    );
}

fn FS::Sys::OpenWrite(path)
{
    return syscall(
        SYSCALL::OPEN, 
        path,
        1, // O_WRONLY (fcntl.h)
        0  // irrelevent for open
    );
}

fn FS::Sys::Stat(path)
{
    put stat = Chunk::New(FS::STRUCT::__old_kernel_stat);
    put retval = syscall(SYSCALL::STAT, path, stat);

    jump skip ~ Sys::Error(retval) ^ Bool::TRUE;
        print("[FS::Sys::Stat] %s: `%s`\n", [Sys::ErrorMsg(retval), path]);
    lab skip;

    return stat;
}

fn FS::Sys::Size(path)
{
    put stat = FS::Sys::Stat(path);
    put size = (stat + FS::STRUCT::__old_kernel_stat::size::low).0;
    Chunk::Void(stat);
    return size;
}





