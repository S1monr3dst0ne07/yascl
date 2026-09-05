
use "lib/chunk.yap"

// super cool shape example.
// destructors and batteries not included.

seq Data::Circle
{
	RADIUS,
}
seq Data::Rect
{
	HEIGHT,
	WIDTH
}

seq Shape::Kind
{
	CIRCLE, RECT,
}

seq Shape
{
	KIND, // ShapeKind
	DATA,
}

fn Make::Rect(height, width)
{
	put data = Chunk::New(Data::Rect);
	put data.Data::Rect::HEIGHT = height;
	put data.Data::Rect::WIDTH  = width;
	
	put shape = Chunk::New(Shape);
	put shape.Shape::KIND = Shape::Kind::RECT;
	put shape.Shape::DATA = data;
	
	return shape;
}
fn Make::Circle(radius)
{
	put data = Chunk::New(Data::Circle);
	put data.Data::Circle::RADIUS = radius;
	
	put shape = Chunk::New(Shape);
	put shape.Shape::KIND = Shape::Kind::CIRCLE;
	put shape.Shape::DATA = data;
	
	return shape;
}

fn Area(shape)
{
	put kind = shape.Shape::KIND;
	put data = shape.Shape::DATA;
	
	jump kind_circle ~ kind == Shape::Kind::CIRCLE;
	jump kind_rect   ~ kind == Shape::Kind::RECT;
    jump empty;
	
	lab kind_circle;
		return (data.Data::Circle::RADIUS) * 6; // close enough to 2pi lol
	lab kind_rect;
		return (data.Data::Rect::HEIGHT) * (data.Data::Rect::WIDTH);
    lab empty;
        return 0;
}



fn main()
{

    put shapeA = Make::Circle(10);
    put shapeB = Make::Rect(2, 3);

    put areaA = Area(shapeA);
    put areaB = Area(shapeB);

    print("area a: %d\n", [areaA]);
    print("area b: %d\n", [areaB]);

}

