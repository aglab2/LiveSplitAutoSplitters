state("sonic")
{
	byte state: 0x36BDC7C;
}

start
{
	return current.state != old.state && old.state == 0x0C;
}