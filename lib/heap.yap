

use "lib/mem.yap"

//TODO: implement properly linked chunks

seq Heap::CHUNK
{
    SIZE,
    BUFFER,
}


fn Heap::New(words)
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
    put chunk.Heap::CHUNK::SIZE = needed;
    print("base: %d\n", [chunk]);
    return chunk : Heap::CHUNK::BUFFER;
}

fn Heap::Void(ptr)
{
    put chunk = ptr - (0 : Heap::CHUNK::BUFFER);
    put size = chunk.Heap::CHUNK::SIZE;

    Mem::Set(chunk, 0, size);
}



