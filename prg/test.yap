

use "lib/str.yap"


fn main()
{

    static 256 ~ buffer;

    put i = 0;
    lab loop;
        Str::Format(buffer, "counting: %d\n", [i]);
        IO::OutString(buffer);
        put i = i + 1;
    jump loop;

}



