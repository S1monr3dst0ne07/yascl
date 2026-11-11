use "lib/io.yap"
use "lib/float.yap"
use "lib/debug.yap"
use "lib/str.yap"
use "lib/uapi.yap"

seq Config
{
	WIDTH       = 200,
	HEIGHT      = 40,
	BALL_AMOUNT = 8,
}

seq Ball
{
	PX,
	PY,
	VX,
	VY,
}

fn get_ball(balls, i)
{
	return balls : (i * 4);
}

fn sleep(seconds, milliseconds)
{
    static Time::Spec ~ time;
    put time.Time::Spec::SEC = seconds;
    put time.Time::Spec::NSEC = milliseconds * 1000000;

    syscall(SYSCALL::NANOSLEEP, time, 0);
}


fn random(upper_bound)
{
    static Time::Spec ~ time;
    syscall(SYSCALL::CLOCK_GETTIME, 0, time);

    put magic = ((0 - 1) >> 32);

    put x = (time.Time::Spec::NSEC) & magic;

    // Algorithm "xor" from p. 4 of Marsaglia, "Xorshift RNGs"
    put x = x ^ (x << 13);
    put x = x & magic;

    put x = x ^ (x >> 17);
    put x = x & magic;

    put x = x ^ (x << 5);
    put x = x & magic;

    return x % upper_bound;
}

fn print_escape(code)
{
    put str = " ";
    put str.0 = 27;
    IO::Print(str);
    IO::Print(code);
}

fn reset_screen()
{
    print_escape("[2J");
}

fn set_cursor(x, y)
{
    static 128 ~ buff;

    put str   = "[%d;%dH";
    put str = Str::Format(buff, str, [x, y]);
    print_escape(buff);
}

fn set_color(c)
{
    static 128 ~ buff;

    put str   = "[%dm";
    put str = Str::Format(buff, str, [c]);
    print_escape(buff);
}

fn reset_color(c)
{
    print_escape("[0m");
}

fn hide_cursor()
{
    print_escape("[?25l");
}

fn show_cursor()
{
    print_escape("[?25h");
}

fn buffer_start()
{
    print_escape("[?2026h");
}

fn buffer_end()
{
    print_escape("[?2026l");
}

fn alt_screen_start()
{
    print_escape("[?1049h");
}

fn alt_screen_end()
{
    print_escape("[?1049l");
}

fn abs(f)
{
    return f & ((0 - 1) >> 1);
}

fn fadd_ball_field(ball, field, delta)
{
	put ball.field = (ball.field) ~+ delta;
}

fn coll_two_balls(b1, b2)
{
    put radius = 5.0;

    put dx  = (b1.Ball::PX) ~- (b2.Ball::PX);
    put dy  = (b1.Ball::PY) ~- (b2.Ball::PY);

    put dvx = (b1.Ball::VX) ~- (b2.Ball::VX);
    put dvy = (b1.Ball::VY) ~- (b2.Ball::VY);

    put dist = Float::Sqrt((dx ~* dx) ~+ (dy ~* dy));
    put overlap = (radius ~* (2.0)) ~- dist;
    jump end ~ overlap ~< (0.0);

    put dot_product_dv_dp = (dvx ~* dx) ~+ (dvy ~* dy);

    // common factors
    put c = dot_product_dv_dp ~/ (dist ~* dist);

    put cx = c ~* dx;
    put cy = c ~* dy;

	fadd_ball_field(b1, Ball::VX, neg(cx));
	fadd_ball_field(b2, Ball::VX,     cx );

	fadd_ball_field(b1, Ball::VY, neg(cy));
	fadd_ball_field(b2, Ball::VY,     cy );

    put correction = overlap ~* (0.501);
    put dx = (dx ~/ dist) ~* correction;
    put dy = (dy ~/ dist) ~* correction;

	fadd_ball_field(b1, Ball::PX,     dx);
	fadd_ball_field(b2, Ball::PX, neg(dx));

	fadd_ball_field(b1, Ball::PY,     dy);
	fadd_ball_field(b2, Ball::PY, neg(dy));

    lab end;
}

fn coll_all_balls(balls)
{
    put amount = Config::BALL_AMOUNT;
    put limit  = amount * amount;

    put i = 0;
    lab loop;
    	put i1 = i % amount;
    	put i2 = i / amount;

        put b1 = get_ball(balls, i1);
        put b2 = get_ball(balls, i2);

        jump skip_coll ~ i1 == i2;
        jump skip_coll ~ i1 >  i2;
	        coll_two_balls(
	        	get_ball(balls, i1),
	        	get_ball(balls, i2),
	        );
        lab skip_coll;

        put i = i + 1;
    jump loop ~ i < limit;
}

fn clamp(x, min, max)
{
	jump bigger_min ~ x ~> min;
		return min;
		lab bigger_min;

	jump smaller_max ~ x ~< max;
		return max;
		lab smaller_max;

	return x;
}

fn neg(x)
{
	return x ^ (1 << 63);
}

fn update(balls, delta_time)
{
    put i = 0;
    put radius = 5.0;

    // compute ball bounding box
    put f_width  = Float::FromInt(Config::WIDTH );
    put f_height = Float::FromInt(Config::HEIGHT);

    put x_min =             radius;
    put x_max = f_width  ~- radius;
    put y_min =             radius;
    put y_max = f_height ~- radius;
     

    lab loop;
    	put ball = get_ball(balls, i);

        put x  = ball.Ball::PX;
        put y  = ball.Ball::PY;
        put vx = ball.Ball::VX;
        put vy = ball.Ball::VY;

        // apply gravity
        put vy = vy ~+ ((1.00) ~* delta_time);
        put vy = vy ~* (0.98);

        // add velocities to the positions
        put x = x ~+ (vx ~* delta_time);
        put y = y ~+ (vy ~* delta_time);

        // clamp into bounding box
        put x_prime = clamp(x, x_min, x_max);
        put y_prime = clamp(y, y_min, y_max);

		// extract collision axies
		put x_no_diff = x_prime == x;
		put y_no_diff = y_prime == y;

		// write back positions
		put ball.Ball::PX = x_prime;
		put ball.Ball::PY = y_prime;

		// update velocities
		put damping = 0.9;

		jump x_no_coll ~ x_no_diff;
			put vx = neg(vx) ~* damping;
			lab x_no_coll;
		jump y_no_coll ~ y_no_diff;
			put vy = neg(vy) ~* damping;
			lab y_no_coll;

		// write back velocities
		put ball.Ball::VX = vx;
		put ball.Ball::VY = vy;

        put i = i + 1;
    jump loop ~ i < Config::BALL_AMOUNT;

    coll_all_balls(balls);
}

fn draw_pixel(x, y, color)
{
    jump end ~ x > (Config::WIDTH  - 1);
    jump end ~ y > (Config::HEIGHT - 1);
    jump end ~ x < 0;
    jump end ~ y < 0;

    // render two characters side-by-side,
    // to give the apperance of a square pixel.

    set_color(color);
    set_cursor(y+1, x*2);
    IO::Print("  ");
    reset_color();

lab end;
}

fn draw_circle(x, y, diam, color)
{
	put rad  = diam / 2;
	put rad2 = rad * rad;

    put i = 0;
    put bound = diam * diam;
    lab loop;
        put ix = ((i % diam) - rad);
        put iy = ((i / diam) - rad);

        put dist = (ix * ix) + (iy * iy);

        jump skip ~ dist > (rad2 - 1);
        	put px = ix + x;
        	put py = iy + y;

	        draw_pixel(px, py, color);
        lab skip;
        put i = i + 1;
    jump loop ~ i < bound;
}

fn draw(balls, width, height)
{
    put colors = [41, 42, 43, 44, 45, 46, 47, 100, 101, 102, 103, 104, 105, 106, 107];
    buffer_start();
    reset_screen();

    put i = 0;
    lab loop;
        put ball = get_ball(balls, i);
        put x = Float::ToSigned(ball.Ball::PX);
        put y = Float::ToSigned(ball.Ball::PY);

        draw_circle(x, y, 10, colors.i);

        put i = i + 1;
    jump loop ~ i < Config::BALL_AMOUNT;

    buffer_end();
}

fn setup()
{
	

    hide_cursor();
    alt_screen_start();
}

fn cleanup()
{
    show_cursor();
    alt_screen_end();
}


fn frandom(upper_bound_int)
{
	put t = random(upper_bound_int);
	return Float::FromInt(t);
}

fn setup_balls(balls)
{
    put i = 0;
    lab loop_set_start_pos;
        put ball = get_ball(balls, i);

        put ball.Ball::PX = (frandom(Config::WIDTH  - 20)         ) ~+ (10.0);
        put ball.Ball::PY = (frandom(Config::HEIGHT - 20)         ) ~+ (10.0);
        put ball.Ball::VX = (frandom(100                ) ~* (0.2)) ~- (10.0);
        put ball.Ball::VY = (frandom(50                 ) ~* (0.1)) ~- (2.5 );

    	put i = i + 1;
    jump loop_set_start_pos ~ i < Config::BALL_AMOUNT;
}

fn disable_input_buffering()
{
	static TermCtl::Termios ~ ts;
	syscall(
		SYSCALL::IOCTL,
		IO::STD::IN,
		TermCtl::Op::GETS,
		ts,
	);

	put ((ts + TermCtl::Termios::LFLAG).0) = 
		((ts + TermCtl::Termios::LFLAG).0) ^
		    TermCtl::Termios::Flags::ICANON;

	syscall(
		SYSCALL::IOCTL,
		IO::STD::IN,
		TermCtl::Op::SETS,
		ts,
	);
}

fn no_key_pressed()
{
    static Poll::Struct ~ pd;
    put (pd + Poll::Struct::FD    ).0 = IO::STD::IN;
    put (pd + Poll::Struct::EVENTS).0 = Poll::Event::POLLIN;

    disable_input_buffering();
	return syscall(SYSCALL::POLL, pd, 1, 0) < 1;
}

fn main()
{
    setup();

    static (Config::BALL_AMOUNT * Ball) ~ balls;
	setup_balls(balls);

    lab game_loop;
        draw(balls);
        update(balls, (1.0) ~/ (5.0));

        sleep(0, 16);
    jump game_loop ~ no_key_pressed();

    cleanup();
}
