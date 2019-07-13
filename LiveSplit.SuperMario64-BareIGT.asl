state("project64")
{
	int igt: "Project64.exe", 0xD6A1C, 0x32D580;
}

init
{
	vars.ResetIGTFixup = 0;
	refreshRate = 30;
}

isLoading
{
	return true;
}

gameTime
{
	int relaxMilliseconds = 5000;
	int relaxFrames = relaxMilliseconds * 60 / 1000;
	
	try{
		if (timer.CurrentTime.RealTime.Value.TotalMilliseconds > relaxMilliseconds) {
			if (current.igt < old.igt)
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
	return TimeSpan.FromSeconds((double)(vars.ResetIGTFixup + current.igt) / 60.0416);
}