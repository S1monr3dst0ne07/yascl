

use "lib/bool.yap"


fn Frac::Make(num, den, sgn)
{
    lab norm_loop;
        jump norm_good ~ ((num >> 32) | (den >> 31)) == 0;
        put num = num >> 1;
        put den = den >> 1;
        jump norm_loop;
    lab norm_good;

    return (sgn << 63) | (num << 31) | den;
}


fn Frac::Num(x)
{
    return (x >> 31) & ((0 - 1) >> 32);
}
fn Frac::Den(x)
{
    return x & ((0 - 1) >> 33);
}
fn Frac::Sgn(x)
{
    return x >> 63;
}


fn Frac::Apply(val, sgn)
    // apply sign to value.
    // encoding into 2's complement.
    // sgn in {0, 1}!
{
    return (val - sgn) ^ (0 - sgn);
}


fn Frac::Neg(x)
{
    return x ^ (1 << 63);
}

fn Frac::Add(a, b)
{
    put common = Frac::Den(a) * Frac::Den(b);

    put x = Frac::Apply(Frac::Num(a) * Frac::Den(b), Frac::Sgn(a));
    put y = Frac::Apply(Frac::Num(b) * Frac::Den(a), Frac::Sgn(b));

    put sum = x + y;

    put sgn = sum >> 63;
    put abs = Frac::Apply(sum, sgn);

    return Frac::Make(abs, common, sgn);
}

fn Frac::Mul(a, b)
{
    put num = Frac::Num(a) * Frac::Num(b);
    put den = Frac::Den(a) * Frac::Den(b);
    put sgn = Frac::Sgn(a) ^ Frac::Sgn(b);

    return Frac::Make(num, den, sgn);
}

fn Frac::Reci(x)
{
    put num = Frac::Den(x);
    put den = Frac::Num(x);
    put sgn = Frac::Sgn(x);
    return Frac::Make(num, den sgn);
}


fn Frac::Cmp(big, small)
{
    put sgn_big   = Frac::Sgn(big);
    put sgn_small = Frac::Sgn(small);

    jump sign_good ~ sgn_big <  sgn_small;
    jump sign_good ~ sgn_big == sgn_small;
        return Bool::FALSE;
    lab sign_good;

    put big_scaled   = Frac::Num(big)   * Frac::Den(small);
    put small_scaled = Frac::Num(small) * Frac::Den(big);

    return big_scaled > small_scaled;
}


