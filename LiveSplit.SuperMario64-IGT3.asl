state("project64")
{
	int igt: "Project64.exe", 0xD6A1C, 0x32D580;
	byte isPaused: "Project64.exe", 0xD75E4;
}

init
{
	vars.ResetIGTFixup = 0;
	refreshRate = 30;
}

start
{
	return current.igt < old.igt;
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
				if (current.igt < old.igt) //Reset happened
				{ 
					vars.ResetIGTFixup += old.igt;
				}
			}else{
				vars.ResetIGTFixup = 0;
				if (current.igt > relaxFrames)
					return TimeSpan.FromMilliseconds(0); 
			}
		}catch(Exception) {
			vars.ResetIGTFixup = 0;
		}
		return TimeSpan.FromSeconds((double)(vars.ResetIGTFixup + current.time) / 60);
	}
	else
	{
		vars.ResetIGTFixup = timer.CurrentTime.GameTime.Value.TotalSeconds * 60 - current.igt;
	}
}