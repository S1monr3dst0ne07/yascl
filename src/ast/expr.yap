
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


fn Ast::Expr::Parse(stream, ctx)
{
    put left = Ast::Leaf::Parse(stream, ctx);
    put right = Mem::NULL;
    put op = Ast::Expr::OpDecode(Lex::Peek(stream));

    jump skip_right ~ op == Ast::Expr::Op::NONE;
        Lex::Pop(stream);
        put right = Ast::Expr::Parse(stream, ctx);
    lab skip_right;

    put node = Chunk::New(Ast::Expr);
    put node.Ast::Expr::LEFT  = left;
    put node.Ast::Expr::RIGHT = right;
    put node.Ast::Expr::OP    = op;
    return node;
}



