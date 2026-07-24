
use "lib/chunk.yap"


seq Ast::Inplace
{
    EXPR, // Ast::Expr
}


fn Ast::Inplace::Parse(stream)
{
    put node = Chunk::New(Ast::Inplace);
    put node.Ast::Inplace::EXPR = Ast::Expr::Parse(stream);
    Lex::Expect(stream, ";");
    return node;
}



