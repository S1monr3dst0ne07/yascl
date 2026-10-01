

// μPrint
// zero-dependency string printing.
// super slow, use at own risk!

fn Uprint::PutChar(char)
{
    put buffer = " ";
    put buffer.0 = char;

    syscall(SYSCALL::WRITE, 1, buffer, 1);
}

fn Uprint::Print(str)
{
    put i = 0;
    lab loop;
        put char = str.i;
        jump done ~ char == '\0';

        put i = i + 1;
        Uprint::PutChar(char);

        jump loop;
    lab done;
}




