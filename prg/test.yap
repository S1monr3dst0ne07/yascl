

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
    jump loop;
}



