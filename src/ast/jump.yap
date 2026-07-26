

use "lib/chunk.yap"
use "lib/mem.yap"


seq Ast::Jump
{
    TARGET, // Str
    COND,   // AstExpr | Mem::NULL
}


fn Ast::Jump::Parse(stream)
{
    put node = Chunk::New(Ast::Jump);
    Lex::Expect(stream, "jump");
    put node.Ast::Jump::TARGET = Str::Copy(Lex::PopCheck(stream, Lex::Kind::IDEN));
    put node.Ast::Jump::COND = Mem::NULL;

    jump skip_cond ~ (Lex::Peek(stream).0) != '~';
        Lex::Expect(stream, "~");
        put node.Ast::Jump::COND = Ast::Expr::Parse(stream);
    lab skip_cond;

    Lex::Expect(stream, ";");
    return node; 
}


fn Ast::Jump::Resolve(node, ctx)
{
    put cond = node.Ast::Jump::COND;
    jump done ~ cond == Mem::NULL;
        Ast::Expr::Resolve(cond, ctx);
    lab done;
}


fn Ast::Jump::Compile(node, ctx)
{
    put label = Ctx::RenderLabel(ctx, node.Ast::Jump::TARGET);

    put cond = node.Ast::Jump::COND;
    jump always ~ cond == Mem::NULL;
    jump sometimes;

lab always;
    Ctx::Emit(ctx, "jmp %s", [label]);
    jump done;

lab sometimes;
    Ast::Expr::Load(cond, ctx);
    Ctx::Emit(ctx, "cmp rax, 0");
    Ctx::Emit(ctx, "jne %s", [label]);
    jump done;

lab done;
    Chunk::Void(label);
}
