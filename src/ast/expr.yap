
use "src/ast/leaf.yap"


seq Ast::Expr::Op
{
    NONE,
    ADD,
    SUB,
    DOT,
    DOUBLE_DOT,
    EQUAL
    NOT_EQUAL,
    LESSER,
    GREATER,
    MUL,
    DIV,
    AND,
    OR,
    XOR,
    SHIFT_RIGHT,
    SHIFT_LEFT,
    MODULO,
}


seq Ast::Expr
{
    LEFT,  // AstExpr | AstLeaf
    RIGHT, // AstExpr | AstLeaf
    OP,    // Ast::Expr::Op
}


fn Ast::Expr::OpDecode(op)
{
	jump skip_ADD 	        ~ Str::Diff(op, "+");  return Ast::Expr::Op::ADD;           lab skip_ADD;
	jump skip_SUB 	        ~ Str::Diff(op, "-");  return Ast::Expr::Op::SUB;           lab skip_SUB;
	jump skip_DOT 	        ~ Str::Diff(op, ".");  return Ast::Expr::Op::DOT;           lab skip_DOT;
	jump skip_DOUBLE_DOT 	~ Str::Diff(op, ":");  return Ast::Expr::Op::DOUBLE_DOT;    lab skip_DOUBLE_DOT;
	jump skip_EQUAL 	    ~ Str::Diff(op, "=="); return Ast::Expr::Op::EQUAL;         lab skip_EQUAL;
	jump skip_NOT_EQUAL 	~ Str::Diff(op, "!="); return Ast::Expr::Op::NOT_EQUAL;     lab skip_NOT_EQUAL;
	jump skip_LESSER 	    ~ Str::Diff(op, "<");  return Ast::Expr::Op::LESSER;        lab skip_LESSER;
	jump skip_GREATER 	    ~ Str::Diff(op, ">");  return Ast::Expr::Op::GREATER;       lab skip_GREATER;
	jump skip_MUL 	        ~ Str::Diff(op, "*");  return Ast::Expr::Op::MUL;           lab skip_MUL;
	jump skip_DIV 	        ~ Str::Diff(op, "/");  return Ast::Expr::Op::DIV;           lab skip_DIV;
	jump skip_AND 	        ~ Str::Diff(op, "&");  return Ast::Expr::Op::AND;           lab skip_AND;
	jump skip_OR 	        ~ Str::Diff(op, "|");  return Ast::Expr::Op::OR;            lab skip_OR;
	jump skip_XOR 	        ~ Str::Diff(op, "^");  return Ast::Expr::Op::XOR;           lab skip_XOR;
	jump skip_SHIFT_RIGHT 	~ Str::Diff(op, ">>"); return Ast::Expr::Op::SHIFT_RIGHT;   lab skip_SHIFT_RIGHT;
	jump skip_SHIFT_LEFT 	~ Str::Diff(op, "<<"); return Ast::Expr::Op::SHIFT_LEFT;    lab skip_SHIFT_LEFT;
	jump skip_MODULO 	    ~ Str::Diff(op, "%");  return Ast::Expr::Op::MODULO;        lab skip_MODULO;

    return Ast::Expr::Op::NONE;
}


fn Ast::Expr::Parse(stream)
{
    put left = Ast::Leaf::Parse(stream);
    put right = Mem::NULL;
    put op = Ast::Expr::OpDecode(Lex::Peek(stream));

    jump skip_right ~ op == Ast::Expr::Op::NONE;
        Lex::Pop(stream);
        put right = Ast::Expr::Parse(stream);
    lab skip_right;

    put node = Chunk::New(Ast::Expr);
    put node.Ast::Expr::LEFT  = left;
    put node.Ast::Expr::RIGHT = right;
    put node.Ast::Expr::OP    = op;
    return node;
}


fn Ast::Expr::Resolve(node, ctx)
{
    Ast::Leaf::Resolve(node.Ast::Expr::LEFT, ctx);
    
    jump skip_right ~ (node.Ast::Expr::OP) == Ast::Expr::Op::NONE;
        Ast::Expr::Resolve(node.Ast::Expr::RIGHT, ctx);
    lab skip_right;
}



fn Ast::Expr::Load(node, ctx)
{
    jump only_leaf ~ (node.Ast::Expr::OP) == Ast::Expr::Op::NONE;

    Ast::Expr::Load(node.Ast::Expr::RIGHT, ctx);
    Ctx::Emit(ctx, "push rax");
    Ast::Leaf::Load(node.Ast::Expr::LEFT, ctx);
    Ctx::Emit(ctx, "pop rbx");

    put op = node.Ast::Expr::OP;
    jump compile_add         ~ op == Ast::Expr::Op::ADD;
    jump compile_sub         ~ op == Ast::Expr::Op::SUB;
    jump compile_dot         ~ op == Ast::Expr::Op::DOT;
    jump compile_double_dot  ~ op == Ast::Expr::Op::DOUBLE_DOT;
    jump compile_equal       ~ op == Ast::Expr::Op::EQUAL;
    jump compile_not_equal   ~ op == Ast::Expr::Op::NOT_EQUAL;
    jump compile_lesser      ~ op == Ast::Expr::Op::LESSER;
    jump compile_greater     ~ op == Ast::Expr::Op::GREATER;
    jump compile_mul         ~ op == Ast::Expr::Op::MUL;
    jump compile_div         ~ op == Ast::Expr::Op::DIV;
    jump compile_and         ~ op == Ast::Expr::Op::AND;
    jump compile_or          ~ op == Ast::Expr::Op::OR;
    jump compile_xor         ~ op == Ast::Expr::Op::XOR;
    jump compile_shift_right ~ op == Ast::Expr::Op::SHIFT_RIGHT;
    jump compile_shift_left  ~ op == Ast::Expr::Op::SHIFT_LEFT;
    jump compile_modulo      ~ op == Ast::Expr::Op::MODULO;


    lab compile_add; Ctx::Emit(ctx, "add rax, rbx"); jump done;
    lab compile_sub; Ctx::Emit(ctx, "sub rax, rbx"); jump done;
    lab compile_dot; Ctx::Emit(ctx, "mov rax, [rax + rbx*%d]", [Config::WORD_SIZE]); jump done;
    lab compile_double_dot;
        Ctx::Emit(ctx, "lea rax, [rax + rbx*%d]", [Config::WORD_SIZE]); 
        jump done;
    lab compile_equal;
        Ctx::Emit(ctx, "cmp rax, rbx");
        Ctx::Emit(ctx, "sete cl");
        Ctx::Emit(ctx, "movzx rax, cl");
        jump done;
    lab compile_not_equal;
        Ctx::Emit(ctx, "cmp rax, rbx");
        Ctx::Emit(ctx, "setne cl");
        Ctx::Emit(ctx, "movzx rax, cl");
        jump done;
    lab compile_lesser;
        Ctx::Emit(ctx, "cmp rax, rbx");
        Ctx::Emit(ctx, "setb cl"); //below
        Ctx::Emit(ctx, "movzx rax, cl");
        jump done;
    lab compile_greater;
        Ctx::Emit(ctx, "cmp rax, rbx");
        Ctx::Emit(ctx, "seta cl"); //above
        Ctx::Emit(ctx, "movzx rax, cl");
        jump done;


    lab compile_mul;
        Ctx::Emit(ctx, "mul rbx"); 
        jump done;
    lab compile_div;
        Ctx::Emit(ctx, "xor rdx, rdx"); 
        Ctx::Emit(ctx, "div rbx"); 
        jump done;
    lab compile_modulo;
        Ctx::Emit(ctx, "xor rdx, rdx"); 
        Ctx::Emit(ctx, "div rbx"); 
        Ctx::Emit(ctx, "mov rax, rdx"); 
        jump done;
    lab compile_and; Ctx::Emit(ctx, "and rax, rbx"); jump done;
    lab compile_or;  Ctx::Emit(ctx, "or  rax, rbx"); jump done;
    lab compile_xor; Ctx::Emit(ctx, "xor rax, rbx"); jump done;
    lab compile_shift_right;
        Ctx::Emit(ctx, "mov rcx, rbx");
        Ctx::Emit(ctx, "shr rax, cl");
        jump done;
    lab compile_shift_left;
        Ctx::Emit(ctx, "mov rcx, rbx");
        Ctx::Emit(ctx, "shl rax, cl");
        jump done;


lab only_leaf;
    Ast::Leaf::Load(node.Ast::Expr::LEFT, ctx);
lab done;
}


fn Ast::Expr::Store(node, ctx)
{
    jump only_leaf ~ (node.Ast::Expr::OP) == Ast::Expr::Op::NONE;
    jump error     ~ (node.Ast::Expr::OP) != Ast::Expr::Op::DOT;

    Ctx::Emit(ctx, "push rax");
    Ast::Expr::Load(node.Ast::Expr::RIGHT, ctx);
    Ctx::Emit(ctx, "push rax");
    Ast::Leaf::Load(node.Ast::Expr::LEFT,  ctx);
    Ctx::Emit(ctx, "pop rbx");
    Ctx::Emit(ctx, "lea rbx, [rbx*%d]", [Config::WORD_SIZE]);
    Ctx::Emit(ctx, "add rax, rbx");

    Ctx::Emit(ctx, "pop rbx");
    Ctx::Emit(ctx, "mov [rax], rbx");

    jump done;

lab error;
    Error::PrintError("Trying to store into non-dot expression.");
lab only_leaf;
    Ast::Leaf::Store(node.Ast::Expr::LEFT, ctx);
lab done;
}

