
use "lib/chunk.yap"
use "lib/mem.yap"

fn Args::Read(arg)
{
    put len = Args::Len(arg);
    put out = Chunk::New(len);
    Mem::FromBytes(out, arg, len);
    return out;
}


fn Args::Len(arg)
{
    put i = 0;

    lab loop;
        put i = i + 1;
    jump loop ~ (arg+i).0;

    return i;
}


