

use "lib/chunk.yap"
use "lib/dyn.yap"

use "src/ast/put.yap"
use "src/ast/return.yap"
use "src/ast/lab.yap"
use "src/ast/jump.yap"
use "src/ast/static.yap"

seq Ast::Block
{
    NODES, // Dyn<Ast::Block::Node>
}

seq Ast::Block::Node
{
    MESA, // Ptr
    KIND, // Ast::Block::Kind
}

seq Ast::Block::Kind
{
    PUT,
    RETURN,
    LAB,
    JUMP,
    STATIC,
    INPLACE,
}

fn Ast::Block::Local::MakeNode(mesa, kind)
{
    put node = Chunk::New(Ast::Block::Node);
    put node.Ast::Block::Node::MESA = mesa;
    put node.Ast::Block::Node::KIND = kind;
    return node;
}


fn Ast::Block::ParseNode(stream, ctx)
{
    put token_prefix = Lex::PeekTok(stream);
    put prefix = token_prefix.Lex::Token::CONTENT;

    jump kind_put    ~ Str::Diff(prefix, "put") == 0;
    jump kind_return ~ Str::Diff(prefix, "return") == 0;
    jump kind_lab    ~ Str::Diff(prefix, "lab") == 0;
    jump kind_jump   ~ Str::Diff(prefix, "jump") == 0;
    jump kind_static ~ Str::Diff(prefix, "static") == 0;
    jump kind_inplace;


    lab kind_put; return Ast::Block::Local::MakeNode(
        Ast::Put::Parse(stream, ctx), 
        Ast::Block::Kind::PUT
    );

    lab kind_return; return Ast::Block::Local::MakeNode(
        Ast::Return::Parse(stream, ctx), 
        Ast::Block::Kind::RETURN
    );

    lab kind_lab; return Ast::Block::Local::MakeNode(
        Ast::Lab::Parse(stream, ctx), 
        Ast::Block::Kind::LAB
    );

    lab kind_jump; return Ast::Block::Local::MakeNode(
        Ast::Jump::Parse(stream, ctx), 
        Ast::Block::Kind::JUMP
    );

    lab kind_static; return Ast::Block::Local::MakeNode(
        Ast::Static::Parse(stream, ctx), 
        Ast::Block::Kind::STATIC
    );

    lab kind_inplace; return Ast::Block::Local::MakeNode(
        Ast::Inplace::Parse(stream, ctx), 
        Ast::Block::Kind::INPLACE
    );

}


fn Ast::Block::Parse(stream, ctx)
{
    Lex::Expect(stream, "{");

    put nodes = Dyn::Create();
    lab loop;
        jump done ~ (Lex::Peek(stream).0) == '}';

        Dyn::Push(nodes, Ast::Block::ParseNode(stream, ctx));

        jump loop;
    lab done;
    
    Lex::Expect(stream, "}");

    put meta = Chunk::New(Ast::Block);
    put meta.Ast::Block::NODES = nodes;
    return meta;
}


