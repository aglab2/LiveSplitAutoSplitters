state("project64")
{
	byte Stars : 0xD6A1C, 0x33B218;
	byte level : "Project64.exe", 0xD6A1C, 0x32DDFA;
	byte music : "Project64.exe", 0xD6A1C, 0x22261E;
	int anim: "Project64.exe", 0xD6A1C, 0x33B17C;
	int time: "Project64.exe", 0xD6A1C, 0x32D580;
}

startup
{
    settings.Add("LI", false, "Enable Last Impact start mode");
}

init
{
	vars.split = 0;
	vars.lastSymbol = (char) 0;
}

start
{
	vars.split = 0;
	if (settings["LI"])
		return (old.level == 35 && current.level == 16);
	else
		return (current.level == 1 && old.time > current.time);
}

reset
{
	if (settings["LI"])
		return (old.level == 35 && current.level == 16 && current.Stars == 0);
	else
		return (current.level == 1 && old.time > current.time);		
}

split
{
	if (vars.split == 0){
		String splitName = timer.CurrentSplit.Name;
		char lastSymbol = splitName.Last();	
		
		if (lastSymbol == ')' && old.Stars < current.Stars)
		{
			print("Star trigger!");
			char[] separators = {'(', ')', '[', ']'};

			String splitStarCounts = splitName.Split(separators, StringSplitOptions.RemoveEmptyEntries).Last();
		
			int splitStarCount = -1;
			Int32.TryParse(splitStarCounts, out splitStarCount);
			
			if (splitStarCount == current.Stars)
				vars.split = 1;
		}
		else if (lastSymbol == ']' && old.level != current.level)
		{
			print("Level trigger!");
			char[] separators = {'(', ')', '[', ']'};

			String splitLevelCounts = splitName.Split(separators, StringSplitOptions.RemoveEmptyEntries).Last();
		
			int splitLevelCount = -1;
			Int32.TryParse(splitLevelCounts, out splitLevelCount);
			
			if (splitLevelCount == current.level)
				vars.split = 1;		
		}
		else if (lastSymbol == '!' && old.music != current.music)
		{
			print("Music trigger!");
			if (current.music == 0)
				return true;
		}
		else if (lastSymbol == '*' && old.anim != current.anim && current.anim == 4866) //Key grab animation == 4866
		{
			print("Anim trigger!");	
			vars.split = 5;
		}
	}

	if (vars.split == 1)
	{
		if (current.level != old.level || (old.anim != current.anim && old.anim == 4864)){ //Level switching animation == 4864
			vars.split = 0;
			return true;
		}
	}
	
	if (vars.split > 1)
		vars.split--;
}

isLoading
{
	return false;
}

