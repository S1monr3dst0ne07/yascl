
use "lib/x11.yap"
use "lib/float.yap"
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

    put zoom       = 2.0;

    put CxMin = ((0.0) ~- (2.5)) ~/ zoom;
    put CxMax = (         (1.5)) ~/ zoom;
    put CyMin = ((0.0) ~- (2.0)) ~/ zoom;
    put CyMax = (         (2.0)) ~/ zoom;

    put PixelHeight  = 0;
    put PixelWidth  = (CxMax ~- CxMin) ~/ Float::FromInt(iXmax);
    put PixelHeight = (CyMax ~- CyMin) ~/ Float::FromInt(iYmax);

    put IterationMax = 50;
    put ER2 = 4.0; // 2^2

    put iY = 0;
    lab y_loop;
    	put Cy = CyMin ~+ (Float::FromInt(iY) ~* PixelHeight);

        put iX = 0;
        lab x_loop;
        	put Cx = CxMin ~+ (Float::FromInt(iX) ~* PixelWidth);

            put Zx  = 0.0;
            put Zy  = 0.0;
            put Zx2 = 0.0;
            put Zy2 = 0.0;

            put Iteration = 0;
            lab iter_loop;
                jump iter_done ~ Iteration == IterationMax;
                jump iter_done ~ (Zx2 ~+ Zy2) ~> ER2;
					put Zy  = Cy ~+ ((2.0) ~* Zx ~* Zy);
					put Zx  = Cx ~+ Zx2 ~- Zy2;
					put Zx2 = Zx ~* Zx;
					put Zy2 = Zy ~* Zy;

                put Iteration = Iteration + 1;
                jump iter_loop;
            lab iter_done;


            put col = (Iteration * 255) / IterationMax;
            X11::DrawPixel(state, win, iX,       iY,       0,   col, col);
            X11::DrawPixel(state, win, iX+iXmax, iY,       col, 0,   col);
            X11::DrawPixel(state, win, iX,       iY+iYmax, col, col, 0  );
            X11::DrawPixel(state, win, iX+iXmax, iY+iYmax, col, col, col);

            put iX = iX + 1;
        jump x_loop ~ iX < iXmax;

        put iY = iY + 1;
    jump y_loop ~ iY < iYmax;

    lab done;
}
