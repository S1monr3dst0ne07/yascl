


use "lib/x11.yap"
use "lib/debug.yap"


fn main()
{
    put state = X11::OpenDisplay("/tmp/.X11-unix/X1");
    X11::CreateGC(state);

    put win = X11::CreateWindow(state, 200, 200, 200, 200);
    X11::SelectInput(state, win, X11::Mask::EXPOSURE);
    X11::MapWindow(state, win);


    lab loop;
        put event = X11::ReadEvent(state);
        put type = (event.0) & 255;

        jump again ~ type != X11::Event::EXPOSE;
        render(state, win, event);

    lab again;
        Chunk::Void(event);
    jump loop;
}



fn render(state, win, event)
{
    put width = 
        ((event.X11::Event::Expose::W_LOW ) << 0) | 
        ((event.X11::Event::Expose::W_HIGH) << 8) ;
    put height = 
        ((event.X11::Event::Expose::H_LOW ) << 0) | 
        ((event.X11::Event::Expose::H_HIGH) << 8) ;

    print("width:  %d\n", [width]);
    print("height: %d\n", [height]);


    put x = 0;
    lab loop_x;

        put y = 0;
        lab loop_y;
            put u = (x*255) / width;
            put v = (y*255) / height;

            X11::DrawPixel(state, win, 
                x, y,
                u, 255 - u, v,
            );

            put y = y + 1;
        jump loop_y ~ y < height;

        put x = x + 1;
    jump loop_x ~ x < width;
}





