

use "lib/dyn.yap"
use "lib/debug.yap"


fn main()
{
    put list = Dyn::Create();

    Dyn::Push(list, "this");
    Dyn::Push(list, "should");
    Dyn::Push(list, "now");
    Dyn::Push(list, "work");
    Dyn::Push(list, "like");
    Dyn::Push(list, "a");
    Dyn::Push(list, "stack");

    lab loop;
        put elem = Dyn::Pop(list);
        jump done ~ elem == Mem::NULL;

        print("%s\n", [elem]);
    
        jump loop;
    lab done;
        


}



