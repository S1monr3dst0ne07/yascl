




seq Ast::Leaf
{
    VALUE, // Void
    KIND,  // Ast::Leaf::Kind
}

seq Ast::Leaf::Call
{
    NAME,   // Str
    PARAMS, // Dyn<Ast::Expr>
}

seq Ast::Leaf::Kind
{
    NUMBER,
    VAR,
    CALL,
    CONST,
    META,
    STRING,
    ARRAY,
    CHAR,
    HEAP_BASE,
}


fn Ast::Leaf::Local::MakeLeaf(value, kind)
{
    put node = Chunk::New(Ast::Leaf);
    put node.Ast::Leaf::VALUE = value;
    put node.Ast::Leaf::KIND  = kind;
    return node;
}



fn Ast::Leaf::Parse(stream, ctx)
{
    put token = Lex::PopTok(stream);
    put tok_kind = token.Lex::Token::KIND;
    put content  = token.Lex::Token::CONTENT;

    put next = Lex::Peek(stream);

    jump sub_expr  ~ Str::Diff(content, "(");
    jump array     ~ Str::Diff(content, "[");
    jump char_lit  ~ tok_kind == Lex::Kind::SINGLE_QUOTE;
    jump string    ~ tok_kind == Lex::Kind::DOUBLE_QUOTE;
    jump heap_base ~ Str::Diff(content, "__heap_base");
    jump call      ~ Str::Diff(next, "(");
    jump number    ~ Str::IsNumber(content);
    jump meta;

lab sub_expr;
    put expr = Ast::Expr::Parse(stream, ctx);
    Lex::Expect(")");
    return expr;

lab array;
    print("!!! TODO !!! implement array literal parser.");

lab char_lit;
    print("!!! TODO !!! implement char  literal parser.");

lab string;
    print("!!! TODO !!! implement string literal parser.");

lab heap_base;
    print("!!! TODO !!! implement heap base.");

lab call;
    Lex::Expect("(");
    put params = Dyn::Create();
    
    lab loop;
        jump done ~ (Lex::Peek(stream).0) == ')';
        Dyn::Push(params, Ast::Expr::Parse(stream, ctx));
        
        jump loop ~ (Lex::Peek(stream).0) != ',';
        Lex::Expect(",");
        jump loop;
    lab done;

    Lex::Expect(")");
    put subnode = Chunk::New(Ast::Leaf::Call);
    put subnode.Ast::Leaf::Call::NAME = content;
    put subnode.Ast::Leaf::Call::PARAMS = params;

    return Ast::Leaf::Local::MakeLeaf(
        subnode, Ast::Leaf::Kind::CALL,
    );

lab number;
    return Ast::Leaf::Local::MakeLeaf(
        content, Ast::Leaf::Kind::NUMBER,
    );

lab meta;
    return Ast::Leaf::Local::MakeLeaf(
        Mem::NULL, Ast::Leaf::Kind::META,
    );
    

}


