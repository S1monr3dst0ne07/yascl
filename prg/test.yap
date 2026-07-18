

use "lib/io.yap"



fn main()
{
    put i = 0;
    lab loop;
        put i = i + 1;
        jump call ~ (i & ((1 << 25) - 1)) == 0;
    jump loop;
    lab call;
        IO::OutBinary(i);
    jump loop;

}



