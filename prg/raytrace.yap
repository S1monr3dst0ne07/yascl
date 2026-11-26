
use "lib/fs.yap"
use "lib/debug.yap"
use "lib/vec3.yap"

// raytracer demo.
// one ball, illuminated by one light source.
// run like: `./yascl prg/raytrace.yap && feh /tmp/image.ppm`

seq Ctx
{
	WIDTH,
	HEIGHT,

	ASPECT,  // aspect factor between widht and height
	FRAME,   // output pixel buffer
	RADIUS,  // sphere radius
	BLUR,    // blur factor
	LIGHT,   // position of light

	COL_BACKGROUND,
	COL_LIGHT,
	COL_AMIBENT,
}

fn expand(f)
{
	return (f ~* (2.0)) ~- (1.0);
}

fn shader(ctx, screen_u, screen_v)
{
	put radius      = ctx.Ctx::RADIUS;
	put inv_rad     = (1.0) ~/ radius;

	// project screen-space to uv world-space.
	put u =            expand(screen_u) ~* inv_rad ~* ctx.Ctx::ASPECT;
	put v = Float::Neg(expand(screen_v) ~* inv_rad);

	// default color is background color.
	put color = Vec3::Copy(ctx.Ctx::COL_BACKGROUND);

	// compute distance from origin,
	// where sphere sits. this is in uv world-space.
	put origin_dist2 = (u ~* u) ~+ (v ~* v);
	put origin_dist  = Float::Sqrt(origin_dist2);
		
// check sphere-ray collision.
jump done ~ origin_dist ~> (1.0);
	Chunk::Void(color); // free background color

	// from where on out, we can assume the sphere
	// as been hit. compute sphere surface normal.
	put world_z = Float::Sqrt((1.0) ~- origin_dist2);
	put normal  = Vec3::Make(u, v, world_z);

	put diffusion = Float::Clamp(
		Vec3::Dot(normal, ctx.Ctx::LIGHT),
		0.0, 1.0);

	// light = light_color * diffusion + ambient
	put t1    = Vec3::Scale(ctx.Ctx::COL_LIGHT, diffusion);
	put light = Vec3::Add(ctx.Ctx::COL_AMIBENT, t1);
	Chunk::Void(t1);

	// blur color into background at perimeter
	put perim_dist = (1.0) ~- origin_dist;
	put mix = Float::Clamp((ctx.Ctx::BLUR) ~/ perim_dist, 0.0, 1.0);

	// color = light * (1.0 - mix) + bg * mix
	put t1 = Vec3::Scale(light                  , (1.0) ~- mix);
	put t2 = Vec3::Scale(ctx.Ctx::COL_BACKGROUND,          mix);

	put color = Vec3::Add(t1, t2);
	Chunk::Void(t1);
	Chunk::Void(t2);

lab done;
	return color;
}

fn render(ctx)
{
	put width  = ctx.Ctx::WIDTH;
	put height = ctx.Ctx::HEIGHT;
	put frame  = ctx.Ctx::FRAME;

	put f_width  = Float::FromInt(width);
	put f_height = Float::FromInt(height);

	// compute aspect factor
	put ctx.Ctx::ASPECT = f_width ~/ f_height;

	put write_index = 0;

	put y = 0;
	lab loop_y;
		put x = 0;
		lab loop_x;
			put col = shader(ctx
				Float::FromInt(x) ~/ f_width, 
				Float::FromInt(y) ~/ f_height, 
			);

			put frame.(write_index+0) = Float::ToInt((col.0) ~* (255.999));
			put frame.(write_index+1) = Float::ToInt((col.1) ~* (255.999));
			put frame.(write_index+2) = Float::ToInt((col.2) ~* (255.999));
			put write_index = write_index + 3;

			Chunk::Void(col);

			put x = x + 1;
		jump loop_x ~ x < width;
			print("%d %d\n", [x, y]);
		put y = y + 1;
	jump loop_y ~ y < height;
}

fn frame_byte_count(ctx)
{
	return (ctx.Ctx::WIDTH) * (ctx.Ctx::HEIGHT) * 3;
}


fn write_image(ctx)
{
	put fd = FS::Sys::Open(
		"/tmp/image.ppm",
		FS::Mode::RDWR | FS::Mode::CREATE | FS::Mode::TRUNC,
		FS::Permissions::READ_WRITE,
	);

	static 256 ~ header;
	Str::Format(header, "P6\n%d %d\n255\n", [
		ctx.Ctx::WIDTH, ctx.Ctx::HEIGHT, 
	]);

	IO::Write(fd, header,        Str::Len(header)     );
	IO::Write(fd, ctx.Ctx::FRAME,frame_byte_count(ctx));

	FS::Sys::Close(fd);
}

fn main()
{
	put ctx = Chunk::New(Ctx);

	put ctx.Ctx::RADIUS = 0.7;
	put ctx.Ctx::BLUR   = 0.01;

	put ctx.Ctx::COL_BACKGROUND = Vec3::Make(0.2 , 0.2, 0.2);
	put ctx.Ctx::COL_LIGHT      = Vec3::Make(0.9 , 0.8, 0.6);
	put ctx.Ctx::COL_AMIBENT    = Vec3::Make(0.05, 0.1, 0.2);

	put ctx.Ctx::LIGHT = Vec3::Normalize(Vec3::Make(1.0, 1.0, 1.0));

	put ctx.Ctx::WIDTH  = 1920;
	put ctx.Ctx::HEIGHT = 1080;

	put ctx.Ctx::FRAME = Chunk::New(frame_byte_count(ctx));

	render(ctx);
	write_image(ctx);
}



