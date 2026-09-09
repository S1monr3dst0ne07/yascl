

use "lib/net.yap"

fn main()
{
    put addr = Net::ParseAddr("127.0.0.1");
    put port = Net::HostToNetShort(5000);
    put server = Net::Server::Init(addr, port, 10);

    jump exit ~ server == Mem::NULL;

    lab loop;
        put conn = Net::Server::Accept(server);

        put string = "hello world";
        Net::Write(conn, string, Str::Len(string));

        Net::Close(conn);
    jump loop;

lab exit;
}



