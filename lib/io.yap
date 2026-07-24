

use "lib/syscall.yap"


fn IO::OutChar(char)
{
    put buffer = " ";
    put buffer.0 = char;

    syscall(SYSCALL::WRITE, 1, buffer, 1);
}

fn IO::OutString(str)
{
    put i = 0;
    lab loop;
        put char = str.i;
        put i = i + 1;
        IO::OutChar(char);
    jump loop ~ char;
}




