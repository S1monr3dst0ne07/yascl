

use "lib/ht.yap"
use "src/ctx.yap"


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
    SUBEXPR,
}


fn Ast::Leaf::Local::MakeLeaf(value, kind)
{
    put node = Chunk::New(Ast::Leaf);
    put node.Ast::Leaf::VALUE = value;
    put node.Ast::Leaf::KIND  = kind;
    return node;
}



fn Ast::Leaf::Parse(stream)
{
    put token = Lex::PopTok(stream);
    put tok_kind = token.Lex::Token::KIND;
    put content  = token.Lex::Token::CONTENT;

    put next = Lex::Peek(stream);


    jump char_lit  ~ tok_kind == Lex::Kind::SINGLE_QUOTE;
    jump string    ~ tok_kind == Lex::Kind::DOUBLE_QUOTE;
    jump sub_expr  ~ Str::Diff(content, "(") == 0;
    jump array     ~ Str::Diff(content, "[") == 0;
    jump call      ~ Str::Diff(next, "(") == 0;
    jump number    ~ Str::IsNumber(content);
    jump meta;

lab sub_expr;
    put expr = Ast::Expr::Parse(stream);
    Lex::Expect(stream, ")");

    return Ast::Leaf::Local::MakeLeaf(
        expr, Ast::Leaf::Kind::SUBEXPR,
    );

lab array;
    put elems = Dyn::Create();
    
    lab array_loop;
        jump array_done ~ (Lex::Peek(stream).0) == ']';
        Dyn::Push(elems, Ast::Expr::Parse(stream));
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
        Str::Unescape(Str::Copy(content)),
        Ast::Leaf::Kind::STRING,
    );


lab call;
    Lex::Expect(stream, "(");
    put params = Dyn::Create();
    
    lab call_loop;
        put tok = Lex::PeekTok(stream);
        jump call_done ~ (tok.Lex::Token::KIND) == Lex::Kind::PAREN_CLOSE;
        Dyn::Push(params, Ast::Expr::Parse(stream));
        
        jump call_loop ~ (Lex::Peek(stream).0) != ',';
        Lex::Expect(stream, ",");
        jump call_loop;
    lab call_done;

    Lex::Expect(stream, ")");
    put subnode = Chunk::New(Ast::Leaf::Call);
    put subnode.Ast::Leaf::Call::NAME = Str::Copy(content);
    put subnode.Ast::Leaf::Call::PARAMS = params;

    return Ast::Leaf::Local::MakeLeaf(
        subnode, Ast::Leaf::Kind::CALL,
    );

lab number;
    return Ast::Leaf::Local::MakeLeaf(
        Str::ToInt(content), Ast::Leaf::Kind::NUMBER,
    );

lab meta;
    return Ast::Leaf::Local::MakeLeaf(
        Str::Copy(content), Ast::Leaf::Kind::META,
    );
    

}


fn Ast::Leaf::ResolveContainer(container, ctx)
    // assume container : Dyn<Ast::Expr>
{
    put i = 0;
    lab loop;
        jump done ~ i == Dyn::Size(container);
        Ast::Expr::Resolve(Dyn::Ptr(container).i, ctx);
        put i = i + 1;
        jump loop;
    lab done;
}


fn Ast::Leaf::Resolve(node, ctx)
    // this is complicated, because a leaf can both be ...
    //  ... the base case for recursive resolution.
    //  ... another container objects whos fields need to be resolved.
{
    put kind  = node.Ast::Leaf::KIND;
    put value = node.Ast::Leaf::VALUE;

    // recursive resolve
    jump subexpr ~ kind == Ast::Leaf::Kind::SUBEXPR;
    jump call    ~ kind == Ast::Leaf::Kind::CALL;
    jump array   ~ kind == Ast::Leaf::Kind::ARRAY;

    jump done    ~ kind != Ast::Leaf::Kind::META;

    // base resolve
    jump const ~ HT::Has(ctx.Ctx::Global::CONSTS, value);
    jump var;
    
    lab const;
        put node.Ast::Leaf::KIND = Ast::Leaf::Kind::CONST;
        jump done;
    lab var;
        put node.Ast::Leaf::KIND = Ast::Leaf::Kind::VAR;
        jump done;

    lab subexpr;
        Ast::Expr::Resolve(value, ctx);
        jump done;

    lab call;
        put container = value.Ast::Leaf::Call::PARAMS;
        Ast::Leaf::ResolveContainer(container, ctx);
        jump done;

    lab array;
        Ast::Leaf::ResolveContainer(value, ctx);
        jump done;

    lab done;
}


fn Ast::Leaf::Load(node, ctx)
{
    put kind = node.Ast::Leaf::KIND;
    put value = node.Ast::Leaf::VALUE;

    jump load_subexpr   ~ kind == Ast::Leaf::Kind::SUBEXPR;
    jump load_number    ~ kind == Ast::Leaf::Kind::NUMBER;
    jump load_var       ~ kind == Ast::Leaf::Kind::VAR;
    jump load_call      ~ kind == Ast::Leaf::Kind::CALL;
    jump load_const     ~ kind == Ast::Leaf::Kind::CONST;
    jump load_string    ~ kind == Ast::Leaf::Kind::STRING;
    jump load_array     ~ kind == Ast::Leaf::Kind::ARRAY;
    jump load_char      ~ kind == Ast::Leaf::Kind::CHAR;
    Error::PrintError("internal error: meta node while Ast::Leaf::Load");
    jump done;

lab load_char;   
lab load_number;
    Ctx::Emit(ctx, "mov rax, %d", [value]);
    jump done;
lab load_const;
    put const = HT::Get(ctx.Ctx::Global::CONSTS, value);
    Ctx::Emit(ctx, "mov rax, %d", [const]);
    jump done;
lab load_var;
    jump var_not_exist ~ Bool::Not(Ctx::VarExists(ctx, value));
    put addr = Ctx::VarLookup(ctx, value);
    Ctx::Emit(ctx, "mov rax, [rbp - %d]", [addr]);
    jump done;

lab load_subexpr;
    Ast::Expr::Load(value, ctx);
    jump done;

lab load_call;
    put name   = value.Ast::Leaf::Call::NAME;
    put params = value.Ast::Leaf::Call::PARAMS;
    //Ctx::LocalSave(ctx);
    put abi = Config::ABI();

    // push call results
    put i = 0;
    lab push_loop;
        jump push_done ~ i == Dyn::Size(params);
        put param = Dyn::Ptr(params).i;
        put i = i + 1;

        Ast::Expr::Load(param, ctx);
        Ctx::Emit(ctx, "push rax");
        jump push_loop;
    lab push_done;

    // pop into passing regs
    lab pop_loop;
        jump pop_done ~ i == 0;
        put i = i - 1;
        Ctx::Emit(ctx, "pop %s", [abi.i]);
        jump pop_loop;
    lab pop_done;
    
    //actual call
    jump syscall ~ Str::Diff(name, "syscall") == 0;
    Ctx::Emit(ctx, "call %s", [Utils::TranslateFuncName(name)]);
    jump call_done;

    lab syscall;
    Ctx::Emit(ctx, "syscall");
    jump call_done;

    lab call_done;
    //Ctx::LocalRestore(ctx);
    jump done;

lab load_string;
    put label = Ctx::Fresh(ctx);

    HT::Set(
        ctx.Ctx::Global::STRINGS, 
        label, 
        value,
    );
    Ctx::Emit(ctx, "mov rax, %s", [label]);

    Chunk::Void(label);
    jump done;

lab load_array;
    put label = Ctx::Fresh(ctx);

    HT::Set(
        ctx.Ctx::Global::STATICS, 
        label, 
        Dyn::Size(value),
    );

    // load elements of array
    put vaddr = 0;
    lab array_loop;
        jump array_done ~ vaddr == Dyn::Size(value);
        put addr = vaddr * Config::WORD_SIZE;

        put elem = Dyn::Ptr(value).vaddr;
        Ast::Expr::Load(elem, ctx);
        Ctx::Emit(ctx, "mov [%s + %d], rax", [label, addr]);

        put vaddr = vaddr + 1;
        jump array_loop;
    lab array_done;

    // load reference
    Ctx::Emit(ctx, "mov rax, %s", [label]);

    Chunk::Void(label);
    jump done;

lab var_not_exist;
    Error::PrintError("Variable `%s` has not been defined", [value]);

lab done;
}

fn Ast::Leaf::Store(node, ctx)
{
    put kind = node.Ast::Leaf::KIND;
    put value = node.Ast::Leaf::VALUE;
    jump subexpr ~ kind == Ast::Leaf::Kind::SUBEXPR;
    jump not_var ~ kind != Ast::Leaf::Kind::VAR;

    put addr = Ctx::VarLookup(ctx, value);
    Ctx::Emit(ctx, "mov [rbp - %d], rax", [addr]);

    jump done;
lab not_var;
    Error::PrintError("Trying to store into non-variable value");
lab subexpr;
    Ast::Expr::Store(value, ctx);
lab done;
}


fn Ast::Leaf::Collect(node, ctx)
{
    put kind = node.Ast::Leaf::KIND;
    put value = node.Ast::Leaf::VALUE;

    jump not_var ~ kind != Ast::Leaf::Kind::VAR;
        Ctx::VarAlloc(ctx, value);
    lab not_var;
}


