state("project64") { }
state("retroarch") { }

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

    vars.baseRAMAddressFound  = false;
    vars.stopwatch = new Stopwatch();
    vars.ADDRESS_SEARCH_INTERVAL = 1000;
    vars.baseRAMAddress = IntPtr.Zero;
	
    vars.retroarch = false;
	if (game.ProcessName.Contains("retroarch"))
	{
		vars.retroarch = true;
	}
	
	vars.verifyRetriesLeft = 0;
}

start
{
	vars.split = 0;
	if (settings["LI"])
		return (old.level == 35 && current.level == 16);
	else{
		if(settings["DelA"] && (current.level == 1 || current.level == 0) && current.time < 20)
			vars.deleteFile = true;
		return ((current.level == 1 || current.level == 0) && current.time < 20);
	}
}

reset
{
	String splitName = timer.CurrentSplit.Name;
	char lastSymbol = splitName.Last();
	if (settings["LI"]){
		return (old.level == 35 && current.level == 16 && current.stars == 0);
	}else if ((current.level == 1 || current.level == 0) && (old.time > current.time)){
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
		else if (lastSymbol == ')' && old.stars < current.stars)
		{
			print("Star trigger!");
			char[] separators = {'(', ')', '[', ']'};
 
			String splitStarCounts = splitName.Split(separators, StringSplitOptions.RemoveEmptyEntries).Last();
		
			int splitStarCount = -1;
			Int32.TryParse(splitStarCounts, out splitStarCount);
			
			if (splitStarCount == current.stars && !isKeySplit) //Postpone key split to later
				vars.split = 1;
		} 
		else if (lastSymbol == ']' && old.level != current.level && old.level != 1)
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
		else if (isKeySplit && (current.level == 30 || current.level == 33 || current.level == 34) && old.anim != current.anim && current.anim == 4866) //Key grab animation == 4866
		{
			print("Key split trigger!");
			char[] separators = {'(', ')', '[', ']', '*'};

			String splitStarCounts = splitName.Split(separators, StringSplitOptions.RemoveEmptyEntries).Last();
		
			int splitStarCount = -1;
			Int32.TryParse(splitStarCounts, out splitStarCount);
			
			if (splitStarCount == current.stars)
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
	if (!vars.baseRAMAddressFound)
	{
		if (!vars.stopwatch.IsRunning || vars.stopwatch.ElapsedMilliseconds > vars.ADDRESS_SEARCH_INTERVAL)
		{
			vars.stopwatch.Start();
			vars.baseRAMAddress = IntPtr.Zero;

			if (!vars.retroarch)
			{
				// hardcoded values because GetSystemInfo / GetNativeSystemInfo can't return info for remote process
				var min = 0x10000L;
				var max = game.Is64Bit() ? 0x00007FFFFFFEFFFFL : 0xFFFFFFFFL;

				var mbiSize = (UIntPtr) 0x30; // Clueless

				var addr = min;
				do
				{
					MemoryBasicInformation mbi;
					if (WinAPI.VirtualQueryEx(game.Handle, (IntPtr)addr, out mbi, mbiSize) == (UIntPtr)0)
						break;

					addr += (long)mbi.RegionSize;

					if (mbi.State != MemPageState.MEM_COMMIT)
						continue;

					if ((mbi.Protect & MemPageProtect.PAGE_GUARD) != 0)
						continue;

					if (mbi.Type != MemPageType.MEM_PRIVATE)
						continue;
					
					if (((int) mbi.Protect & (int) 0xcc) == 0)
						continue;

					uint val;
					if (!game.ReadValue(mbi.BaseAddress, out val))
					{
						continue;
					}
					if ((val & 0xfffff000) == 0x3C1A8000)
					{
						vars.baseRAMAddress = mbi.BaseAddress;
						break;
					}
				} while (addr < max);

			}
			else
			{
				var parallelModule = modules.Where(x => x.ModuleName.Contains("parallel_n64")).First();
				var parallelStart = (long) parallelModule.BaseAddress;
				for (long num = 0; num < (long) parallelModule.ModuleMemorySize / 0x1000; num++)
				{
					uint val;
					var addr = (IntPtr) (parallelStart + num * 0x1000);
					if (!game.ReadValue(addr, out val))
					{
						continue;
					}
					if ((val & 0xfffff000) == 0x3C1A8000)
					{
						vars.baseRAMAddress = addr;
						break;
					}
				}
			}

			if (vars.baseRAMAddress == IntPtr.Zero)
			{
				vars.stopwatch.Restart();
				return false;
			}
			else
			{
				vars.stopwatch.Reset();
				vars.baseRAMAddressFound = true;
			}
		}
		else
		{
			return false;
		}
	}

	// Verify base RAM address is still valid on each update
	uint tval;
	if (!game.ReadValue((IntPtr) vars.baseRAMAddress, out tval))
	{
		vars.baseRAMAddressFound = false;
		vars.baseRAMAddress = IntPtr.Zero;
		return false;
	}

	if ((tval & 0xfffff000) != 0x3C1A8000)
	{
		if (0 == (vars.verifyRetriesLeft--))
		{
			vars.baseRAMAddressFound = false;
			vars.baseRAMAddress = IntPtr.Zero;
		}
		return false;
	}
	else
	{
		vars.verifyRetriesLeft = 100;
	}

	vars.starsAddress = vars.baseRAMAddress + 0x1c6b14;
	vars.levelAddress = vars.baseRAMAddress + 0x1b8fa2;
	vars.musicAddress = vars.baseRAMAddress + 0xe1382;
	vars.animAddress  = vars.baseRAMAddress + 0x1c6a78;
	vars.timeAddress  = vars.baseRAMAddress + 0x10d020;

	vars.igtSaveFileAddress    = vars.baseRAMAddress + 0x4CDA4;
	vars.igtTimerOffsetAddress = vars.baseRAMAddress + 0x1b8f9c;
	vars.igtGlobalTimerAddress = vars.baseRAMAddress + 0x1b8ea0;

	current.stars = memory.ReadValue<byte>((IntPtr) vars.starsAddress);
	current.level = memory.ReadValue<byte>((IntPtr) vars.levelAddress);
	current.music = memory.ReadValue<byte>((IntPtr) vars.musicAddress);
	current.anim  = memory.ReadValue<int> ((IntPtr) vars.animAddress);
	current.time  = memory.ReadValue<int> ((IntPtr) vars.timeAddress);
	
	current.igtSaveFile    = memory.ReadValue<int>((IntPtr) vars.igtSaveFileAddress);
	current.igtTimerOffset = memory.ReadValue<int>((IntPtr) vars.igtTimerOffsetAddress);
	current.igtGlobalTimer = memory.ReadValue<int>((IntPtr) vars.igtGlobalTimerAddress);
	
	if (!vars.forceSplit)
		vars.forceSplit = current.time < old.time;
	if (vars.deleteFile)
	{
		if (current.time < 4 * 60) {
			vars.split = 0;
			byte[] data = Enumerable.Repeat((byte)0x00, 0x78).ToArray();
			IntPtr ptr = vars.baseRAMAddress + 0x4cda0;
			if (!game.WriteBytes(ptr, data))
			{ 
				vars.errorCode |= 2;
				print("write fail");
			}
			vars.delay = -1;
		}else{
			if (current.time < 5 * 60)
				vars.deleteFile = false;
		}
	}
}

isLoading
{
	return true;
}

gameTime
{
	if (current.igtTimerOffset == 0 || current.level == 1)
	{
		return TimeSpan.FromSeconds(current.igtSaveFile / 30.0);
	}
	else
	{
		return TimeSpan.FromSeconds((current.igtSaveFile + current.igtGlobalTimer - current.igtTimerOffset) / 30.0);
	}
}
