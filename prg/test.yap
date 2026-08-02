

use "lib/time.yap"
use "lib/debug.yap"


fn main()
{
    lab loop;
        print("loop\n");
        Time::Nap(500);
    jump loop;
}



