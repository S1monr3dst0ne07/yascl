

use "lib/net.yap"
use "lib/str.yap"
use "lib/debug.yap"

fn main()
{
    put addr = Net::ParseAddr("127.0.0.1");
    put port = Net::HostToNetShort(5000);

    put sock = Net::Connect(addr, port);
    print("socket: %d\n", [sock]);

    put string = "hello world\n";
    Net::Write(sock, string, Str::Len(string));
    
}
