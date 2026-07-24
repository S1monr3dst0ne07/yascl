

use "lib/chunk.yap"

// string hash table implementation.
// https://benhoyt.com/writings/hash-table-in-c/


seq HT::Entry
{
    KEY,   // str, Mem::NULL if slop empty
    VALUE, // ptr,
}


seq HT
{
    ENTRIES, // Array<HT::Entry> 
    CAPACITY,
    LENGTH,
}


seq HT::Config
{
    INITIAL_CAPACITY = 16 // must be non-zero
}


fn HT::Create()
{
    // i am very boldly assuming that the heap is infinite in size.
    // this assumption is fair, consider it's 1 mega qword.
    // *bad mr. evil impression* one million quad words.

    put ht = Chunk::New(HT);
    put ht.HT::LENGTH = 0;
    put ht.HT::CAPACITY = HT::Config::INITIAL_CAPACITY;

    put size = HT::Entry * (ht.HT::CAPACITY);
    put ht.HT::ENTRIES = Chunk::New(size);
    Mem::Set(
        ht.HT::ENTRIES,
        0,
        size,
    );

    return ht;
}


fn HT::Void(ht)
{
    // first void Str::Copy'd keys.
    put i = 0;
    lab loop;
        put entry = (ht.HT::ENTRIES).i;
        Chunk::Void(entry.HT::Entry::KEY);
        put i = i + 1;
    jump loop ~ i < (ht.HT::CAPACITY);

    // then void container and header object.
    Chunk::Void(ht.HT::ENTRIES);
    Chunk::Void(ht);
}


seq HT::FNV
{
    OFFSET  = 14695981039346656037,
    PRIME   = 1099511628211,
}

fn HT::HashKey(key)
{
    put hash = HT::FNV::OFFSET;
    lab loop;
        put char = key.0;
        jump done ~ char == '\0';
        put key = key : 1;

        put hash = hash ^ char;
        put hash = hash * HT::FNV::PRIME;
    jump loop;
    lab done;

    return hash;
}



fn HT::Get(ht, key)
{
    // capacity is always a power of two,
    // hence (capacity-1) is a mask into the container.
    put hash = HT::HashKey(key);
    put index = hash & ((ht.HT::CAPACITY) - 1);


    lab loop;
        put entry = (ht.HT::ENTRIES) : (index * HT::Entry);
        put entry_key = entry.HT::Entry::KEY;

        // end of slot -> entry not found.
        jump not_found ~ entry_key == Mem::NULL;
        
        // if key matches, entry has been found.
        jump found ~ Str::Diff(key, entry_key) == 0;

        // if key doesn't, then move to next entry in slot.
        put index = index + 1;
        
        //wrap around if need be.
        jump wrap_around ~ index == (ht.HT::CAPACITY);

        jump loop;

    lab wrap_around;
        put index = 0;
        jump loop;

lab found;
    return entry.HT::Entry::VALUE;
lab not_found;
    return Mem::NULL;
}



fn HT::Local::Set(entries, capacity, key, value, plength)
{
    put hash = HT::HashKey(key);
    put index = hash & (capacity - 1);


    lab loop;
        put entry = entries : (index * HT::Entry);
        put entry_key = entry.HT::Entry::KEY;

        jump found_empty   ~ entry_key == Mem::NULL;
        jump already_exist ~ Str::Diff(key, entry_key) == 0;

        put index = index + 1;
        jump wrap_around ~ index == capacity;
        jump loop;

    lab wrap_around;
        put index = 0;
        jump loop;


lab already_exist;
    put entry.HT::Entry::VALUE = value;
    jump done;

lab found_empty;
    jump skip_key_copy ~ plength == Mem::NULL;
        put key = Str::Copy(key);
        put plength.0 = (plength.0) + 1;
    lab skip_key_copy;

    put entry.HT::Entry::KEY   = key;
    put entry.HT::Entry::VALUE = value;
    jump done;

lab done;
}



fn HT::Expand(ht)
{
    put new_capacity = (ht.HT::CAPACITY) * 2;
    put new_size = HT::Entry * new_capacity;
    put new_entires = Chunk::New(new_size);

    put index = 0;
    lab loop;
        jump done ~ index == (ht.HT::CAPACITY);

        put entry = (ht.HT::ENTRIES) : (index * HT::Entry);
        jump skip_set ~ (entry.HT::Entry::KEY) == Mem::NULL;

        // copy into new entry chunk
        HT::Local::Set(
            new_entires, 
            new_capacity, 
            entry.HT::Entry::KEY,
            entry.HT::Entry::VALUE,
            Mem::NULL,
        );

        lab skip_set;
        put index = index + 1;
    jump loop;
    lab done;

    Chunk::Void(ht.HT::ENTRIES);
    put ht.HT::ENTRIES = new_entires;
    put ht.HT::CAPACITY = new_capacity;
}


fn HT::Set(ht, key, value)
{
    jump skip_expand ~ (ht.HT::LENGTH) < ((ht.HT::CAPACITY) / 2);
        HT::Expand(ht);
    lab skip_expand;

    HT::Local::Set(
        ht.HT::ENTRIES,
        ht.HT::CAPACITY,
        key, value,
        ht : HT::LENGTH,
    );
}




seq HT::Iter
{
    KEY,
    VALUE,
    _TABLE,
    _INDEX,
    _COUNT,
}


fn HT::MakeIter(ht)
{
    return [
        Mem::NULL,
        Mem::NULL,
        ht,
        0,
        ht.HT::LENGTH,
    ];
}

fn HT::Next(it)
{
    put ht = it.HT::Iter::_TABLE;

    put count = it.HT::Iter::_COUNT;
    jump empty ~ count == 0;
    put it.HT::Iter::_COUNT = count - 1;

    lab loop;
        put i = it.HT::Iter::_INDEX;
        put it.HT::Iter::_INDEX = i + 1;

        put entry = (ht.HT::ENTRIES):(i * HT::Entry);
        jump again ~ (entry.HT::Entry::KEY) == Mem::NULL;

        put it.HT::Iter::KEY   = entry.HT::Entry::KEY;
        put it.HT::Iter::VALUE = entry.HT::Entry::VALUE;
        return Bool::TRUE;

        lab again;
    jump loop ~ (it.HT::Iter::_INDEX) < (ht.HT::CAPACITY);

lab empty;
    return Bool::FALSE;
}



