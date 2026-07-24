

use "lib/mem.yap"


seq Chunk::Config
{
    MAGIC = 123456789,
}
seq Chunk
{
    MAGIC_LOW,  // must be Chunk::Config::MAGIC
    MAGIC_HIGH, // must also be Chunk::Config::MAGIC
        // chunk is not present if both are zero.

    SIZE,  // 
    NEXT,  // Mem::NULL for last  chunk
    PREV,  // Mem::NULL for first chunk
    BASE,  // base address of chunk
}


fn Chunk::FromBase(ptr)
{ 
    return ptr - (0 : Chunk::BASE); 
}
fn Chunk::ToBase(ptr)
{
    return ptr + (0 : Chunk::BASE);
}

fn Chunk::Local::VerifyMagic(chunk)
{
    jump corr ~ (chunk.Chunk::MAGIC_LOW)  != Chunk::Config::MAGIC;
    jump corr ~ (chunk.Chunk::MAGIC_HIGH) != Chunk::Config::MAGIC;
    jump good;

    lab corr;
        print("!!! Heap corrupted at %d, magic not present\n", [chunk]);
        syscall(SYSCALL::EXIT, 1);
    lab good;
}


fn Chunk::Local::Init()
{
    jump done ~ __heap_base.0;
        put primordial = __heap_base;
        put primordial.Chunk::MAGIC_LOW  = Chunk::Config::MAGIC;
        put primordial.Chunk::MAGIC_HIGH = Chunk::Config::MAGIC;
        put primordial.Chunk::SIZE       = Chunk::BASE; // base size
        put primordial.Chunk::NEXT       = Mem::NULL;
        put primordial.Chunk::PREV       = Mem::NULL;
    lab done;
}

// --- user heap ---
fn Chunk::New(words)
{
    Chunk::Local::Init(); // make sure heap is initialized.
    put needed = words + Chunk::BASE;

    // *collars and leashes you* let's go for walkies~
    put walker = __heap_base;


    lab loop;
        Chunk::Local::VerifyMagic(walker);
        jump last_chunk ~ (walker.Chunk::NEXT) == Mem::NULL;

        put interval = (walker.Chunk::NEXT) - walker;
        put space = (interval >> 3) - (walker.Chunk::SIZE);
        jump enough_space ~ space >  needed;
        jump enough_space ~ space == needed;

        // WALKIES !!!!!!
        put walker = walker.Chunk::NEXT;
        jump loop;

lab last_chunk;
lab enough_space;
    // last chunk or enough space after chunk.
    // allocate new chunk after this one. 
    put prev = walker;
    put next = walker.Chunk::NEXT;

    put new = walker : (walker.Chunk::SIZE);
    put new.Chunk::MAGIC_LOW  = Chunk::Config::MAGIC;
    put new.Chunk::MAGIC_HIGH = Chunk::Config::MAGIC;
    put new.Chunk::SIZE       = needed;
    put new.Chunk::NEXT       = next;
    put new.Chunk::PREV       = prev;

    put prev.Chunk::NEXT = new;
    jump skip_next ~ next == Mem::NULL;
        put next.Chunk::PREV = new;
    lab skip_next;

    return Chunk::ToBase(new);
}


fn Chunk::Void(ptr)
{
    // grab chunk data
    put chunk = Chunk::FromBase(ptr);
    put size = chunk.Chunk::SIZE;

    Chunk::Local::VerifyMagic(chunk);

    // unlink chunk
    put prev = chunk.Chunk::PREV;
    put next = chunk.Chunk::NEXT;

    put prev.Chunk::NEXT = next;
    jump skip_next ~ next == Mem::NULL;
        put next.Chunk::PREV = prev;
    lab skip_next;

    // zero chunk
    Mem::Set(chunk, 0, size);
}

fn Chunk::Size(ptr)
{
    put chunk = Chunk::FromBase(ptr);
    return (chunk.Chunk::SIZE) - Chunk::BASE;
}

fn Chunk::Copy(ptr)
{
    put size = Chunk::Size(ptr);

    put new = Chunk::New(size);
    Mem::Cpy(new, ptr, size);

    return new;
}
