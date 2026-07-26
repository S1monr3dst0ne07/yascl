
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


fn Ast::Inplace::Resolve(node, ctx)
{
    Ast::Expr::Resolve(node.Ast::Inplace::EXPR, ctx);
}


fn Ast::Inplace::Compile(node, ctx)
{
    Ast::Expr::Load(node.Ast::Inplace::EXPR, ctx);
}

