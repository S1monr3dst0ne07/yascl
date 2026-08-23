

use "lib/dyn.yap"

use "src/utils.yap"
use "src/config.yap"
use "src/ast/block.yap"



seq Ast::FnDef
{
    NAME,   // Str
    PARAMS, // Dyn<Str>
    BODY,   // Ast::Block
}






fn Ast::FnDef::Parse(stream)
{
    put node = Chunk::New(Ast::FnDef);
    
    Lex::Expect(stream, "fn");
    put node.Ast::FnDef::NAME = Utils::TranslateFuncName(
        Str::Copy(Lex::PopCheck(stream, Lex::Kind::IDEN)),
    );
    Lex::Expect(stream, "(");


    put params = Dyn::Create();
    lab loop;
        jump done ~ (Lex::Peek(stream).0) == ')';
        Dyn::Push(params, Str::Copy(Lex::PopCheck(stream, Lex::Kind::IDEN)));

        jump loop ~ (Lex::Peek(stream).0) != ',';

        Lex::Pop(stream);
        jump loop;

    lab done;
    put node.Ast::FnDef::PARAMS = params;
        
    
    Lex::Expect(stream, ")");
    put node.Ast::FnDef::BODY = Ast::Block::Parse(stream);

    return node;
}


fn Ast::FnDef::Resolve(node, ctx)
{
    Ast::Block::Resolve(
        node . Ast::FnDef::BODY,
        ctx,
    );
}

fn Ast::FnDef::Compile(node, ctx)
{
    put local_super_ctx = ctx.Ctx::Global::LOCAL;
    put local_ctx = Ctx::MakeLocal(node.Ast::FnDef::NAME);
    put ctx.Ctx::Global::LOCAL = local_ctx;

    // collect local variables and prepare stack frame
    Ast::FnDef::Collect(node, ctx);
    put local_count = (local_ctx.Ctx::Local::VARS).HT::LENGTH;
    put frame_size = local_count * Config::WORD_SIZE;

    // function entry point
    Ctx::Emit(ctx, "%s:", [node.Ast::FnDef::NAME]);
    Ctx::Emit(ctx, "enter %d,0", [frame_size]);

    // populate parameter variables.
    put abi = Config::ABI();
    put params = node.Ast::FnDef::PARAMS;
    put i = 0;
    lab loop;
        jump done ~ i == Dyn::Size(params);

        put param_name = Dyn::Ptr(params).i;
        put passing_reg = abi.i;
        put param_addr = Ctx::VarLookup(ctx, param_name);
        Ctx::Emit(ctx, "mov [rbp - %d], %s", [param_addr, passing_reg]);
        
        put i = i + 1;
        jump loop;
    lab done;
        
    // body
    Ast::Block::Compile(node.Ast::FnDef::BODY, ctx);

    // function exit
    Ctx::Emit(ctx, "leave");
    Ctx::Emit(ctx, "xor rax, rax"); // return 0 by default
    Ctx::Emit(ctx, "ret");

    // void subctx, restore superctx
    Ctx::VoidLocal(local_ctx);
    put ctx.Ctx::Global::LOCAL = local_super_ctx;
}



fn Ast::FnDef::Collect(node, ctx)
{
    put params = node.Ast::FnDef::PARAMS;
    
    // collection local variable from
    // function parameters.
    put i = 0;
    lab loop;
        jump done ~ i == Dyn::Size(params);

        put param_name = Dyn::Ptr(params).i;
        Ctx::VarAlloc(ctx, param_name);
        
        put i = i + 1;
        jump loop;
    lab done;

    put body = node.Ast::FnDef::BODY;
    Ast::Block::Collect(body, ctx);
}


