
use "lib/net.yap"
use "lib/dyn.yap"


seq X11::State
{
    SOCKET,
    ROOT_WIN,
    ID_ALLOCER,
    ID_GC,
    NET_BUFFER,
}


seq X11::Mask
{
    KEYPRESS = 1,
    EXPOSURE = 32768,
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



fn X11::Flush(state)
{
    put cache = state.X11::State::NET_BUFFER;
    jump empty ~ Dyn::Size(cache) == 0;
        Net::Write(state.X11::State::SOCKET, Dyn::Ptr(cache), Dyn::Size(cache));
        put cache.Dyn::SIZE = 0;
    lab empty;
}

fn X11::Local::Read(state, words)
{
    X11::Flush(state);
    put out = Chunk::New(words);
    Net::Read(state.X11::State::SOCKET, out, words);
    return out;
}
fn X11::Local::BufferBump(state, words)
{
    put cache = state.X11::State::NET_BUFFER;
    put new_size = Dyn::Size(cache) + words;
    put ptr = (cache.Dyn::CONTAINER) : Dyn::Size(cache);

    jump skip_flush ~ new_size < (cache.Dyn::CAPACITY);
        X11::Flush(state);
        put cache.Dyn::SIZE = words;
        return cache.Dyn::CONTAINER;
    lab skip_flush;

    put cache.Dyn::SIZE = new_size;
    return ptr;
}
fn X11::Local::Write(state, packet, words)
{
    Mem::Cpy(
        X11::Local::BufferBump(state, words),
        packet,
        words,
    );
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
    put state.X11::State::NET_BUFFER = Dyn::CreatePreAlloc(1 << 10);
    put state.X11::State::SOCKET = Net::UN::Connect(sock_path);

    // <debug>
    //    put addr = Net::ParseAddr("127.0.0.1");
    //    put port = Net::HostToNetShort(6000);
    //    put state.X11::State::SOCKET = Net::IN::Connect(addr, port);
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
    BIT0, BIT1, BIT2, BIT3, // bitmask (has to zero for this impl)
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


seq X11::Req::CreateWindow
{
    OPCODE, // 1 for this
    DEPTH,
    LEN_LOW, LEN_HIGH, 
    ID0, ID1, ID2, ID3, 
    ROOT0, ROOT1, ROOT2, ROOT3, 
    X_LOW, X_HIGH, //pos
    Y_LOW, Y_HIGH,
    W_LOW, W_HIGH, //size
    H_LOW, H_HIGH,
    B_LOW, B_HIGH, //border width
    CLASS_LOW, CLASS_HIGH // 1 for InputOutput
    VIS0, VIS1, VIS2, VIS3, // 0 for CopyFromParent
    BIT0, BIT1, BIT2, BIT3, // bitmask
}
fn X11::CreateWindow(state, x, y, w, h)
{
    put req = Chunk::New(X11::Req::CreateWindow);
    Mem::Set(req, 0, X11::Req::CreateWindow);

    put req.X11::Req::CreateWindow::OPCODE   = 1;
    put req.X11::Req::CreateWindow::DEPTH    = 0;
    put req.X11::Req::CreateWindow::LEN_LOW  = 8;
    put req.X11::Req::CreateWindow::LEN_HIGH = 0;

    put win_id = X11::Local::AllocID(state);
    put req.X11::Req::CreateWindow::ID0 = (win_id >>  0) & 255;
    put req.X11::Req::CreateWindow::ID1 = (win_id >>  8) & 255;
    put req.X11::Req::CreateWindow::ID2 = (win_id >> 16) & 255;
    put req.X11::Req::CreateWindow::ID3 = (win_id >> 24) & 255;

    put root_id = state.X11::State::ROOT_WIN;
    put req.X11::Req::CreateWindow::ROOT0 = (root_id >>  0) & 255;
    put req.X11::Req::CreateWindow::ROOT1 = (root_id >>  8) & 255;
    put req.X11::Req::CreateWindow::ROOT2 = (root_id >> 16) & 255;
    put req.X11::Req::CreateWindow::ROOT3 = (root_id >> 24) & 255;


    put req.X11::Req::CreateWindow::X_LOW  = (x >> 0) & 255;
    put req.X11::Req::CreateWindow::X_HIGH = (x >> 8) & 255;
    put req.X11::Req::CreateWindow::Y_LOW  = (y >> 0) & 255;
    put req.X11::Req::CreateWindow::Y_HIGH = (y >> 8) & 255;

    put req.X11::Req::CreateWindow::W_LOW  = (w >> 0) & 255;
    put req.X11::Req::CreateWindow::W_HIGH = (w >> 8) & 255;
    put req.X11::Req::CreateWindow::H_LOW  = (h >> 0) & 255;
    put req.X11::Req::CreateWindow::H_HIGH = (h >> 8) & 255;

    put req.X11::Req::CreateWindow::B_LOW  = 1;
    put req.X11::Req::CreateWindow::CLASS_LOW  = 1;

    X11::Local::Write(state, req, X11::Req::CreateWindow);
    Chunk::Void(req);

    return win_id;
}


seq X11::Req::Change
    // generic change request.
    // used for ChangeWindowAttr
    // and for ChangeGC
{
    OPCODE, PADDING, // YAY!
    LEN_LOW, LEN_HIGH,
    ID0,  ID1,  ID2,  ID3,
    BIT0, BIT1, BIT2, BIT3,
    VAL0, VAL1, VAL2, VAL3,
}

fn X11::Local::ChangeReq(state, opcode, id, bit, val)
{
    put req = X11::Local::BufferBump(state, X11::Req::Change);
    Mem::Set(req, 0, X11::Req::Change);

    put req.X11::Req::Change::OPCODE = opcode;
    put req.X11::Req::Change::LEN_LOW  = 4; // 3+n (n = 1)
    put req.X11::Req::Change::LEN_HIGH = 0;

    put req.X11::Req::Change::ID0 = (id >>  0) & 255;
    put req.X11::Req::Change::ID1 = (id >>  8) & 255;
    put req.X11::Req::Change::ID2 = (id >> 16) & 255;
    put req.X11::Req::Change::ID3 = (id >> 24) & 255;

    put req.X11::Req::Change::BIT0 = (bit >>  0) & 255;
    put req.X11::Req::Change::BIT1 = (bit >>  8) & 255;
    put req.X11::Req::Change::BIT2 = (bit >> 16) & 255;
    put req.X11::Req::Change::BIT3 = (bit >> 24) & 255;

    put req.X11::Req::Change::VAL0 = (val >>  0) & 255;
    put req.X11::Req::Change::VAL1 = (val >>  8) & 255;
    put req.X11::Req::Change::VAL2 = (val >> 16) & 255;
    put req.X11::Req::Change::VAL3 = (val >> 24) & 255;

}



fn X11::SelectInput(state, win, mask)
{
    X11::Local::ChangeReq(
        state,
        2, //ChangeWindowAttr
        win,
        (1 << 11), //PropertyChange
        mask,
    );
}



seq X11::Req::MapWindow
{
    OPCODE, PADDING, // YAY!
    LEN_LOW, LEN_HIGH,
    WIN0, WIN1, WIN2, WIN3
}
fn X11::MapWindow(state, win)
{
    put req = Chunk::New(X11::Req::MapWindow);
    put req.X11::Req::MapWindow::OPCODE = 8;
    put req.X11::Req::MapWindow::LEN_LOW = 2;
    put req.X11::Req::MapWindow::LEN_HIGH = 0;

    put req.X11::Req::MapWindow::WIN0 = (win >>  0) & 255;
    put req.X11::Req::MapWindow::WIN1 = (win >>  8) & 255;
    put req.X11::Req::MapWindow::WIN2 = (win >> 16) & 255;
    put req.X11::Req::MapWindow::WIN3 = (win >> 24) & 255;

    X11::Local::Write(state, req, X11::Req::MapWindow);
    Chunk::Void(req);
}



fn X11::ReadEvent(state)
{
    return X11::Local::Read(state, 32);
}


seq X11::Event::Expose
{
    CODE, PADDING, // hehe padding :3
    SEQ_LOW, SEQ_HIGH,
    WIN0, WIN1, WIN2, WIN3,
    X_LOW, X_HIGH,
    Y_LOW, Y_HIGH,
    W_LOW, W_HIGH,
    H_LOW, H_HIGH,
    COUNT_LOW, COUNT_HIGH,
}

fn X11::SetFore(state, r, g, b)
{
    X11::Local::ChangeReq(
        state,
        56, //ChangeGC
        state.X11::State::ID_GC,
        (1 << 2), //Foreground
        (r <<  0) |
        (g <<  8) |
        (b << 16) ,
    );
}

seq X11::Req::PolyPoint
{
    OPCODE, MODE,
    LEN_LOW, LEN_HIGH,
    WIN0, WIN1, WIN2, WIN3,
    GC0,  GC1,  GC2,  GC3,
    X_LOW, X_HIGH,
    Y_LOW, Y_HIGH,
}

fn X11::PolyPointTMP(state, win, x, y)
{
    put req = X11::Local::BufferBump(state, X11::Req::PolyPoint);

    put req.X11::Req::PolyPoint::OPCODE = 64;
    put req.X11::Req::PolyPoint::MODE = 0; // origin relative
    put req.X11::Req::PolyPoint::LEN_LOW = 4; 
    put req.X11::Req::PolyPoint::LEN_HIGH = 0; 

    put req.X11::Req::PolyPoint::WIN0 = (win >>  0) & 255;
    put req.X11::Req::PolyPoint::WIN1 = (win >>  8) & 255;
    put req.X11::Req::PolyPoint::WIN2 = (win >> 16) & 255;
    put req.X11::Req::PolyPoint::WIN3 = (win >> 24) & 255;

    put gc = state.X11::State::ID_GC;
    put req.X11::Req::PolyPoint::GC0 = (gc >>  0) & 255;
    put req.X11::Req::PolyPoint::GC1 = (gc >>  8) & 255;
    put req.X11::Req::PolyPoint::GC2 = (gc >> 16) & 255;
    put req.X11::Req::PolyPoint::GC3 = (gc >> 24) & 255;

    
    put req.X11::Req::PolyPoint::X_LOW  = (x >> 0) & 255;
    put req.X11::Req::PolyPoint::X_HIGH = (x >> 8) & 255;
    put req.X11::Req::PolyPoint::Y_LOW  = (y >> 0) & 255;
    put req.X11::Req::PolyPoint::Y_HIGH = (y >> 8) & 255;

}




fn X11::DrawPixel(state, win, x, y, r, g, b)
{
    X11::SetFore(state, r, g, b);
    X11::PolyPointTMP(state, win, x, y);
}



