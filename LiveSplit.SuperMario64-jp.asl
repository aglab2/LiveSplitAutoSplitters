state("project64")
{
	byte Stars : "project64.exe", 0xD6A1C, 0x339EA8;
	byte level : "project64.exe", 0xD6A1C, 0x32ce9A;
	byte music : "project64.exe", 0xD6A1C, 0x222a1E;
	int anim: "project64.exe", 0xD6A1C, 0x339e0C;
	int time: "project64.exe", 0xD6A1C, 0x32c640;
	byte isPaused: "project64.exe", 0xD75E4;
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
	vars.deleteFile = false;
	
	refreshRate = 30;
	
	vars.errorCode = 0;
	vars.ResetIGTFixup = 0;
	vars.forceSplit = false;
}

start
{
	vars.split = 0;
	if (settings["LI"])
		return (old.level == 35 && current.level == 16);
	else{
		if(settings["DelA"] && current.level == 1 && old.time > current.time)
			vars.deleteFile = true;
		return (current.level == 1 && old.time > current.time);
	}
}

reset
{
	String splitName = timer.CurrentSplit.Name;
	char lastSymbol = splitName.Last();
	if (settings["LI"]){
		return (old.level == 35 && current.level == 16 && current.Stars == 0);
	}else if (current.level == 1 && old.time > current.time){
		return lastSymbol != 'R';
	}
}

split
{
	if (vars.split == 0){
		String splitName = timer.CurrentSplit.Name;
		char lastSymbol = splitName.Last();
		bool isKeySplit = (splitName.ToLower().IndexOf("key") != -1) || (lastSymbol == '*');
		
		if (settings["LastSplit"] && timer.Run.Count - 1 == timer.CurrentSplitIndex && (current.anim == 6409 || current.anim == 6404 || current.anim == 4866 || current.anim == 4871))
		{
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
		else if (lastSymbol == 'R')
		{
			print("Reset trigger!");
			if (vars.forceSplit) {
				vars.forceSplit = false;
				return true;
			}
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
		vars.forceSplit = false;
		String splitName = timer.CurrentSplit.Name;
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
	if (!vars.forceSplit)
		vars.forceSplit = current.time < old.time;
	if (vars.deleteFile)
	{
		if (timer.CurrentTime.RealTime.Value.TotalSeconds < 4) {
			vars.split = 0;
			byte[] data = Enumerable.Repeat((byte)0x00, 0x70).ToArray();
			//DeepPointer fileA = new DeepPointer("project64.exe", 0xD6A1C, 0x207708); //TODO: this is better solution
			IntPtr ptr;
		
			var module =  modules.FirstOrDefault(m => m.ModuleName.ToLower() == "project64.exe");
			ptr = module.BaseAddress + 0xD6A1C;
		
			if (!game.ReadPointer(ptr, false, out ptr) || ptr == IntPtr.Zero)
			{
				vars.errorCode |= 1;
				print("readptr fail");
			}
			ptr += 0x207b08;
			if (!game.WriteBytes(ptr, data))
			{ 
				vars.errorCode |= 2;
				print("write fail");
			}
			vars.delay = -1;
		}else{
			if (timer.CurrentTime.RealTime.Value.TotalSeconds < 5)
				vars.deleteFile = false;
		}
	}
}

isLoading
{
	return current.isPaused == 0;
}

gameTime
{
	if (current.isPaused == 0) 
	{
		int relaxMilliseconds = 5000;
		int relaxFrames = relaxMilliseconds * 60 / 1000;
	
		try{
			if (timer.CurrentTime.RealTime.Value.TotalMilliseconds > relaxMilliseconds) {
				if (current.time < old.time) //Reset happened 
				{ 
					print("Fixup occured");
					vars.ResetIGTFixup += old.time;
				}
			}else{
				vars.ResetIGTFixup = 0;
				if (current.time > relaxFrames)
					return TimeSpan.FromMilliseconds(0);
			}
		}catch(Exception) {
			vars.ResetIGTFixup = 0;
		}
		return TimeSpan.FromSeconds((double)(vars.ResetIGTFixup + current.time) / 60.0416);
	}
	else
	{
		vars.ResetIGTFixup = (double) timer.CurrentTime.GameTime.Value.TotalSeconds * 60.0416 - current.igt;
	}
}
