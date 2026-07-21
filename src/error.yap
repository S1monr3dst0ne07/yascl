
use "lib/io.yap"
use "lib/syscall.yap"

fn Error::Error(msg)
{
    IO::OutString(msg);
    syscall(
        SYSCALL::EXIT,
        1,
    );
}


