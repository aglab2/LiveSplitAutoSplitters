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
	settings.Add("DelA", false, "Delete File A on game reset");
	settings.Add("LastSplit", true, "Split on final split when Grand Star or regular star was grabbed");
}

init
{
	vars.split = 0;
	vars.delay = -1;
	vars.lastSymbol = (char) 0;
	
	vars.errorCode = 0;
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
	if (settings["LI"]){
		return (old.level == 35 && current.level == 16 && current.Stars == 0);
	}else if (current.level == 1 && old.time > current.time){
		return true;
	}
}

split
{
	//print(current.anim.ToString());
	if (vars.split == 0){
		String splitName = timer.CurrentSplit.Name;
		char lastSymbol = splitName.Last();
		bool isKeySplit = (splitName.ToLower().IndexOf("key") != -1) || (lastSymbol == '*');
		
		if (timer.Run.Count - 1 == timer.CurrentSplitIndex && (current.anim == 6409 || current.anim == 6404 || current.anim == 4866 || current.anim == 4871))
		{
			if (settings["LastSplit"])
				return true;
		}
		else if (lastSymbol == ')' && old.Stars < current.Stars)
		{
			print("Star trigger!");
			char[] separators = {'(', ')', '[', ']'};
 
			String splitStarCounts = splitName.Split(separators, StringSplitOptions.RemoveEmptyEntries).Last();
		
			int splitStarCount = -1;
			Int32.TryParse(splitStarCounts, out splitStarCount);
			
			if (splitStarCount == current.Stars && !isKeySplit) //Postpone key split to later
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
		else if (isKeySplit && old.anim != current.anim && current.anim == 4866) //Key grab animation == 4866
		{
			print("Key split trigger!");
			char[] separators = {'(', ')', '[', ']', '*'};

			String splitStarCounts = splitName.Split(separators, StringSplitOptions.RemoveEmptyEntries).Last();
		
			int splitStarCount = -1;
			Int32.TryParse(splitStarCounts, out splitStarCount);
			
			if (splitStarCount == current.Stars)
				vars.split = 5;
		}
	}

	if (vars.split == 1)
	{
		String splitName = timer.CurrentSplit.Name;
		print(current.anim.ToString()); 
		if (current.level != old.level || (old.anim != current.anim && old.anim == 4866) || (old.anim != current.anim && old.anim == 4867) || (old.anim != current.anim && old.anim == 4871) || (old.anim != current.anim && old.anim == 4866)){
			vars.split = -20;
			return true;
		}
	}
	
	if (vars.split > 1)
		vars.split--;
		
	if (vars.split < 0)
		vars.split++;
}

update
{
	if (settings["DelA"] && current.time > 60 && current.time < 200)
	{
		byte[] data = Enumerable.Repeat((byte)0x00, 0x70).ToArray();
		//DeepPointer fileA = new DeepPointer("Project64.exe", 0xD6A1C, 0x207708); //TODO: this is better solution
        IntPtr ptr;
		
		var module =  modules.FirstOrDefault(m => m.ModuleName.ToLower() == "project64.exe");
		ptr = module.BaseAddress + 0xD6A1C;
		
		if (!game.ReadPointer(ptr, false, out ptr) || ptr == IntPtr.Zero)
        {
			vars.errorCode |= 1;
		    print("readptr fail");
        }
		ptr += 0x207708;
        if (!game.WriteBytes(ptr, data))
        { 
			vars.errorCode |= 2;
		    print("write fail");
        }
		vars.delay = -1;
	}
}

isLoading
{
	return true;
}

gameTime
{
	return new TimeSpan(vars.errorCode, 0, 0);
}

