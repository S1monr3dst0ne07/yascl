
use "lib/chunk.yap"


seq Ast::Inplace
{
    EXPR, // Ast::Expr
}


fn Ast::Inplace::Parse(stream, ctx)
{
    put node = Chunk::New(Ast::Inplace);
    put node.Ast::Inplace::EXPR = Ast::Expr::Parse(stream, ctx);
    Lex::Expect(stream, ";");
    return node;
}



