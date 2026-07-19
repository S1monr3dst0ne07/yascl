

use "lib/mem.yap"


seq Chunk
{
    SIZE,
    BUFFER,
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

        put must_restart = walker.0;
        jump restart ~ must_restart;
            // advance trail
            put walker = walker : 1;
            put trail  = trail  - 1;

            jump loop;

        lab restart;
            // skip block
            put walker = walker : (walker.0);

            //restart trail
            put trail = needed;

            jump loop;
    lab done;

    put chunk = walker - (0 : needed);
    put chunk.Chunk::SIZE = needed;
    return chunk : Chunk::BUFFER;
}

fn Chunk::Void(ptr)
{
    put chunk = ptr - (0 : Chunk::BUFFER);
    put size = chunk.Chunk::SIZE;

    Mem::Set(chunk, 0, size);
}


// --- regular chunk routines ---



