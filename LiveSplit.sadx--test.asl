state("sonic")
{
	byte state: 0x36BDC7C; //+0x400000
	byte results: 0x509FB4;
	byte cutscene: 0x509FB0;
	byte levelState: 0x3722DE4;
}

startup
{
    settings.Add("miniboss", false, "Enable split for minibosses");
}

start
{
	return current.state != old.state && old.state == 0x0C;
}

split
{
	if (settings["miniboss"])
		return current.results == 0 && old.results == 1 && current.cutscene == 1;
	else
		return current.results == 0 && old.results == 1 && current.cutscene == 1 && current.state != 5;
}