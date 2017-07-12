state("sonic")
{
	byte state: 0x36BDC7C; //+0x400000
	byte7 storiesCompletion: 0x03718850;
	byte19 sonicCompletion: 0x037188AC;
	byte13 tailsCompletion: 0x037188E7;
	byte8 knucklesCompletion: 0x03718927;
	byte4 amyCompletion: 0x0371895E;
	byte8 gammaCompletion: 0x037189A2;
	byte5 bigCompletion: 0x037189DD;
	
	byte results: 0x509FB4;
	byte cutscene: 0x509FB0;
	byte gameStatus: 0x3722DE4;
	
	byte frames: 0x370EF35;
	byte minutes: 0x370EF48;
	byte seconds: 0x370F128;
}

startup
{
    settings.Add("subsplit", false, "Split on timer end for the last segment in subsplits");
	settings.Add("lastsplit", true, "Split on timer end for the last segment");
}

init{
	refreshRate = 30;
}

start
{
	return current.state != old.state && old.state == 0x0C;
}

split
{
	String splitName = timer.CurrentSplit.Name;
	bool subsplitCase  = settings["subsplit"]  && (splitName[0] != '-');
	bool lastsplitCase = settings["lastsplit"] && (timer.Run.Count - 1 == timer.CurrentSplitIndex);
	if (subsplitCase || lastsplitCase) {
		return current.frames == old.frames && current.gameStatus == 0xF && old.gameStatus == 0xF && (current.minutes != 0 || current.seconds != 0);
	}else{
		return 
			!Enumerable.SequenceEqual(current.storiesCompletion, old.storiesCompletion) ||
			!Enumerable.SequenceEqual(current.sonicCompletion, old.sonicCompletion) ||
			!Enumerable.SequenceEqual(current.tailsCompletion, old.tailsCompletion) ||
			!Enumerable.SequenceEqual(current.knucklesCompletion, old.knucklesCompletion) ||
			!Enumerable.SequenceEqual(current.amyCompletion, old.amyCompletion) ||
			!Enumerable.SequenceEqual(current.gammaCompletion, old.gammaCompletion) ||
			!Enumerable.SequenceEqual(current.bigCompletion, old.bigCompletion);
	}
}