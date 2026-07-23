

use "lib/chunk.yap"
use "lib/dyn.yap"

use "src/ast/expr.yap"


seq Ast::Put
{
    DST, // Ast::Expr
    SRC, // Ast::Expr
}


fn Ast::Put::Parse(stream, ctx)
{
    put node = Chunk::New(Ast::Put);
    Lex::Expect(stream, "put");
    put node.Ast::Put::DST = Ast::Expr::Parse(stream, ctx);
    Lex::Expect(stream, "=");
    put node.Ast::Put::SRC = Ast::Expr::Parse(stream, ctx);
    Lex::Expect(stream, ";");
    return node;
}







