




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


    jump char_lit  ~ tok_kind == Lex::Kind::SINGLE_QUOTE;
    jump string    ~ tok_kind == Lex::Kind::DOUBLE_QUOTE;
    jump sub_expr  ~ Str::Diff(content, "(") == 0;
    jump array     ~ Str::Diff(content, "[") == 0;
    jump heap_base ~ Str::Diff(content, "__heap_base") == 0;
    jump call      ~ Str::Diff(next, "(") == 0;
    jump number    ~ Str::IsNumber(content);
    jump meta;

lab sub_expr;
    put expr = Ast::Expr::Parse(stream, ctx);
    Lex::Expect(stream, ")");
    return expr;

lab array;
    put elems = Dyn::Create();
    
    lab array_loop;
        jump array_done ~ (Lex::Peek(stream).0) == ']';
        Dyn::Push(elems, Ast::Expr::Parse(stream, ctx));
        jump array_loop ~ (Lex::Peek(stream).0) != ',';
        Lex::Expect(stream, ",");
        jump array_loop;
    lab array_done;
    Lex::Expect(stream, "]");

    return Ast::Leaf::Local::MakeLeaf(
        elems, Ast::Leaf::Kind::ARRAY,
    );


lab char_lit;
    return Ast::Leaf::Local::MakeLeaf(
        Str::Unescape(content).0, 
        Ast::Leaf::Kind::CHAR,
    );


lab string;
    return Ast::Leaf::Local::MakeLeaf(
        Str::Unescape(content),
        Ast::Leaf::Kind::STRING,
    );

lab heap_base;
    return Ast::Leaf::Local::MakeLeaf(
        Mem::NULL, Ast::Leaf::Kind::HEAP_BASE,
    );

lab call;
    Lex::Expect(stream, "(");
    put params = Dyn::Create();
    
    lab call_loop;
        jump call_done ~ (Lex::Peek(stream).0) == ')';
        Dyn::Push(params, Ast::Expr::Parse(stream, ctx));
        
        jump call_loop ~ (Lex::Peek(stream).0) != ',';
        Lex::Expect(stream, ",");
        jump call_loop;
    lab call_done;

    Lex::Expect(stream, ")");
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


