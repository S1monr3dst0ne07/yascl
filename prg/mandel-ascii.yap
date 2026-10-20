
use "lib/io.yap"
use "lib/float.yap"

fn main()
{
    put iXmax = 100;
    put iYmax = 100;

    put zoom       = 2.0;

    put CxMin = ((0.0) ~- (2.5)) ~/ zoom;
    put CxMax = (         (1.5)) ~/ zoom;
    put CyMin = ((0.0) ~- (2.0)) ~/ zoom;
    put CyMax = (         (2.0)) ~/ zoom;

    put PixelHeight  = 0;
    put PixelWidth  = (CxMax ~- CxMin) ~/ Float::FromInt(iXmax);
    put PixelHeight = (CyMax ~- CyMin) ~/ Float::FromInt(iYmax);

    put IterationMax = 200;
    put ER2 = 4.0; // 2^2

    put frame_buffer = Dyn::Create();

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
                jump iter_done_inside  ~ Iteration == IterationMax;
                jump iter_done_outside ~ (Zx2 ~+ Zy2) ~> ER2;
					put Zy  = Cy ~+ ((2.0) ~* Zx ~* Zy);
					put Zx  = Cx ~+ Zx2 ~- Zy2;
					put Zx2 = Zx ~* Zx;
					put Zy2 = Zy ~* Zy;

                put Iteration = Iteration + 1;
                jump iter_loop;
            lab iter_done_inside;   Dyn::Push(frame_buffer, '#'); jump iter_done;
            lab iter_done_outside;  Dyn::Push(frame_buffer, ' '); jump iter_done;
            lab iter_done;

            put iX = iX + 1;
        jump x_loop ~ iX < iXmax;

        Dyn::Push(frame_buffer, '\n');
        put iY = iY + 1;
    jump y_loop ~ iY < iYmax;

    lab done;

	Dyn::Push(frame_buffer, '\0');
	IO::Print(Dyn::Ptr(frame_buffer));

	Dyn::Void(frame_buffer);
}
