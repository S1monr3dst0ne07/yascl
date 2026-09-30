

// resources for further reading:
// - register decoder: https://intel.github.io/SDM/definition/Read_GPR.html


use "src/tmpl.yap"


seq IR::Op
{
    // reference exists to this node. noop.
    // address of node in binary will be written
    // to arg field by assembly pass.
    REF, 

    LOAD_INT,    // mov rax, arg
    LOAD_STRING, // mov rax, "arg"

    PUSH, // push rax

    LOAD_PARAM,  // mov rax, ABI[arg]
    STORE_PARAM, // pop ABI[arg]
    
    LOAD_LOCAL,  // mov rax, [rbp - arg]
    STORE_LOCAL, // mov [rbp - arg], rax

    ENTER,  // arg = local count = frame_count / WORD_SIZE
    LEAVE,  // also returns

    SYSCALL,
}

seq IR::Node
{
    OPCODE,
    ARG,

    // relevant node address
    //  ref            -> defintion address
    //  call / jump    -> patch address
    //  string / const -> literal patch address0
    //  etc ...
    ADDR, 
    
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


fn IR::Push8(ctx, value)
{
    put output = ctx.Ctx::Global::OUTPUT;
    Dyn::Push(output, value & 255);
}
fn IR::PushREXW(ctx)
{
    IR::Push8(ctx, 72); // 0x48
}
fn IR::Push16(ctx, value)
{
    IR::Push8(ctx, value);
    IR::Push8(ctx, value >> 8);
}
fn IR::Push32(ctx, value)
{
    IR::Push8(ctx, value);
    IR::Push8(ctx, value >> 8);
    IR::Push8(ctx, value >> 16);
    IR::Push8(ctx, value >> 24);
}
fn IR::Push64(ctx, value)
{
    put i = 0;
    lab loop;
        IR::Push8(ctx, value);
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


fn IR::PostAsm(ctx, patch_nodes)
{
    put node_i = 0;
    lab loop;
        jump done ~ node_i == Dyn::Size(patch_nodes);
        put node = Dyn::Ptr(patch_nodes).node_i;
        put node_i = node_i + 1;

        put opcode = node.IR::Node::OPCODE; 
        put arg    = node.IR::Node::ARG; 

        jump op_string ~ opcode == IR::Op::LOAD_STRING;
        jump loop;

        lab op_string;
            put base_ptr = IR::Addr(ctx);

            put i = 0;
            lab op_string_loop;
                put char = arg.i;
                put i = i + 1;

                IR::Push8(ctx, char);
            jump op_string_loop ~ char != '\0';
            jump run_patch;

        lab run_patch;
            IR::Patch64(ctx, node.IR::Node::ADDR, base_ptr);

        jump loop;
    lab done;
}

fn IR::Asm(ctx)
{
    // list of nodes to be patched,
    // during post-assemble
    put patch_nodes = Dyn::Create();

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
    jump asm_push  ~ opcode == IR::Op::PUSH;
    jump asm_store_param ~ opcode == IR::Op::STORE_PARAM;
    jump asm_syscall ~ opcode == IR::Op::SYSCALL;
    jump asm_load_string ~ opcode == IR::Op::LOAD_STRING;

    print("Invalid opcode: %d\n", [opcode]);

    jump loop;

lab asm_ref;
    put iter.IR::Node::ADDR = IR::Addr(ctx);
    jump loop;    

lab asm_load_int;
    IR::PushREXW(ctx);
    IR::Push8(ctx, 184); // B8 + 0 (0 -> rax)
    IR::Push64(ctx, arg);
    jump loop;

lab asm_store_local;
    IR::PushREXW(ctx);
    IR::Push8(ctx, 137); // 0x89
    IR::Push8(ctx, 133); // 0x85
    IR::Push32(ctx, (1 << 32) - arg);
    jump loop;

lab asm_enter;
    IR::Push8(ctx, 200); // 0xC8 -> enter
    IR::Push16(ctx, arg); // low byte
    IR::Push8(ctx, 0);   // zero-nested
    jump loop;

lab asm_leave;
    IR::Push8(ctx, 201); // 0xC9 -> leave
    IR::Push8(ctx, 195); // 0xC3 -> near return
    jump loop;

lab asm_push;
    IR::Push8(ctx, 80); // 0x50 -> push rax
    jump loop;

lab asm_store_param;
    jump asm_store_param_rax ~ arg == 0;
    jump asm_store_param_rdi ~ arg == 1;
    jump asm_store_param_rsi ~ arg == 2;
    jump asm_store_param_rdx ~ arg == 3;

    IR::Push8(ctx, 65);
    jump asm_store_param_r10 ~ arg == 4;
    jump asm_store_param_r8 ~ arg  == 5;
    jump asm_store_param_r9 ~ arg  == 6;
    Error::Error("PANIC: INTERNAL ERROR, DO NOT RUN EXECUTABLE");

    lab asm_store_param_rax; IR::Push8(ctx, 88); jump loop;
    lab asm_store_param_rdi; IR::Push8(ctx, 95); jump loop;
    lab asm_store_param_rsi; IR::Push8(ctx, 94); jump loop;
    lab asm_store_param_rdx; IR::Push8(ctx, 90); jump loop;

    lab asm_store_param_r10; IR::Push8(ctx, 90); jump loop;
    lab asm_store_param_r8 ; IR::Push8(ctx, 88); jump loop;
    lab asm_store_param_r9 ; IR::Push8(ctx, 89); jump loop;

lab asm_syscall;
    IR::Push8(ctx, 15);
    IR::Push8(ctx, 5);
    jump loop;

lab asm_load_string;
    IR::PushREXW(ctx);
    IR::Push8(ctx, 184);
    put iter.IR::Node::ADDR = IR::Addr(ctx);
    IR::Push64(ctx, 0);

    Dyn::Push(patch_nodes, iter);
    jump loop;
    


lab done;
    IR::PostAsm(ctx, patch_nodes);
    Dyn::Delete(patch_nodes);
    Tmpl::Finalize(ctx);
}



