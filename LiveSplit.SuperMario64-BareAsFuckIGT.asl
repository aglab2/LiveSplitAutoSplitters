state("project64")
{
	int igt: "Project64.exe", 0xD6A1C, 0x32D580;
}

init
{
	refreshRate = 30;
}

gameTime
{
	return TimeSpan.FromSeconds((double)current.igt / 60.0416);
}