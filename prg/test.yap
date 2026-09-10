

use "lib/http.yap"

fn main()
{
    put addr = Net::ParseAddr("0.0.0.0");
    put port = Net::HostToNetShort(5000);
    put server = Net::Server::Init(addr, port, 10);

    jump exit ~ server == Mem::NULL;

    lab loop;
        put conn = Net::Server::Accept(server);

        put req = Http::Recv(conn);

        put string = "hello world";
        put ht = HT::Create();
        Http::Send(conn, ht, string, Str::Len(string));
        HT::Void(ht);

        Http::VoidReq(req);
        Net::Close(conn);
    jump loop;


lab exit;
}



