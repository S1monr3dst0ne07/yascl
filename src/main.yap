

use "lib/debug.yap"
use "lib/chunk.yap"
use "lib/args.yap"
use "lib/bool.yap"

use "src/lex.yap"
use "src/ctx.yap"
use "src/error.yap"
use "src/ast/prog.yap"


seq Options
{
    SOURCE,
    OUTPUT,
    RUN,
}


fn cmdline(argc, argv)
{
    jump no_args ~ argc < 2;
    static Options ~ opt;

    put opt.Options::SOURCE = Args::Read(argv.1);
    put opt.Options::OUTPUT = "/tmp/a.out";
    put opt.Options::RUN    = Bool::TRUE;

    jump have_output_path ~ argc > 2;
    return opt;

lab have_output_path;
    put opt.Options::OUTPUT = Args::Read(argv.2);
    put opt.Options::RUN    = Bool::FALSE;
    return opt;

lab no_args;
    Error::PrintError("No arguments provided.
    Usage: ./compiler <source-path> [<exec-path>]

    If the executable path <exec-path> is not specified,
    the binary will be written to a temporary file `/tmp/a.out`
    and executed after successful compilation.");
}

fn maybe_run(opt)
{
    jump done ~ Bool::Not(opt.Options::RUN);

    print("--- Running ---\n");
    syscall(SYSCALL::EXECVE,
        FS::ConvertPath(opt.Options::OUTPUT),
        Mem::NULL,
        Mem::NULL,
    );

lab done;
}

fn main(argc, argv)
{
    put opt = cmdline(argc, argv);

    put ctx = Ctx::MakeGlobal();

    put root = Ast::Prog::File(opt.Options::SOURCE, ctx);
    Ast::Prog::Resolve(root, ctx);
    
    Ast::Prog::Compile(root, ctx);
    Ctx::LinkGlobal(ctx);
    IR::Asm(ctx);

    print("Compilation successful\n");

    Ctx::Output(ctx, opt.Options::OUTPUT);


    //dump_ht("consts.txt", "%s: %d\n", ctx.Ctx::Global::CONSTS);
    //dump_heap("core");

    maybe_run(opt);
}



