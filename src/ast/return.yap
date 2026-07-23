
use "lib/chunk.yap"


seq Ast::Return
{
    VALUE, // AstExpr
}


fn Ast::Return::Parse(stream, ctx)
{
    put node = Chunk::New(Ast::Return);
    Lex::Expect(stream, "return");
    put node.Ast::Return::VALUE = Ast::Expr::Parse(stream, ctx);
    Lex::Expect(stream, ";");
    return node;
}



