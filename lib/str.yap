

use "lib/io.yap"
use "lib/mem.yap"


fn Str::Len(str)
{
    put len = 0;
    lab loop;
        put len = len + 1;
    jump loop ~ str.len;
    return len;
}


fn Str::FromIntBase(numb, base)
{
    static 256 ~ buffer;
    put i = 255;

    // put terminator
    put buffer.i = 0;

    lab loop;
        put i = i - 1;
        put buffer.i = (numb % base) + ("0".0);
        put numb = numb / base;
    jump loop ~ numb;

    return buffer : i;
}


