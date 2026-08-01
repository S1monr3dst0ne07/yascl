


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



fn Net::Connect(addr, port)
{
    // create socket
    put socket = Sys::TryCall(
        "Net::Connect::sys_socket",
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
        "Net::Connect::sys_connect",
        SYSCALL::CONNECT,
        socket, // socket fd
        obj,    // address object
        16,     // needs to be 16, otherwise kernel throws fit.
    );

    return socket;
}



