

use "lib/fs.yap"
use "lib/debug.yap"


fn main()
{
    put src = FS::Read("hello.txt");

    print("file: `%s`\n", [src]);




}



