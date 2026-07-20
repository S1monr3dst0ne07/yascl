

use "lib/chunk.yap"


seq Dyn
{
    SIZE,
    CAPACITY,
    CONTAINER,
}

fn Dyn::Size(list)
{
    return list.Dyn::SIZE;
}


fn Dyn::CreatePopulate(size, capacity, container)
{
    put list = Chunk::New(Dyn);
    put list.Dyn::SIZE      = size;
    put list.Dyn::CAPACITY  = capacity;
    put list.Dyn::CONTAINER = container;
    return list;
}

fn Dyn::CreateUseChunk(container)
{
    put size = Chunk::Size(container);
    return Dyn::CreatePopulate(
        size, size, // cap = size
        container,
    );
}


fn Dyn::Create()
{
    return Dyn::CreateUseChunk(Chunk::New(1));
}


fn Dyn::CreateCopyChunk(chunk)
{
    put other = Chunk::Copy(chunk);
    return Dyn::CreateUseChunk(other);
}


fn Dyn::Copy(list)
{
    return Dyn::CreateCopyChunk(list.Dyn::CONTAINER);
}

fn Dyn::Delete(list)
{
    Chunk::Void(list.Dyn::CONTAINER);
    Chunk::Void(list);
}



fn Dyn::Recap(list, cap)
{
    jump invalid ~ cap < list.Dyn::SIZE;

    put container = Chunk::New(cap);

    Mem::Cpy(
        container,
        list.Dyn::CONTAINER,
        list.Dyn::CAPACITY,
    );

    Chunk::Void(list.Dyn::CONTAINER);
    put list.Dyn::CAPACITY  = cap;
    put list.Dyn::CONTAINER = container;

    lab invalid;
}


fn Dyn::Local::EnsureSize(list, size)
{
    jump fine ~ list.Dyn::CAPACITY > (size - 1);
        Dyn::Recap(
            list,
            list.Dyn::CAPACITY * 2,
        );
    lab fine; 
}





