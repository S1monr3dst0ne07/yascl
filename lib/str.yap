

use "lib/io.yap"
use "lib/mem.yap"


fn Str::FromIntBase(numb, base)
{
    static 256 ~ buffer;
    put i = 255;
    Mem::Set(buffer, 0, i);

    lab loop;
        put buffer.i = (numb % base) + ("0".0);
        put numb = numb / base;
        put i = i - 1;
    jump loop ~ numb;

    return buffer : (i + 1);
}




