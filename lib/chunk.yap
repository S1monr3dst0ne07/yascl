

use "lib/mem.yap"

// K&R user-heap implementation.
// hopefully more readable than the original. :3

seq Chunk::FB // free block
{
        // number of units, measured by header.
        // this is done to prevent the header
        // from getting sliced.
    UNITS, 
    SIZE, // number of actual qwords stored.
    NEXT, // pointer to next chunk
    PADDING, // everybody needs some extra padding sometimes ;3
}


fn Chunk::FreePtr()
{
    static 1 ~ ptr;
    return ptr;
}


fn Chunk::Local::Init()
{
    jump done ~ Chunk::FreePtr().0;

    // first chunk, ever!
    static 10 ~ primal;

    // initialize free list
    put Chunk::FreePtr().0 = primal;

    // initialize primal chunk, making it point to itself.
    //  (the free block for a cyclic linked list)
    put primal.Chunk::FB::NEXT = primal;
    put primal.Chunk::FB::UNITS = 0;

lab done;
}




// --- user heap ---
fn Chunk::New(words)
{
    put need = ((words + Chunk::FB - 1) / Chunk::FB) + 1;
    Chunk::Local::Init(); // make sure heap is initialized.

    put prev = Chunk::FreePtr().0;
    put curr = prev.Chunk::FB::NEXT;


    lab find_loop;
        put units = curr.Chunk::FB::UNITS;
        jump not_big_enough ~ units <  need;
        jump exact_match    ~ units == need;
        jump cut_block;

    lab not_big_enough;
        jump still_in_free_list ~ curr != Chunk::FreePtr().0;

        // free list has wrapped around.
        // the heap needs to be expanded.
        put curr = Chunk::MoreCore(need);

    lab still_in_free_list;
        // move to next block.
        put prev = curr;
        put curr = curr.Chunk::FB::NEXT;
    jump find_loop;


lab exact_match;
    put prev.Chunk::FB::NEXT = curr.Chunk::FB::NEXT;
    jump done;

lab cut_block;
    // shrink old.
    put curr.Chunk::FB::UNITS = (curr.Chunk::FB::UNITS) - need;
    // make new.
    put curr = curr : ((curr.Chunk::FB::UNITS) * Chunk::FB);
    put curr.Chunk::FB::UNITS = need;

lab done;
    put Chunk::FreePtr().0 = prev;
    put curr.Chunk::FB::SIZE = words; // update metadata
    put base = curr : Chunk::FB;

    Mem::Set(base, 0, words);

    return base;
}


fn Chunk::MoreCore(units)
{
    put MIN_CORE_NUMB = 1024;
    jump units_good ~ units > MIN_CORE_NUMB;
        put units = MIN_CORE_NUMB;
    lab units_good;

    put head = Mem::SmartBreak(units * Chunk::FB);
    put head.Chunk::FB::UNITS = units;

    put base = head : Chunk::FB;
    Chunk::VoidOFF(base); //merge into free list

    return Chunk::FreePtr().0;
}


fn Chunk::Local::After(chunk)
    // compute head pointer of
    // chunk immediately after chunk.
{
    return chunk : (chunk.Chunk::FB::UNITS);
}

fn Chunk::Void(ptr)
{
    put head = ptr : (0 - Chunk::FB);
    put neigh = Chunk::FreePtr().0;

    lab find_neighbor_loop;
        // block has been found on bounds enter.
        jump found ~ (neigh < head) & (head < (neigh.Chunk::FB::NEXT));

        // special check for physical free list memory wrap around.
        put last = (neigh < (neigh.Chunk::FB::NEXT)) ^ Bool::TRUE;
        put semibound = (neigh < head) | (head < (neigh.Chunk::FB::NEXT));
        jump found ~ last & semibound;

        put neigh = neigh.Chunk::FB::NEXT;
        jump find_neighbor_loop;
    lab found;

    put next = neigh.Chunk::FB::NEXT;
    put head.Chunk::FB::NEXT = next;
    put neigh.Chunk::FB::NEXT = head;

    put Chunk::FreePtr().0 = neigh;
}
fn Chunk::VoidOFF(ptr)
{
    put head = ptr : (0 - Chunk::FB);
    put neigh = Chunk::FreePtr().0;

    lab find_neighbor_loop;
        // block has been found on bounds enter.
        jump found ~ (neigh < head) & (head < (neigh.Chunk::FB::NEXT));

        // special check for physical free list memory wrap around.
        put last = (neigh < (neigh.Chunk::FB::NEXT)) ^ Bool::TRUE;
        put semibound = (neigh < head) | (head < (neigh.Chunk::FB::NEXT));
        jump found ~ last & semibound;

        put neigh = neigh.Chunk::FB::NEXT;
        jump find_neighbor_loop;
    lab found;


    put next = neigh.Chunk::FB::NEXT;
    jump no_forward_coalesce;
    jump no_forward_coalesce ~ Chunk::Local::After(head) != (neigh.Chunk::FB::NEXT);
        put head.Chunk::FB::UNITS = (head.Chunk::FB::UNITS) + (next.Chunk::FB::UNITS);
        put next = next.Chunk::FB::NEXT;
    lab no_forward_coalesce;
    put head.Chunk::FB::NEXT = next;

    jump no_backward_coalesce;
    jump no_backward_coalesce ~ Chunk::Local::After(neigh) != head;
        put neigh.Chunk::FB::UNITS = (neigh.Chunk::FB::UNITS) + (head.Chunk::FB::UNITS);
        put head = head.Chunk::FB::NEXT;
    lab no_backward_coalesce;
    put neigh.Chunk::FB::NEXT = head;

    put Chunk::FreePtr().0 = neigh;
}

fn Chunk::Size(ptr)
{
    put head = ptr : (0 - Chunk::FB);
    return head.Chunk::FB::SIZE;
}

fn Chunk::Copy(ptr)
{
    put size = Chunk::Size(ptr);

    put new = Chunk::New(size);
    Mem::Cpy(new, ptr, size);

    return new;
}
