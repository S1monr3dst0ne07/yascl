



fn Mem::Set(buf, value, count)
{
    put i = 0;
    lab loop;
        put buf.i = value;
        put i = i + 1;
    jump loop ~ i < count;
}



fn Mem::Cpy(dst, src, count)
{
    put i = 0;
    lab loop;
        put dst.i = src.i;
        put i = i + 1;
    jump loop ~ i < count;
}




