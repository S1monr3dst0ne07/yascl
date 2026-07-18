

use "lib/debug.yap"


fn main()
{

    static 256 ~ buffer;

    put mode = "SILLY";

    put i = 0;
    lab loop;
        print("counting: %d, mode: %s\n", [i, mode]);
        put i = i + 1;
    jump loop;

}



