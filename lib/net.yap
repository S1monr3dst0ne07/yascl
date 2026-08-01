


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
	RAW	      = 3,
}

seq Net::CONFIG
{
    IPv4_ADDR_PART_COUNT = 4,
        // not shit! it's in the name.
}


fn Net::ParseAddr(addr)
    // parse ipv4 address in 3-dot format.
    // convert to network byte order.
{
    put index = 0;
    put buffer = 0;

    put pos = 0;
    put net = 0;

    lab loop;
        put char = addr.index;
        put index = index + 1;

        jump delim ~ char == '\0';
        jump delim ~ char == '.';

        put buffer = (buffer * 10) + (char - '0');
        jump loop;
    lab delim;
        put net = net | (buffer << (pos * 8));
        put pos = pos + 1;
        put buffer = 0;
    jump loop ~ pos != Net::CONFIG::IPv4_ADDR_PART_COUNT;

    return net;
}


fn Net::Connect(address, port)
{
    
}



