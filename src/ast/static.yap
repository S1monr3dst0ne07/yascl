
use "lib/chunk.yap"


seq Ast::Static
{
    WORDS, // Int
    EXPR,  // Ast::Expr
}



fn Ast::Static::Parse(stream, ctx)
{
    put node = Chunk::New(Ast::Static);
    Lex::Expect(stream, "static");
    put node.Ast::Static::WORDS = Str::ToInt(Lex::Pop(stream));
    Lex::Expect(stream, "~");
    put node.Ast::Static::EXPR = Ast::Expr::Parse(stream, ctx);
    Lex::Expect(stream, ";");
    return node;
}

