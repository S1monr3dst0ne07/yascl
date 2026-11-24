
// this module is responsible for generating
// the elf symbol table needed for debugging.
// the symtab is not required to produce a working
// executable, hence why it's been confined to
// this file. 


seq Section::Stuff
{
	PROGBIT_BASE_PTR,
	STR_TAB_BASE_PTR,
	SYM_TAB_BASE_PTR,

	PROGBIT_END_PTR,
	STR_TAB_END_PTR,
	SYM_TAB_END_PTR,

	SECT_HDR_BASE_PTR, // vaddr pointer to start of section headers
	STR_TAB_MAP,       // map from symbol to offset into string table
}

fn Section::GenStrtabEntry(ctx, stuff, symbol)
{
	put base = stuff.Section::Stuff::STR_TAB_BASE_PTR;
	put map  = stuff.Section::Stuff::STR_TAB_MAP;

	// prevent redundant string entires
	jump done ~ HT::Has(map, symbol);

	// register offset into string table
	put offset = IR::Addr(ctx) - base;
	HT::Set(map, symbol, offset);
	
	// write actual string
	put i = 0;
	lab loop;
		put char = symbol.i;
		put i = i + 1;

		IR::Push8(ctx, char);
	jump loop ~ char;

lab done;
}

fn Section::GenStrTab(ctx, stuff)
{
	// generates the string table
	// with all of the function / label
	// names.

	put stuff.Section::Stuff::STR_TAB_BASE_PTR = IR::Addr(ctx);

	// the elf64 string table starts with an empty string.
	// don't ask me why, it's just like that...
	IR::Push8(ctx, '\0');

	put iter = ctx.Ctx::Global::IR_ROOT;
	lab ir_loop;
		put iter = iter.IR::Node::NEXT;
		jump ir_done ~ iter == Mem::NULL;
		jump ir_loop ~ (iter.IR::Node::OPCODE) != IR::Op::REF;

		put symbol = iter.IR::Node::ARG;
		jump ir_loop ~ symbol == Mem::NULL;

		Section::GenStrtabEntry(ctx, stuff, symbol);

		jump ir_loop;
	lab ir_done;

	// write sections names
	Section::GenStrtabEntry(ctx, stuff, ".strtab");
	Section::GenStrtabEntry(ctx, stuff, ".symtab");
	Section::GenStrtabEntry(ctx, stuff, ".all");

	put stuff.Section::Stuff::STR_TAB_END_PTR = IR::Addr(ctx);
}

fn Section::GenSymTab(ctx, stuff)
{
	put stuff.Section::Stuff::SYM_TAB_BASE_PTR = IR::Addr(ctx);
	put map = stuff.Section::Stuff::STR_TAB_MAP;

	//typedef struct {
	//    uint32_t      st_name ;
	//    uint8_t   	st_info ;
	//    uint8_t 		st_other;
	//    uint16_t      st_shndx;
	//    uintptr_t     st_value;
	//    uint64_t      st_size ;
	//} Elf64_Sym;

	// empty symbol entry for some reason...
	IR::Push32(ctx, 0); // st_name
	IR::Push8 (ctx, 0); // st_info
	IR::Push8 (ctx, 0); // st_other
	IR::Push16(ctx, 0); // st_shndx
	IR::Push64(ctx, 0); // st_value
	IR::Push64(ctx, 0); // st_size


	put iter = ctx.Ctx::Global::IR_ROOT;
	lab ir_loop;
		put iter = iter.IR::Node::NEXT;
		jump ir_done ~ iter == Mem::NULL;
		jump ir_loop ~ (iter.IR::Node::OPCODE) != IR::Op::REF;

		put symbol = iter.IR::Node::ARG;
		jump ir_loop ~ symbol == Mem::NULL;

		put addr   = iter.IR::Node::ADDR;
		put offset = HT::Get(map, symbol);

		IR::Push32(ctx, offset); // st_name
		IR::Push8 (ctx, 16 | 2); // st_info  = STT_FUNC | STB_GLOBAL
		IR::Push8 (ctx, 0     ); // st_other = STV_DEFAULT
		IR::Push16(ctx, 3     ); // st_shndx = `.all`
		IR::Push64(ctx, addr  ); // st_value
		IR::Push64(ctx, 0     ); // st_size  = 0

		jump ir_loop;
	lab ir_done;

	put stuff.Section::Stuff::SYM_TAB_END_PTR = IR::Addr(ctx);
}

fn Section::GenSectHdrs(ctx, stuff)
{
	put stuff.Section::Stuff::SECT_HDR_BASE_PTR = IR::Addr(ctx);
	put map = stuff.Section::Stuff::STR_TAB_MAP;

	// --- null section header ---
	IR::Push32(ctx, 0); // sh_name      = 0
	IR::Push32(ctx, 0); // sh_type      = SHT_NULL
	IR::Push64(ctx, 0); // sh_flags     = 0
	IR::Push64(ctx, 0); // sh_addr      = 0
	IR::Push64(ctx, 0); // sh_offset    = 0
	IR::Push64(ctx, 0); // sh_size      = 0
	IR::Push32(ctx, 0); // sh_link      = 0
	IR::Push32(ctx, 0); // sh_info      = 0
	IR::Push64(ctx, 0); // sh_addralign = 0
	IR::Push64(ctx, 0); // sh_ent_size  = 0

	// --- section header for string table ---
	put str_tab_base_ptr = stuff.Section::Stuff::STR_TAB_BASE_PTR;
	put str_tab_end_ptr  = stuff.Section::Stuff::STR_TAB_END_PTR;

	put str_tab_offset = str_tab_base_ptr - Tmpl::Config::LOAD_ADDR;
	put str_tab_size   = str_tab_end_ptr  - str_tab_base_ptr;

	IR::Push32(ctx, HT::Get(map, ".strtab")); // sh_name      = 0
	IR::Push32(ctx, 3                      ); // sh_type      = SHT_STRTAB
	IR::Push64(ctx, 0                      ); // sh_flags     = 0
	IR::Push64(ctx, 0                      ); // sh_addr      = 0 (don't load)
	IR::Push64(ctx, str_tab_offset         ); // sh_offset
	IR::Push64(ctx, str_tab_size           ); // sh_size
	IR::Push32(ctx, 0                      ); // sh_link      = 0
	IR::Push32(ctx, 0                      ); // sh_info      = 0
	IR::Push64(ctx, 0                      ); // sh_addralign = 0
	IR::Push64(ctx, 0                      ); // sh_ent_size  = 0

	// --- section header for symbol table ---
	put sym_tab_base_ptr = stuff.Section::Stuff::SYM_TAB_BASE_PTR; 
	put sym_tab_end_ptr  = stuff.Section::Stuff::SYM_TAB_END_PTR; 

	put sym_tab_offset = sym_tab_base_ptr - Tmpl::Config::LOAD_ADDR;
	put sym_tab_size   = sym_tab_end_ptr  - sym_tab_base_ptr;

	IR::Push32(ctx, HT::Get(map, ".symtab")); // sh_name      = 0
	IR::Push32(ctx, 2                      ); // sh_type      = SHT_SYMTAB
	IR::Push64(ctx, 0                      ); // sh_flags     = 0
	IR::Push64(ctx, 0                      ); // sh_addr      = 0 (don't load)
	IR::Push64(ctx, sym_tab_offset         ); // sh_offset
	IR::Push64(ctx, sym_tab_size           ); // sh_size
	IR::Push32(ctx, 1                      ); // sh_link      = `.strtab`
	IR::Push32(ctx, 1                      ); // sh_info      = 1
	IR::Push64(ctx, 0                      ); // sh_addralign = 0
	IR::Push64(ctx, 24                     ); // sh_ent_size  = 0

	// --- section header for all program data ---
	put progbits_base_ptr = stuff.Section::Stuff::PROGBIT_BASE_PTR;
	put progbits_end_ptr  = stuff.Section::Stuff::PROGBIT_END_PTR;

	put progbits_offset = progbits_base_ptr - Tmpl::Config::LOAD_ADDR;
	put progbits_size   = progbits_end_ptr  - progbits_base_ptr;

	IR::Push32(ctx, HT::Get(map, ".all")   ); // sh_name      = 0
	IR::Push32(ctx, 1                      ); // sh_type      = SHT_PROGBITS
	IR::Push64(ctx, 7                      ); // sh_flags     = WAX
	IR::Push64(ctx, Tmpl::Config::LOAD_ADDR + Tmpl::Config::HEADER_SIZE
	                                       ); // sh_addr      = LOAD_ADDR
	IR::Push64(ctx, progbits_offset        ); // sh_offset
	IR::Push64(ctx, progbits_size          ); // sh_size
	IR::Push32(ctx, 0                      ); // sh_link      = 0
	IR::Push32(ctx, 0                      ); // sh_info      = 0
	IR::Push64(ctx, 0                      ); // sh_addralign = 0
	IR::Push64(ctx, 0                      ); // sh_ent_size  = 0

}

fn Section::PatchMainTable(ctx, stuff)
{
	// patch main elf table to make 
	// section header accessible.
	put sect_hdr_base_ptr    = stuff.Section::Stuff::SECT_HDR_BASE_PTR;
	put sect_hdr_base_offset = sect_hdr_base_ptr - Tmpl::Config::LOAD_ADDR;

	IR::PatchDyn(ctx, 58 + Tmpl::Config::LOAD_ADDR, 64, 2); // e_shentsize = 0x40
	IR::PatchDyn(ctx, 60 + Tmpl::Config::LOAD_ADDR, 4 , 2); // e_shnum     = 4
	IR::Patch64 (ctx, 40 + Tmpl::Config::LOAD_ADDR, sect_hdr_base_offset);
	IR::PatchDyn(ctx, 62 + Tmpl::Config::LOAD_ADDR, 1,  2); // e_shstrndx  = 1
}


fn Section::Gen(ctx)
{
	put stuff = Chunk::New(Section::Stuff);
	put stuff.Section::Stuff::PROGBIT_BASE_PTR = 
		Tmpl::Config::HEADER_SIZE + Tmpl::Config::LOAD_ADDR;
	put stuff.Section::Stuff::PROGBIT_END_PTR  = IR::Addr(ctx);
	put stuff.Section::Stuff::STR_TAB_MAP = HT::Create();

	Section::GenStrTab     (ctx, stuff);
	Section::GenSymTab     (ctx, stuff);
	Section::GenSectHdrs   (ctx, stuff);
	Section::PatchMainTable(ctx, stuff);
	
}

