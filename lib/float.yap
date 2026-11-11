
// "BLESSED BE YE,
//    who read this file and have
//    no idea how it works." - me

// "CURSED BE YE,
//    who have to maintain this,
//    haha lol." - idk, satan or smth

use "lib/str.yap"
use "lib/astr.yap"

fn Float::FromInt(man)
	// warning! slow!
	// don't use for constants.
{
	jump zero ~ man == 0;

	put exp = 0;
	lab loop;
		put msb = man >> 63;
		put exp = exp + 1;
		put man = man << 1;
	jump loop ~ msb == 0;

	return (man >> 12) | ((1023 + 64 - exp) << 52);

lab zero;
	return 0;
}

fn Float::ToInt(float)
{
	put exp_raw = (float >> 52) & ((1 << 11) - 1);
	put man = (float & ((1 << 52) - 1)) | (1 << 52);
	put exp_shift = (52 - (exp_raw - 1023));

	jump subnormal ~ exp_shift > 63;
	return man >> exp_shift;

lab subnormal;
	return 0;
}

fn Float::ToSigned(float)
{
	put sign = float >> 63;
	put int = Float::ToInt(float);
	jump pos ~ sign == 0;
		put int = 0 - int;
	lab pos;
	return int;
}


fn Float::IntPow(base, power)
{
	jump pos ~ (power >> 63) == 0;
		put power = 0 - power;
		put base  = (1.0) ~/ base;
	lab pos;

	put res = 1.0;
	lab loop; jump done ~ power == 0;
		put power = power - 1;
		put res   = res ~* base;
	jump loop; lab done;

	return res;
}

fn Float::ToStr(float, prec)
{
	put output = AStr::Create();

	// sign
	jump positive ~ (float & (1 << 63)) == 0;
	AStr::AppendChar(output, '-');

	lab positive;

	// real part
	AStr::AppendStr(
		output
		Str::FromIntBase(
			Float::ToInt(float),
			10
		),
	);

	// radix
	AStr::AppendChar(output, '.');

	// frac part
	put prec_scale = Float::IntPow(10.0, prec);
	put frac = Float::ToInt((float ~% (1.0)) ~* prec_scale);
	put str = Str::FromIntBase(frac, 10);
	put len = Str::Len(str);

	AStr::AppendCharTimes(output, '0', prec - len);
	AStr::AppendStr     (output, str);
	AStr::AppendChar    (output, '\0');
	
	return AStr::DetachStr(output);
}



fn Float::BabSqrtIter(x, n)
	// assuming n > 0
{
	put r = 1.0;
	lab loop;
		put r = (r ~+ (x ~/ r)) ~* (0.5);
		
		put n = n - 1;
	jump loop ~ n;

	return r;
}

fn Float::BabSqrt(x)
{
	return Float::BabSqrtIter(x, 10);
}


seq Float::FastSqrt
{
	MAGIC = 2303591209400008704,
}

fn Float::FastSqrt(x)
{
	// the mantissa must be in the interal [1,2).
	// given that the square root function is monotonic,
	// the image of the mantissa must be 
	// 		[√1, √2) =~ [1, 1.414)
	// this interval is small enough to be recovered by newton-raphson.
	// hence we can ignore the mantissa for now.

	// now consider the remaining work.
	// let b be the exponent bias
	// and m be the physical mantissa bit count.
	// then exp = (x >> m) - b
	//   sqrt(x)                       | by halving of exponent
	// = (((x >> m) - b) / 2 + b) << m | distribute outer bitshift
	// = (x - (b << m)) / 2 + (b << m) | distribute halving
	// = x/2 + (b << (m - 1))
	// now substitude b=1023 and m=52 according to IEEE 754.
	// and perform exponent halving by bitshift
	// = (x >> 1) + (1023 << 51)

	// pure dark magic. also known as math.
	put t = (x >> 1) + Float::FastSqrt::MAGIC;
	
	// newton-raphson refinement.
	put t = (t ~+ (x ~/ t)) ~* (0.5);

	return t;
}

fn Float::Sqrt(x)
{
	// default square root.
	// change algorithm here.
	return Float::FastSqrt(x);
}


