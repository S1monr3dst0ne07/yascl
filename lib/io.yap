

use "lib/syscall.yap"


fn IO::OutChar(char)
{
    put buffer = " ";
    put buffer.0 = char;

    syscall(SYSCALL::WRITE, 0, buffer, 1);
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



fn IO::OutNumber(numb)
{
    IO::OutString(Str::FromIntBase(numb, 10));
    IO::OutChar("\n".0);
}


fn IO::OutBinary(numb)
{
    IO::OutString(Str::FromIntBase(numb, 2));
    IO::OutChar("\n".0);
}




