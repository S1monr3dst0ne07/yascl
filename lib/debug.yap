

// debug functions don't have their own namespace.
// they should only be used during debugging because of this.

use "lib/str.yap"
use "lib/io.yap"

fn print(pattern, args)
{
    static 16384 ~ buffer;
    Str::Format(buffer, pattern, args);
    IO::OutString(buffer);
}




fn dump(limit)
{
    print("--- heap dump start ---");
    print("__heap_base=%d\n", [__heap_base]);

    put i = 0;
    lab loop;
        print("%d=%d\n", [i, __heap_base.i]);

        put i = i + 1;
    jump loop ~ i < limit;
    
}


