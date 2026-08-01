
use "lib/chunk.yap"


seq Net::AF
{
    UNSPEC,
    UNIX,
    INET,
}

seq Net::SOCK
{
	STREAM	  = 1,
	DGRAM	  = 2,
	RAW       = 3,
}

seq Net::CONFIG
{
    IPv4_ADDR_PART_COUNT = 4,
        // not shit! it's in the name.
}


fn Net::ParseAddr(str)
    // parse ipv4 address in 3-dot format.
    // convert to network byte order.
{
    put index = 0;
    put buffer = 0;

    put pos = 0;
    put addr = 0;

    lab loop;
        put char = str.index;
        put index = index + 1;

        jump delim ~ char == '\0';
        jump delim ~ char == '.';

        put buffer = (buffer * 10) + (char - '0');
        jump loop;
    lab delim;
        put addr = addr | (buffer << (pos * 8));
        put pos = pos + 1;
        put buffer = 0;
    jump loop ~ pos != Net::CONFIG::IPv4_ADDR_PART_COUNT;

    return addr;
}


fn Net::HostToNetShort(x)
{
    put low  = (x     ) & 255;
    put high = (x >> 8) & 255;

    return (low << 8) + high;
}


seq Net::STRUCT::sockaddr_in
    // in bit count format.
{
    sin_family = 0, 
    sin_port   = 16, 
    sin_addr   = 32,
}



fn Net::IN::Connect(addr, port)
{
    // create socket
    put socket = Sys::TryCall(
        "Net::IN::Connect::sys_socket",
        SYSCALL::SOCKET, 
        Net::AF::INET,     // address family: internet
        Net::SOCK::STREAM, // socket type: stream (meaning: make sure all data get there it's supposed to.)
        0,                 // only tcp/ip for this config, so protocol can be let blank.
    );

    // the sockaddr_in struct fits into a native qword.
    // sizeof(struct sockaddr_in) reports 16 but it contains
    // 8 bytes of padding which can be ignored when rawdogging.
    static 1 ~ obj;
    put obj.0 =
        (Net::AF::INET << Net::STRUCT::sockaddr_in::sin_family) |
        (port          << Net::STRUCT::sockaddr_in::sin_port)   |
        (addr          << Net::STRUCT::sockaddr_in::sin_addr)   ;

    Sys::TryCall(
        "Net::IN::Connect::sys_connect",
        SYSCALL::CONNECT,
        socket, // socket fd
        obj,    // address object
        16,     // needs to be 16, otherwise kernel throws fit.
    );

    return socket;
}


fn Net::UN::Connect(path)
{
    put path_len = Str::Len(path);
    put obj_size = path_len + 2;
    put obj = Chunk::New(obj_size);
    put obj.0 = Net::AF::UNIX;
    Mem::ToBytes(obj + 2, path, path_len);

    put socket = Sys::TryCall(
        "Net::UN::Connect::sys_socket",
        SYSCALL::SOCKET, 
        Net::AF::UNIX,
        Net::SOCK::STREAM, 
        0,                 
    );
    Sys::TryCall(
        "Net::UN::Connect::sys_connect",
        SYSCALL::CONNECT,
        socket, 
        obj,
        110,
    );

    return socket;
}





fn Net::Write(socket, buffer, count)
{
    // syscall is slow anyways.
    // so the heap action can't hurt much.
    put bytes = Chunk::New(count);
    Mem::ToBytes(bytes, buffer, count);

    put nbytes = Sys::TryCall(
        "Net::Write",
        SYSCALL::WRITE,
        socket,
        bytes,
        count,
    );

    Chunk::Void(bytes);
    return nbytes;
}


fn Net::Read(socket, buffer, count)
{
    put bytes = Chunk::New(count);

    put nbytes = Sys::TryCall(
        "Net::Read",
        SYSCALL::READ,
        socket,
        bytes,
        count,
    );

    Mem::FromBytes(buffer, bytes, count);
    //Chunk::Void(bytes);
    return nbytes;
}


