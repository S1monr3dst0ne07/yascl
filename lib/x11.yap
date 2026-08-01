
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
    Chunk::Void(resp_head);

    put resp = X11::Local::Read(state, size);
    
    put i = 0;
    lab loop;
        print("%d\n", [resp.i]);
        put i = i + 1;
    jump loop ~ i < (size-1);

}


