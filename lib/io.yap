

use "lib/syscall.yap"

seq IO::STD
{
    IN  = 0,
    OUT = 1,
    ERR = 2,
}


fn IO::Write(fd, qstr, len)
{
    // syscall are slow anyways.
    put bstr = Chunk::New(len);
    Mem::ToBytes(bstr, qstr, len);
    syscall(SYSCALL::WRITE, fd, bstr, len);
    Chunk::Void(bstr);
}

fn IO::Print(str)
{
    put len = Str::Len(str);
    IO::Write(IO::STD::OUT, str, len);
}

fn IO::Error(str)
{
    put len = Str::Len(str);
    IO::Write(IO::STD::ERR, str, len);
}




