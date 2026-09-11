

use "lib/syscall.yap"
use "lib/chunk.yap"
use "lib/bool.yap"
use "lib/dyn.yap"

seq FS::STRUCT::stat
    // https://github.com/torvalds/linux/blob/master/arch/x86/include/uapi/asm/stat.h
{
    mode    = 24,
    size    = 48,
}
seq FS::STRUCT::dirent
{
    d_reclen = 16,
    d_name = 18,
    _virt_len = 20,
}


seq FS::ENUM::MODE // (fcntl.h)
{
    RDONLY = 0,
    WRONLY = 1,
    WRDR   = 2,
    CREATE = 64,
    TRUNC  = 512,
}

seq FS::Seek::Mode
{
    SEEK_SET,
    SEEK_CUR,
    SEEK_END,
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
    put stat = Chunk::New(FS::STRUCT::stat);
    Sys::TryCall("FS::Sys::Stat", SYSCALL::FSTAT, fd, stat);

    return stat;
}



fn FS::Sys::Size(fd)
{
    put stat = FS::Sys::Stat(fd);
    put size = (stat + FS::STRUCT::stat::size).0;
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

fn FS::IsDir(path)
{
    put fd = FS::Sys::Open(path, FS::ENUM::MODE::RDONLY);
    put stat = FS::Sys::Stat(fd);

    // TODO FIX THIS
    // https://github.com/torvalds/linux/blob/master/include/uapi/linux/stat.h

    put mode = (stat + FS::STRUCT::stat::mode).0;
    put is_dir = (mode & (1 << 14)) != 0;

    Chunk::Void(stat);
    FS::Sys::Close(fd);

    return is_dir;
}

fn FS::Size(path)
{
    put fd = FS::Sys::Open(path, FS::ENUM::MODE::RDONLY);
    put size = FS::Sys::Size(fd);
    FS::Sys::Close(fd);
    return size;
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





seq FS::Dir::Type
{
    UNKNOWN   = 0,
    FIFO      = 1,
    CHAR_DEV  = 2,
    DIR       = 4,
    BLOCK_DEV = 6,
    FILE      = 8,
    LINK      = 10,
    UNIX_SOCK = 12,
}
seq FS::Dir::Ent
{
    NAME, // Str
    TYPE, // FS::Dir::Type
}

seq FS::Dir::Config
{
    BUFFER_SIZE = 1000000,
}

fn FS::Dir::ParseDirEnt(buffer, listing)
{
    put rec_len_ptr = buffer + FS::STRUCT::dirent::d_reclen;
    put record_length = (rec_len_ptr.0) & ((1 << 16) - 1);
    put name_length = 
        record_length - 
        (FS::STRUCT::dirent::_virt_len);

    put name = Chunk::New(name_length+1);
    put name.name_length = '\0';
    Mem::FromBytes(
        name, 
        buffer + FS::STRUCT::dirent::d_name, 
        name_length
    );

    put type_offset = record_length - 1;
    put type = ((buffer + type_offset).0) & 255;

    put entry = Chunk::New(FS::Dir::Ent);
    put entry.FS::Dir::Ent::NAME = name;
    put entry.FS::Dir::Ent::TYPE = type;
    Dyn::Push(listing, entry);

    return record_length;
}

fn FS::Dir(path)
    // gives back Dyn<FS::Dir::Ent>
{
    static FS::Dir::Config::BUFFER_SIZE ~ buffer;

    put fd = syscall(
        SYSCALL::OPEN, 
        FS::ConvertPath(path),
        FS::ENUM::MODE::RDONLY,
        0  // irrelevent for open
    );
    jump path_not_exists ~ Sys::Error(fd);
    jump not_a_dir       ~ Bool::Not(FS::IsDir(path));

    put buffer_capacity = Sys::TryCall(
        "FS::Dir",
        SYSCALL::GETDENTS,
        fd,
        buffer,
        FS::Dir::Config::BUFFER_SIZE,
    );

    put listing = Dyn::Create();

    put offset = 0;
    lab loop;
        jump done ~ offset == buffer_capacity;
        put offset = offset + FS::Dir::ParseDirEnt(
            buffer + offset, 
            listing
        );

        jump loop;
    lab done;

    return listing;

lab path_not_exists;
lab not_a_dir;
    return Mem::NULL;
}


