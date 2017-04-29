state("sonic")
{
	byte state: 0x36BDC7C; //+0x400000
	byte7 storiesCompletion: 0x03718850;
	byte19 sonicCompletion: 0x037188AC;
	byte13 tailsCompletion: 0x03B188E7;
	byte8 knucklesCompletion: 0x03B18927;
	byte4 amyCompletion: 0x03B1895E;
	byte8 gammaCompletion: 0x03B189A2;
	byte5 bigCompletion: 0x03B189DD;
}

start
{
	return current.state != old.state && old.state == 0x0C;
}

split
{
	return 
		!Enumerable.SequenceEqual(current.storiesCompletion, old.storiesCompletion) ||
		!Enumerable.SequenceEqual(current.sonicCompletion, old.sonicCompletion) ||
		!Enumerable.SequenceEqual(current.tailsCompletion, old.tailsCompletion) ||
		!Enumerable.SequenceEqual(current.knucklesCompletion, old.knucklesCompletion) ||
		!Enumerable.SequenceEqual(current.amyCompletion, old.amyCompletion) ||
		!Enumerable.SequenceEqual(current.gammaCompletion, old.gammaCompletion) ||
		!Enumerable.SequenceEqual(current.bigCompletion, old.bigCompletion);
}