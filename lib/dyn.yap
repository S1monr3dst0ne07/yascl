

use "lib/chunk.yap"
use "lib/bool.yap"


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
fn Dyn::Ptr(list)
    // shorthand for get/set access.
{
    return list.Dyn::CONTAINER;
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
    put DEFAULT_CAP = 1;
    return Dyn::CreatePopulate(
        0,
        DEFAULT_CAP,
        Chunk::New(DEFAULT_CAP),
    );
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

    return Bool::TRUE;

lab invalid;
    return Bool::FALSE;
}


fn Dyn::Local::EnsureSize(list, size)
{
    jump fine ~ (list.Dyn::CAPACITY) > (size - 1);
        // can never error for obvious reasons 
        Dyn::Recap(
             list,
            (list.Dyn::CAPACITY) * 2,
        ); 
    lab fine; 
}

fn Dyn::Insert(list, index, elem)
{
    put new_size = (list.Dyn::SIZE) + 1;
    Dyn::Local::EnsureSize(list,new_size);

    jump out_of_bounds ~ index > (list.Dyn::SIZE);
    put pos = list.Dyn::CONTAINER : index;

    Mem::CpyB(
        pos : 1, pos,
        (list.Dyn::SIZE) - index,
    );

    put (list.Dyn::CONTAINER).index = elem;
    put list.Dyn::SIZE = new_size;

    return Bool::TRUE;
lab out_of_bounds;
    return Bool::FALSE;
}




