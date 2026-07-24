
use "lib/io.yap"
use "lib/syscall.yap"

fn Error::Error(msg)
{
    IO::OutString(msg);
    syscall(
        SYSCALL::EXIT,
        1,
    );
}


fn Error::PrintError(pattern, args)
{
    static 16384 ~ buffer1;
    static 16384 ~ buffer2;
    Str::Format(buffer1, pattern, args);
    Str::Format(buffer2, "Error: %s\n", [buffer1]);

    Error::Error(buffer2);
}

fn Error::TokenError(token, pattern, args)
{
    static 16384 ~ buffer1;
    static 16384 ~ buffer2;
    Str::Format(buffer1, pattern, args);
    Str::Format(buffer2, "Error in `%s` at line %d: %s\n", [
        token.Lex::Token::PATH,
        token.Lex::Token::LINENO,
        buffer1,
    ]);

    Error::Error(buffer2);
}



