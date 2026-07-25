
use "lib/chunk.yap"


seq Ast::Return
{
    VALUE, // AstExpr
}


fn Ast::Return::Parse(stream)
{
    put node = Chunk::New(Ast::Return);
    Lex::Expect(stream, "return");
    put node.Ast::Return::VALUE = Ast::Expr::Parse(stream);
    Lex::Expect(stream, ";");
    return node;
}


fn Ast::Return::Resolve(node, ctx)
{
    Ast::Expr::Resolve(node.Ast::Return::VALUE, ctx);
}

