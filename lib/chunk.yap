

use "lib/mem.yap"


seq Chunk
{
    HEADER,
    BUFFER,
}


fn Chunk::FromBuffer(ptr)
{ 
    return ptr - (0 : Chunk::BUFFER); 
}
fn Chunk::ToBuffer(ptr)
{
    return ptr : Chunk::BUFFER;
}

seq Chunk::Config
{
    MAGIC = 4294967296, // (1 << 32)
}

fn Chunk::LH2S(chunk) // local header to size
{
    put header = chunk.Chunk::HEADER;
    jump corrupt ~ (header & Chunk::Config::MAGIC) == 0;
    put size = header ^ Chunk::Config::MAGIC;
    return size;

lab corrupt;
    print("Heap corruption! at %d, magic not present\n", [chunk]);
    syscall(SYSCALL::EXIT, 1);
}



// --- user heap ---
fn Chunk::New(words)
{
    put needed = words + 1;

    // *collars and leashes you* let's go for walkies~
    put walker = __heap_base;

    put trail = needed;
    lab loop;
        jump done ~ trail == 0;

        jump restart ~ walker.0;
            // advance trail
            put walker = walker : 1;
            put trail  = trail  - 1;

            jump loop;

        lab restart;
            // skip block
            put walker = walker : Chunk::LH2S(walker);

            //restart trail
            put trail = needed;

            jump loop;
    lab done;


    put chunk = walker - (0 : needed);
    put chunk.Chunk::HEADER = needed | Chunk::Config::MAGIC;

    return Chunk::ToBuffer(chunk);
}


fn Chunk::Void(ptr)
{
    put chunk = Chunk::FromBuffer(ptr);
    put size = Chunk::LH2S(chunk);

    Mem::Set(chunk, 0, size);
}


// --- regular chunk routines ---
fn Chunk::Size(ptr)
{
    put chunk = Chunk::FromBuffer(ptr);
    return Chunk::LH2S(chunk) - 1;
}

fn Chunk::Copy(ptr)
{
    put size = Chunk::Size(ptr);

    put new = Chunk::New(size);
    Mem::Cpy(new, ptr, size);

    return new;
}
