
// 3d vector class from 
// https://raytracing.github.io/books/RayTracingInOneWeekend.html


seq Vec3 { X, Y, Z }

fn Vec3::MakeZero()
{
	return Chunk::New(Vec3);
}

fn Vec3::Make(x, y, z)
{
	put v = Vec3::MakeZero();
	put v.Vec3::X = x;
	put v.Vec3::Y = y;
	put v.Vec3::Z = z;
	return v;
}

fn Vec3::Copy(v)
{
	return Vec3::Make(
		v.0, v.1, v.2,
	);
}

fn Vec3::Neg(v)
{
	put minus_one = (1.0) ~- (0.0);
	put v.0 = minus_one ~- (v.0);
	put v.1 = minus_one ~- (v.1);
	put v.2 = minus_one ~- (v.2);
}

fn Vec3::IAdd(a, b)
{
	put a.0 = (a.0) ~+ (b.0);
	put a.1 = (a.1) ~+ (b.1);
	put a.2 = (a.2) ~+ (b.2);
}

fn Vec3::IScale(v, scalar)
{
	put v.0 = (v.0) ~* scalar;
	put v.1 = (v.1) ~* scalar;
	put v.2 = (v.2) ~* scalar;
}

fn Vec3::IScaleInv(v, scalar)
{
	Vec3::IScale(v, (1.0) ~/ scalar);
}

fn Vec3::Add(this, other)
{
	put out = Vec3::Copy(this);
	put out.0 = (out.0) ~+ (other.0);
	put out.1 = (out.1) ~+ (other.1);
	put out.2 = (out.2) ~+ (other.2);
	return out;
}
fn Vec3::Sub(this, other)
{
	put out = Vec3::Copy(this);
	put out.0 = (out.0) ~- (other.0);
	put out.1 = (out.1) ~- (other.1);
	put out.2 = (out.2) ~- (other.2);
	return out;
}
fn Vec3::Mul(this, other)
{
	put out = Vec3::Copy(this);
	put out.0 = (out.0) ~* (other.0);
	put out.1 = (out.1) ~* (other.1);
	put out.2 = (out.2) ~* (other.2);
	return out;
}
fn Vec3::Scale(this, scalar)
{
	put out = Vec3::Copy(this);
	Vec3::IScale(out, scalar);
	return out;
}
fn Vec3::ScaleInv(this, scalar)
{
	put out = Vec3::Copy(this);
	Vec3::IScaleInv(out, scalar);
	return out;
}



// --- vector specific stuff ---

fn Vec3::Dot(u, v)
{
    return ((u.0) ~* (v.0)) ~+
           ((u.1) ~* (v.1)) ~+
           ((u.2) ~* (v.2))  ;
}

fn Vec3::Length2(v)
{
	return Vec3::Dot(v, v);
}

fn Vec3::Length(v)
{
	return Float::Sqrt(Vec3::Length2(v));
}

fn Vec3::Cross(u, v)
{
	return Vec3::Make(
		((u.1) ~* (v.2)) ~- ((u.2) ~* (v.1)),
		((u.2) ~* (v.0)) ~- ((u.0) ~* (v.2)),
		((u.0) ~* (v.1)) ~- ((u.1) ~* (v.0)),
	);
}

fn Vec3::Normalize(v)
{
	return Vec3::ScaleInv(v, Vec3::Length(v));
}

fn Vec3::Format(v)
{
	static 4096 ~ buffer;
	Str::Format(buffer, 
		"%f %f %f",
		[v.0, v.1, v.2]
	);
	return buffer;
}


