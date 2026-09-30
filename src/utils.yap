

fn Utils::Unescape(content)
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
        jump car_return ~ subchar == 'r';
        jump tabulate   ~ subchar == 't';
        jump terminator ~ subchar == '0';
        jump mesa       ~ subchar == '\\';
            //unknown control sequence.
            //ignore backslash.
        jump loop; 

    lab newline     ; put content.(i-offset) = '\n'; jump control_done;
    lab car_return  ; put content.(i-offset) = '\r'; jump control_done;
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
