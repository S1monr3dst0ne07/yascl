



fn Utils::TranslateFuncName(token_content)
    // tokens are only read once.
    // translation can happen in-place.
{
    put i = 0;
    lab loop;
        put char = token_content.i;
        jump done ~ char == '\0';

        // convert double-colon to underscore.
        // fasm syntax does not allow double-colon
        // in label names.
        jump skip_trans ~ char != ':';
            put char = '_';
        lab skip_trans;

        put token_content.i = char;
        put i = i + 1;
        jump loop;
    lab done;

    return token_content;
}


