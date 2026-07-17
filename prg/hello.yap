


seq Syscall
{
    READ,
    WRITE,
}

fn strlen(str)
{
    put len = 0 - 1;
    lab loop;
        put len = len + 1;
        put char = str.len;
    jump loop ~ char != 0;

    return len;
}


fn print(str)
{
    put words = strlen(str);
    put bytes = words + words + words + words + words + words + words + words;
    syscall(Syscall::WRITE, 0, str, bytes);
}



fn main()
{
    print("hello world\n");
}




