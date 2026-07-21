
use "lib/io.yap"
use "lib/syscall.yap"
use "src/lex.yap"

fn Error::Error(msg)
{
    IO::OutString(msg);
    syscall(
        SYSCALL::EXIT,
        1,
    );
}

fn Error::TokenError(token, pattern, args)
{
    static 16384 ~ buffer1;
    static 16384 ~ buffer2;
    Str::Format(buffer1, pattern, args);
    Str::Format(buffer2, "Error in `%s` at `%d`: %s", [
        token.Lex::Token::PATH,
        token.Lex::Token::LINENO,
        buffer1,
    ]);

    Error::Error(buffer2);
}



