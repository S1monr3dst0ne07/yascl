

use "lib/dyn.yap"

use "src/utils.yap"
use "src/ast/block.yap"



seq Ast::FnDef
{
    NAME,   // Str
    PARAMS, // Dyn<Str>
    BODY,   // Ast::Block
}






fn Ast::FnDef::Parse(stream, ctx)
{
    put node = Chunk::New(Ast::FnDef);
    
    Lex::Expect(stream, "fn");
    put node.Ast::FnDef::NAME = Utils::TranslateFuncName(
        Lex::PopCheck(stream, Lex::Kind::IDEN),
    );
    Lex::Expect(stream, "(");


    put params = Dyn::Create();
    lab loop;
        jump done ~ Lex::Peek(stream) == ')';
        Dyn::Push(params, Lex::PopCheck(stream, Lex::Kind::IDEN));

        jump comma ~ Lex::Peek(stream) == ',';
        jump loop;

    lab comma;
        Lex::Pop(stream);
        jump loop;

    lab done;
    put node.Ast::FnDef::PARAMS = params;
        
    
    Lex::Expect(stream, ")");
    put node.Ast::FnDef::BODY = Ast::Block::Parse(stream, ctx);

    return node;
}







