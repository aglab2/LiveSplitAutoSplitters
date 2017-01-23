# Super Mario 64 ASL script usage
This ASL script use notation in splits to detect time to split. All special symbols are detected at the end of segment name. Splitter supports resets, starts, auto splitting on notations. Autosplitter does not support last split on star collect.

#Adding AutoSplitter to LiveSplit
Download autosplitter file from repository using Raw button [link](https://raw.githubusercontent.com/aglab2/LiveSplitAutoSplitters/master/LiveSplit.SuperMario64.asl). Right Click on LiveSplit, select _Edit Layout..._. In appeared window press _+_ button, choose _Control_ > _Scriptable Auto Splitter_. Double left click on _Scriptable Auto Splitter_ item and choose script path with _Browse..._ button. Depending on hack, check Last Impact start mode. 

#List of special symbols:
(STAR_COUNT): Split will be fired on fadeout after STAR_COUNT. Put "key" keyword anywhere in split name, for example: "Shadow Mario Key (20)" to fire split on key get rather then 20th star get.

[LEVEL_NUMBER]: Split will be fired on fadeout on enter to LEVEL_NUMBER.

*: Split will be fired on key/troll star grab

#Script Example
I have made an example for Last Impact [20 star splits](https://splits.io/10je).

#TODO
Add tutorial on finding LEVEL_NUMBER
Add support for pj64 1.7
