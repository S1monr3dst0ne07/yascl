

use "lib/mem.yap"


fn Str::Len(str)
{
    put len = 0;
    lab loop;
        put len = len + 1;
    jump loop ~ str.len;
    return len;
}


fn Str::FromIntBase(numb, base)
{
    static 256 ~ buffer;
    put i = 255;

    // put terminator
    put buffer.i = 0;

    lab loop;
        put i = i - 1;
        put buffer.i = (numb % base) + ("0".0);
        put numb = numb / base;
    jump loop ~ numb;

    return buffer : i;
}

fn Str::ToBytes(bstr, qstr)
{
    Mem::ToBytes(
        bstr, 
        qstr,
        Str::Len(qstr),
    );
}


fn Str::Diff(alpha, omega)
{
    put i = 0;
    lab loop;
        jump done ~ (alpha.i) != (omega.i);
        jump done ~ (alpha.i) == 0;

        put i = i + 1;
        jump loop;
    lab done;

    return ((alpha.i) - (omega.i));
}



fn Str::Format(buffer, pattern, args)
{
    lab loop;
        put char = pattern.0; put pattern = pattern : 1;

        jump done    ~ char == 0;
        jump special ~ char == '%';

        put buffer.0 = char;
        put buffer = buffer : 1;
        jump loop;

    lab special;
        put char = pattern.0; put pattern = pattern : 1;

        jump digits ~ char == 'd';
        jump binary ~ char == 'b';
        jump string ~ char == 's';
        jump loop;

    lab digits;
        put subbuffer = Str::FromIntBase(args.0, 10);
        put args = args : 1;
        jump handle_subbuffer;

    lab binary;
        put subbuffer = Str::FromIntBase(args.0, 2);
        put args = args : 1;
        jump handle_subbuffer;

    lab string;
        put subbuffer = args.0;
        put args = args : 1;
        jump handle_subbuffer;


    lab handle_subbuffer;
        put len = Str::Len(subbuffer);
        Mem::Cpy(buffer, subbuffer, len);
        put buffer = buffer : len;

        jump loop;


    lab done;
        put buffer.0 = 0;
}


