state("project64")
{
	byte Stars      : 0xD6A1C, 0x33B218;
	int  GameFrames : 0xD6A1C, 0x32D5D4;
	byte level : "Project64.exe", 0xD6A1C, 0x32DDFA;
	byte music : "Project64.exe", 0xD6A1C, 0x22261E;
}

init
{
	vars.split = 0;
}

start
{
	vars.split = 0;
	//return (old.level == 35 && current.level == 16);
}

reset
{
	//return (old.level == 35 && current.level == 16 && current.Stars == 0);
}

split
{
	if (vars.split == 0 && old.Stars < current.Stars)
	{
		char[] separators = {'(', ')', '[', ']'};

		String splitName = timer.CurrentSplit.Name;
		String splitStarCounts = splitName.Split(separators, StringSplitOptions.RemoveEmptyEntries).Last();
		
		int splitStarCount = -1;
		Int32.TryParse(splitStarCounts, out splitStarCount);
		char lastSymbol = splitName.Last();
		
		if (lastSymbol == ')' && splitStarCount == current.Stars)
			vars.split = 1;
	}else
	if (vars.split == 0 && old.level != current.level)
	{
		char[] separators = {'(', ')', '[', ']'};

		String splitName = timer.CurrentSplit.Name;
		String splitLevelCounts = splitName.Split(separators, StringSplitOptions.RemoveEmptyEntries).Last();
		
		int splitLevelCount = -1;
		Int32.TryParse(splitLevelCounts, out splitLevelCount);
		char lastSymbol = splitName.Last();
	
		if (lastSymbol == ']' && splitLevelCount == current.level)
			vars.split = 1;		
	}else
	if (vars.split == 0 && old.music != current.music){
		String splitName = timer.CurrentSplit.Name;
		char lastSymbol = splitName.Last();
	
		if (lastSymbol == '*' && current.music == 0)
			return true;
	}

	if (vars.split > 0)
	{
		if (current.level != old.level){
			vars.split = 0;
			return true;
		}
	}
}

isLoading
{
	return false;
}

