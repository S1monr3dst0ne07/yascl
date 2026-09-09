
use "lib/net.yap"



seq Http::MethodKind
{
    GET,
    POST,
}

fn Http::GetMethodKind(string)
{
    jump skip_GET  ~ Str::Diff(string, "GET");  return Http::MethodKind::GET;  lab skip_GET;
    jump skip_POST ~ Str::Diff(string, "POST"); return Http::MethodKind::POST; lab skip_POST;
}

seq Http::Request
{
    METHOD,  
    PATH,
    PARAMS,
    //DATA,
}


seq Http::Config
{
    RECV_BUFFER_SIZE = 1000000,
    SEND_BUFFER_SIZE = 1000000,
}

fn Http::Local::Next(buffer, delim)
{
    put i = 0;
    lab loop;
        put char = buffer.i;
        jump done ~ char == delim;

        put i = i + 1;
        jump loop;
    lab done;

    put buffer.i = '\0';
    return buffer : (i + 1);
}

fn Http::Recv(socket)
{
    // i pray to shiva "let my buffers be sufficient", but they are not.
    put buffer = Chunk::New(Http::Config::RECV_BUFFER_SIZE);
    put nbytes = Net::Read(socket, buffer, Http::Config::RECV_BUFFER_SIZE);
    put buffer.nbytes = '\0';

    put req = Chunk::New(Http::Request);
    
    put method_string = buffer; put buffer = Http::Local::Next(buffer, ' ');
    put path          = buffer; put buffer = Http::Local::Next(buffer, ' ');
    put version       = buffer; put buffer = Http::Local::Next(buffer, '\n');

    put table = HT::Create();

    put req.Http::Request::METHOD = Http::GetMethodKind(method_string);
    put req.Http::Request::PATH   = Str::Copy(path);
    put req.Http::Request::PARAMS = table;

    lab loop;
        jump done ~ (buffer.0) == '\0';
        jump done ~ (buffer.0) == '\n';
        jump done ~ (buffer.0) == '\r';

        put key   = buffer; put buffer = Http::Local::Next(buffer, ':') : 1;
        put value = buffer; put buffer = Http::Local::Next(buffer, '\n');

        HT::Set(table, key, value);

        jump loop;
    lab done;

    Chunk::Void(buffer);
    return req;
}

fn Http::Send(socket, params, content, content_length)
{
    static Http::Config::SEND_BUFFER_SIZE ~ buffer;
    put ptr = buffer;

    put ptr = Str::Format(ptr, "HTTP/1.1 200 OK\r\n");

    put it = HT::MakeIter(params);
    lab loop;
        jump done ~ Bool::Not(HT::Next(it));

        put ptr = Str::Format(ptr, "%s: %s\r\n", [
            it.HT::Iter::KEY,
            it.HT::Iter::VALUE,
        ]);

        jump loop;
    lab done;

    put ptr.0 = '\r';
    put ptr.1 = '\n';
    put ptr = ptr : 2;

    put header_length = (ptr - buffer) >> 3;
    Net::Write(socket, buffer, header_length);
    Net::Write(socket, content, content_length);
}



