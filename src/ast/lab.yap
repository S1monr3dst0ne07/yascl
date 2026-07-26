

use "lib/chunk.yap"



seq Ast::Lab
{
    NAME, // Str
}


fn Ast::Lab::Parse(stream)
{
    put node = Chunk::New(Ast::Lab);
    Lex::Expect(stream, "lab");
    put node.Ast::Lab::NAME = Str::Copy(Lex::PopCheck(stream, Lex::Kind::IDEN));
    Lex::Expect(stream, ";");
    return node;
}


fn Ast::Lab::Compile(node, ctx)
{
    put label = Ctx::RenderLabel(ctx, node.Ast::Lab::NAME);
    Ctx::Emit(ctx, "%s:", [label]);
    Chunk::Void(label);
}


