

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
    static 256 ~ buffer;

    put i = 0;
    lab buildLoop;
        put tail = numb / 10;
        put buffer.i = (numb - (tail * 10)) + ("0".0);
        put numb = tail;
        put i = i + 1;
    jump buildLoop ~ numb;


    lab printLoop;
        put i = i - 1;
        IO::OutChar(buffer.i);
    jump printLoop ~ i > 0;

    IO::OutChar("\n".0);
    
}


fn IO::OutBinary(numb)
{
    static 256 ~ buffer;

    put i = 0;
    lab buildLoop;
        put buffer.i = (numb & 1) + ("0".0);
        put numb = numb >> 1;
        put i = i + 1;
    jump buildLoop ~ numb;


    lab printLoop;
        put i = i - 1;
        IO::OutChar(buffer.i);
    jump printLoop ~ i > 0;

    IO::OutChar("\n".0);
}




