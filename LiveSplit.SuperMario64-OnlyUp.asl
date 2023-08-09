state("project64")
{
	short Stars : 0xD6A1C, 0x18DFDC;
	int time: "project64.exe", 0xD6A1C, 0x37d620;
	byte isPaused: "project64.exe", 0xD75E4;
}

startup
{
}

init
{
	refreshRate = 30;
}

start
{
	return current.time > 5;
}

reset
{
	return old.time > current.time;
}

split
{
	if (current.Stars > 8)
		return false;

	if (current.Stars < 0)
		return false;

	return timer.CurrentSplitIndex <= (current.Stars - 1);
}

isLoading
{
	return current.isPaused == 0;
}
