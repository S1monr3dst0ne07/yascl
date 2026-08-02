
use "lib/net.yap"


seq X11::State
{
    SOCKET,
    ROOT_WIN,
    ID_ALLOCER,
    ID_GC,
}


seq X11::Mask
{
    EXPOSURE = 1,
    KEYPRESS = 32768,
}
seq X11::Event
{
    KEYPRESS = 2,
    EXPOSE   = 12,
}


fn X11::Local::AllocID(state)
{
    put allocer = state.X11::State::ID_ALLOCER;
    put state.X11::State::ID_ALLOCER = allocer + 1;
    return allocer;
}

fn X11::Local::Read(state, words)
{
    put out = Chunk::New(words);
    Net::Read(state.X11::State::SOCKET, out, words);
    return out;
}
fn X11::Local::Write(state, buffer, words)
{
    Net::Write(state.X11::State::SOCKET, buffer, words);
}


// YAY PADDING FOR EVERYBODY !!!
// don't you just love being padded?
seq X11::Startup::Ask
{
    PREFIX,
    PADDING,
    VERSION_MAJOR_LOW, VERSION_MAJOR_HIGH,
    VERSION_MINOR_LOW, VERSION_MINOR_HIGH,
    AUTH_NAME_LOW, AUTH_NAME_HIGH, AUTH_NAME_PADDING,
    AUTH_DATA_LOW, AUTH_DATA_HIGH, AUTH_DATA_PADDING,
}
seq X11::Startup::RespHead
{
    SUCCESS, PADDING,
    VERSION_MAJOR_LOW, VERSION_MAJOR_HIGH,
    VERSION_MINOR_LOW, VERSION_MINOR_HIGH,
    SIZE_LOW, SIZE_HIGH,
}
seq X11::Startup::Resp
{
    RELEASE0, RELEASE1, RELEASE2, RELEASE3,
    RES_ID_BASE0, RES_ID_BASE1, RES_ID_BASE2, RES_ID_BASE3,
    RES_ID_MASK0, RES_ID_MASK1, RES_ID_MASK2, RES_ID_MASK3,
    MONBUF_SIZE0, MONBUF_SIZE1, MONBUF_SIZE2, MONBUF_SIZE3,
    VENDOR_SIZE0, VENDOR_SIZE1,
    MAX_REQ_LEN0, MAX_REQ_LEN1,
    NUMBER_SCREENS,
    NUMBER_FORMATS,
    IMAGE_BYTE_ORDER,
    BITMAP_BIT_ORDER,
    BMP_FMT_SCANLINE_UNIT,
    BMP_FMT_SCANLINE_PAD,
    MIN_KEYCODE,
    MAX_KEYCODE,
    PADDING0, PADDING1, PADDING2, PADDING3,
    DYNAMIC_START,
}

fn X11::OpenDisplay(sock_path)
{
    put state = Chunk::New(X11::State);
    //put state.X11::State::SOCKET = Net::UN::Connect(sock_path);

    // <debug>
        put addr = Net::ParseAddr("127.0.0.1");
        put port = Net::HostToNetShort(6000);
        put state.X11::State::SOCKET = Net::IN::Connect(addr, port);
    // </debug>


    // ask for connection init
    put ask = Chunk::New(X11::Startup::Ask);
    put ask.X11::Startup::Ask::PREFIX = 'l';

    put ask.X11::Startup::Ask::VERSION_MAJOR_LOW  = 11; // X... 11
    put ask.X11::Startup::Ask::VERSION_MAJOR_HIGH = 0 ; 

    X11::Local::Write(state, ask, X11::Startup::Ask);
    Chunk::Void(ask);

    // read response header
    put resp_head = X11::Local::Read(state, X11::Startup::RespHead);
    put size = 
        ((resp_head.X11::Startup::RespHead::SIZE_LOW ) << 0) |
        ((resp_head.X11::Startup::RespHead::SIZE_HIGH) << 8) ;
    put succ = resp_head.X11::Startup::RespHead::SUCCESS;
    Chunk::Void(resp_head);
    jump conn_init_fail ~ Bool::Not(succ);

    // read actual response body.
    put resp = X11::Local::Read(state, size);

    put state.X11::State::ID_ALLOCER =
        ((resp.X11::Startup::Resp::RES_ID_BASE0) << 0 ) |
        ((resp.X11::Startup::Resp::RES_ID_BASE1) << 8 ) |
        ((resp.X11::Startup::Resp::RES_ID_BASE2) << 16) |
        ((resp.X11::Startup::Resp::RES_ID_BASE3) << 24) ;

    put dynamic = resp : X11::Startup::Resp::DYNAMIC_START;
    put vendor_size = 
        ((resp.X11::Startup::Resp::VENDOR_SIZE0) << 0) | 
        ((resp.X11::Startup::Resp::VENDOR_SIZE1) << 8) ;

    // --- reading vendor ---
    // provided if needed.
    //put vendor = Chunk::New(vendor_size+1);
    //Mem::Cpy(vendor, dynamic, vendor_size);
    //print("vendor: %s\n", [vendor]);

    // move to format section.
    put dynamic = dynamic : vendor_size;

    // formats don't need to read.
    // most every X11 implementation supports
    // the standard formats. if you want to figure
    // out which standards your X11 server provides,
    // just use wireshark.
    put number_formats = resp.X11::Startup::Resp::NUMBER_FORMATS;
    put format_size    = number_formats * 8;
    put dynamic = dynamic : format_size;

    // finally read screen info.
    // only one screen is supported.
    put number_screens = resp.X11::Startup::Resp::NUMBER_SCREENS;
    jump multiple_screens_fail ~ number_screens > 1;

    // TODO: make a proper struct for this.
    // for now, just read root win id info.
    put state.X11::State::ROOT_WIN = 
        ((dynamic.0) <<  0) |
        ((dynamic.1) <<  8) |
        ((dynamic.2) << 16) |
        ((dynamic.3) << 24) ;
    
    Chunk::Void(resp);
    return state;

lab multiple_screens_fail;
    print("[X11::OpenDisplay] Server has %d, but this implementation only supports one screen.", [number_screens]);
    return Mem::NULL;
lab conn_init_fail;
    print("[X11::OpenDisplay] Initial connection fail.");
    return Mem::NULL;
}





seq X11::Req::CreateGC
{
    OPCODE, // 55=0x37 for this
    PADDING, // YES!
    LEN_LOW, LEN_HIGH,
    GC0,  GC1,  GC2,  GC3,  // GC ID from AllocID
    WIN0, WIN1, WIN2, WIN3, // window ID
    BIT0, BIT1, BIT2, BIT3, // bit mask (has to zero for this impl)
}
fn X11::CreateGC(state)
{
    put req = Chunk::New(X11::Req::CreateGC);
    put req.X11::Req::CreateGC::OPCODE  = 55;

    // (4+n) where n is the extension.
    // this impl doesnt support extension,
    // is the request length is always 4.
    put req.X11::Req::CreateGC::LEN_LOW  = 4; 
    put req.X11::Req::CreateGC::LEN_HIGH = 0;

    put gd_id = X11::Local::AllocID(state);
    put state.X11::State::ID_GC = gd_id;
    put req.X11::Req::CreateGC::GC0 = (gd_id >>  0) & 255;
    put req.X11::Req::CreateGC::GC1 = (gd_id >>  8) & 255;
    put req.X11::Req::CreateGC::GC2 = (gd_id >> 16) & 255;
    put req.X11::Req::CreateGC::GC3 = (gd_id >> 24) & 255;

    put root_win_id = state.X11::State::ROOT_WIN;
    put req.X11::Req::CreateGC::WIN0 = (root_win_id >>  0) & 255;
    put req.X11::Req::CreateGC::WIN1 = (root_win_id >>  8) & 255;
    put req.X11::Req::CreateGC::WIN2 = (root_win_id >> 16) & 255;
    put req.X11::Req::CreateGC::WIN3 = (root_win_id >> 24) & 255;

    // bitmask has to be full unset.
    put req.X11::Req::CreateGC::BIT0 = 0;
    put req.X11::Req::CreateGC::BIT1 = 0;
    put req.X11::Req::CreateGC::BIT2 = 0;
    put req.X11::Req::CreateGC::BIT3 = 0;

    X11::Local::Write(state, req, X11::Req::CreateGC);
    Chunk::Void(req);
}



