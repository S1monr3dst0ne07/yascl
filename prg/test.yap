

use "lib/dyn.yap"
use "lib/debug.yap"


fn main()
{
    put list = Dyn::Create();

    Dyn::Insert(list, 0, "test");
    Dyn::Insert(list, 0, "another test");
    Dyn::Insert(list, 2, "test end");

    put i = 0;
    lab loop;
        print("%d : %s\n", [i, Dyn::Ptr(list).i]);
    
        put i = i + 1;
    jump loop ~ i < (list.Dyn::SIZE);
        


}



