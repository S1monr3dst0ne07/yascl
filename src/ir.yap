

// resources for further reading:
// - register decoder: https://intel.github.io/SDM/definition/Read_GPR.html


use "src/tmpl.yap"


seq IR::Op
{
    // reference exists to this node. noop.
    // address of node in binary will be written
    // to arg field by assembly pass.
    REF, 

    LOAD_INT, // mov rax, arg

    LOAD_PARAM,  // mov rax, ABI[arg]
    
    LOAD_LOCAL,  // mov rax, [rbp - arg]
    STORE_LOCAL, // mov [rbp - arg], rax

    ENTER,  // arg = local count = frame_count / WORD_SIZE
    LEAVE,  // also returns

}

seq IR::Node
{
    OPCODE,
    ARG,
    
    PREV, // IR::Node
    NEXT, // IR::Node
}


fn IR::Emit(ctx, opcode, arg)
{
    put new = Chunk::New(IR::Node);
    put new.IR::Node::OPCODE = opcode;
    put new.IR::Node::ARG    = arg;

    put iter = ctx.Ctx::Global::IR_ITER;

    put iter.IR::Node::NEXT = new;
    put new.IR::Node::PREV = iter;

    put ctx.Ctx::Global::IR_ITER = new;
}

fn IR::Addr(ctx)
{
    put output = ctx.Ctx::Global::OUTPUT;
    return Dyn::Size(output) + Tmpl::Config::LOAD_ADDR;
}


fn IR::Emit8(ctx, value)
{
    put output = ctx.Ctx::Global::OUTPUT;
    Dyn::Push(output, value & 255);
}
fn IR::EmitREXW(ctx)
{
    IR::Emit8(ctx, 72); // 0x48
}
fn IR::Emit16(ctx, value)
{
    IR::Emit8(ctx, value);
    IR::Emit8(ctx, value >> 8);
}
fn IR::Emit32(ctx, value)
{
    IR::Emit8(ctx, value);
    IR::Emit8(ctx, value >> 8);
    IR::Emit8(ctx, value >> 16);
    IR::Emit8(ctx, value >> 32);
}
fn IR::Emit64(ctx, value)
{
    put i = 0;
    lab loop;
        IR::Emit8(ctx, value);
        put value = value >> 8;
        put i = i + 1;
    jump loop ~ i < 8;
}

fn IR::Patch64(ctx, addr, value)
{
    put vaddr = addr - Tmpl::Config::LOAD_ADDR;
    put output = ctx.Ctx::Global::OUTPUT;

    put i = 0;
    lab loop;
        put Dyn::Ptr(output).(vaddr + i) = value & 255;
        put value = value >> 8;
        put i = i + 1;
    jump loop ~ i < 8;
}


fn IR::Asm(ctx)
{
    Tmpl::Header(ctx);
    put iter = ctx.Ctx::Global::IR_ROOT;

lab loop;
    put iter = iter.IR::Node::NEXT;
    jump done ~ iter == Mem::NULL;
    put opcode = iter.IR::Node::OPCODE;
    put arg = iter.IR::Node::ARG;

    jump asm_ref      ~ opcode == IR::Op::REF;
    jump asm_load_int ~ opcode == IR::Op::LOAD_INT;
    jump asm_store_local ~ opcode == IR::Op::STORE_LOCAL;

    jump asm_enter ~ opcode == IR::Op::ENTER;
    jump asm_leave ~ opcode == IR::Op::LEAVE;

    print("Invalid opcode: %d\n", [opcode]);

    jump loop;

lab asm_ref;
    put iter.IR::Node::ARG = IR::Addr(ctx);
    jump loop;    

lab asm_load_int;
    IR::EmitREXW(ctx);
    IR::Emit8(ctx, 184); // B8 + 0 (0 -> rax)
    IR::Emit64(ctx, arg);
    jump loop;

lab asm_store_local;
    IR::EmitREXW(ctx);
    IR::Emit8(ctx, 137); // 0x89
    IR::Emit8(ctx, 133); // 0x85
    IR::Emit32(ctx, (1 << 32) - arg);
    jump loop;

lab asm_enter;
    IR::Emit8(ctx, 200); // 0xC8 -> enter
    IR::Emit16(ctx, arg); // low byte
    IR::Emit8(ctx, 0);   // zero-nested
    jump loop;

lab asm_leave;
    IR::Emit8(ctx, 201); // 0xC9 -> leave
    IR::Emit8(ctx, 195); // 0xC3 -> near return
    jump loop;

lab done;
    Tmpl::Finalize(ctx);
}



