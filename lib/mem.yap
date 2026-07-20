

seq Mem 
{
    // null pointer contant.
    // mostly semantic.
    NULL 
}


fn Mem::Set(buf, value, count)
{
    put i = 0;
    lab loop;
        put buf.i = value;
        put i = i + 1;
    jump loop ~ i < count;
}


// copy forwards
fn Mem::CpyF(dst, src, count)
{
    put i = 0;
    lab loop; jump done ~ i == count;
        put dst.i = src.i;
        put i = i + 1;
    jump loop; lab done;
}

// copy backwards
fn Mem::CpyB(dst, src, count)
{
    put i = count;
    lab loop; jump done ~ i == 0;
        put i = i - 1;
        put dst.i = src.i;
    jump loop; lab done;
}

// select copy direction
fn Mem::Cpy(dst, src, count)
{
    jump done ~ dst == src;
    jump fore ~ dst < src;
    jump back ~ dst > src;

    lab fore; Mem::CpyF(dst, src, count); jump done;
    lab back; Mem::CpyB(dst, src, count); jump done;

    lab done; 
}




