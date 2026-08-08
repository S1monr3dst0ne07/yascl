
use "lib/x11.yap"
use "lib/frac.yap"
use "lib/debug.yap"

fn main()
{
    put state = X11::OpenDisplay("/tmp/.X11-unix/X1");
    X11::CreateGC(state);


    put width  = 400;
    put height = 400;

    put win = X11::CreateWindow(state, 200, 200, width*2, height*2);
    X11::SelectInput(state, win, X11::Mask::EXPOSURE);
    X11::MapWindow(state, win);


    lab loop;
        put event = X11::ReadEvent(state);
        put type = (event.0) & 255;

        jump again ~ type != X11::Event::EXPOSE;
        mandel(state, win, width, height);

    lab again;
        Chunk::Void(event);
    jump loop;
}


fn mandel(state, win, iXmax, iYmax)
{

    put zoom       = 2;
    put zoom_frac  = Frac::Make(1, zoom, 0);

    put CxMin = Frac::Mul(Frac::Make(5, 2, 1), zoom_frac); //-2.5
    put CxMax = Frac::Mul(Frac::Make(3, 2, 0), zoom_frac); // 1.5
    put CyMin = Frac::Mul(Frac::Make(2, 1, 1), zoom_frac); //-2.0
    put CyMax = Frac::Mul(Frac::Make(2, 1, 0), zoom_frac); // 2.0

    put PixelHeight  = 0;
    put PixelWidth  = Frac::Mul(Frac::Add(CxMax, Frac::Neg(CxMin)), Frac::Make(1, iXmax, 0));
    put PixelHeight = Frac::Mul(Frac::Add(CyMax, Frac::Neg(CyMin)), Frac::Make(1, iYmax, 0));

    put IterationMax = 50;
    put ER2 = Frac::Make(2*2, 1, 0); // 2^2

    put iY = 0;
    lab y_loop;
        put Cy = Frac::Add(CyMin, Frac::Mul(Frac::Make(iY, 1, 0), PixelHeight));

        put iX = 0;
        lab x_loop;
            put Cx = Frac::Add(CxMin, Frac::Mul(Frac::Make(iX, 1, 0), PixelWidth));

            put Zx  = Frac::Make(0, 1, 0);
            put Zy  = Frac::Make(0, 1, 0);
            put Zx2 = Frac::Make(0, 1, 0);
            put Zy2 = Frac::Make(0, 1, 0);


            put Iteration = 0;
            lab iter_loop;
                jump iter_done ~ Iteration == IterationMax;
                jump iter_done ~ Frac::Cmp(Frac::Add(Zx2, Zy2), ER2);
                    put Zy = Frac::Add(Frac::Mul(Frac::Make(2, 1, 0), Frac::Mul(Zx, Zy)), Cy);
                    put Zx = Frac::Add(Frac::Add(Zx2, Frac::Neg(Zy2)),                    Cx);
                    put Zx2 = Frac::Mul(Zx, Zx);
                    put Zy2 = Frac::Mul(Zy, Zy);


                put Iteration = Iteration + 1;
                jump iter_loop;
            lab iter_done;

            put col = (Iteration * 255) / IterationMax;
            X11::DrawPixel(state, win, iX, iY,       0, col, col);
            X11::DrawPixel(state, win, iX+iXmax, iY, col, 0, col);
            X11::DrawPixel(state, win, iX, iY+iYmax, col, col, 0);
            X11::DrawPixel(state, win, iX+iXmax, iY+iYmax, col, col, col);

            put iX = iX + 1;
        jump x_loop ~ iX < iXmax;

        put iY = iY + 1;
    jump y_loop ~ iY < iYmax;

    lab done;
}
