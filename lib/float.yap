
// "BLESSED BE YE,
//    who read this file and have
//    no idea how it works." - me

// "CURSED BE YE,
//    who have to maintain this,
//    haha lol." - idk, satan or smth


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
	put exp = (float >> 52) & ((1 << 11) - 1);
	put man = float & ((1 << 52) - 1) | (1 << 52);

	return man >> (52 - (exp - 1023));
}







