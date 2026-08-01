

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





