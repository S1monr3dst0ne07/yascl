

use "lib/mem.yap"


fn Str::Len(str)
{
    put len = 0;
    lab loop;
        put len = len + 1;
    jump loop ~ str.len;
    return len;
}

fn Str::Copy(str)
{
    put len = Str::Len(str)+1;
    put new = Chunk::New(len);
    Mem::Cpy(new, str, len);
    return new;
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

fn Str::ToInt(str)
{
    put numb = 0;
    put i = 0;

    lab loop;
        put char = str.i;
        jump done ~ char == '\0';
        put i = i + 1;

        put numb = (numb * 10) + (char - '0');
        jump loop;
    lab done;

    return numb;
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

fn Str::Unescape(content)
    // in-place unescape string.
    // only supports most common control codes.
{
    put i = 0;
    put offset = 0;

    lab loop;
        put char = content.i;

        jump done    ~ char == '\0';
        jump control ~ char == '\\';

        put content.(i-offset) = char;
        put i = i + 1;
        jump loop;

    lab control;
        put subchar = content.(i+1);

        jump newline    ~ subchar == 'n';
        jump tabulate   ~ subchar == 't';
        jump terminator ~ subchar == '0';
        jump mesa       ~ subchar == '\\';
            //unknown control sequence.
            //ignore backslash.
        jump loop; 

    lab newline     ; put content.(i-offset) = '\n'; jump control_done;
    lab tabulate    ; put content.(i-offset) = '\t'; jump control_done;
    lab terminator  ; put content.(i-offset) = '\0'; jump control_done;
    lab mesa        ; put content.(i-offset) = '\\'; jump control_done;

    lab control_done;
        put offset = offset + 1;
        put i = i + 2;
        jump loop;

    lab done;
        put content.(i-offset) = '\0';
        return content;
}


fn Str::IsDigit(char)
{
    return (('0' - 1) < char) & (('9' + 1) > char);
}

fn Str::IsNumber(str)
{
    put i = 0;
    put flag = Bool::TRUE;

    lab loop;
        put char = str.i;
        jump done ~ char == '\0';
        put flag = flag & Str::IsDigit(char);
        put i = i + 1;
        jump loop;
    lab done;

    return flag;
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
        Mem::CpyF(buffer, subbuffer, len);
        put buffer = buffer : len;

        jump loop;


    lab done;
        put buffer.0 = 0;
}


