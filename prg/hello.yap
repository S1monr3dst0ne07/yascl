


seq Syscall
{
    READ,
    WRITE,
}

fn outchar(char)
{
    put buffer = " ";
    put buffer.0 = char;

    syscall(Syscall::WRITE, 0, buffer, 1);
}


fn print(str)
{
    put i = 0;
    lab loop;
        put char = str.i;
        put i = i + 1;
        outchar(char);
    jump loop ~ char != 0;
}



fn main()
{
    print("hello world\n");
}




