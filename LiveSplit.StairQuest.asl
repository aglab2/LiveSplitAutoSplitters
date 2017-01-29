state("stair-quest")
{
	int score: "stair-quest.exe", 0x37FAA0;
}

startup
{
}

init
{
}

start
{
}

reset
{
	return (old.score > current.score);
}

split
{
	return (old.score < current.score);
}

isLoading
{
	return false;
}

