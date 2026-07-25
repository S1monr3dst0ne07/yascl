

use "lib/chunk.yap"



seq Ast::Lab
{
    NAME, // Str
}


fn Ast::Lab::Parse(stream)
{
    put node = Chunk::New(Ast::Lab);
    Lex::Expect(stream, "lab");
    put node.Ast::Lab::NAME = Lex::PopCheck(stream, Lex::Kind::IDEN);
    Lex::Expect(stream, ";");
    return node;
}


