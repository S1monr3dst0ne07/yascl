

use "lib/chunk.yap"
use "lib/dyn.yap"

use "src/ast/expr.yap"


seq Ast::Put
{
    DST, // Ast::Expr
    SRC, // Ast::Expr
}


fn Ast::Put::Parse(stream)
{
    put node = Chunk::New(Ast::Put);
    Lex::Expect(stream, "put");
    put node.Ast::Put::DST = Ast::Expr::Parse(stream);
    Lex::Expect(stream, "=");
    put node.Ast::Put::SRC = Ast::Expr::Parse(stream);
    Lex::Expect(stream, ";");
    return node;
}



fn Ast::Put::Resolve(node, ctx)
{
    Ast::Expr::Resolve(node.Ast::Put::DST, ctx);
    Ast::Expr::Resolve(node.Ast::Put::SRC, ctx);
}


fn Ast::Put::Compile(node, ctx)
{
    Ast::Expr::Load (node.Ast::Put::SRC, ctx);
    //Ast::Expr::Store(node.Ast::Put::DST, ctx);
}

