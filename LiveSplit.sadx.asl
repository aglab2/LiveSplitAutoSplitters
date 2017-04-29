state("sonic")
{
	byte state: 0x36BDC7C;
}

start
{
	return current.state != old.state && old.state == 0x0C;
}

split
{
	return current.state != old.state && current.state == 0x5 && old.state == 0x4;
}