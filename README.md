# Super Mario 64 ASL script usage
This ASL script use notation in splits to detect time to split. All special symbols are detected at the end of segment name. Splitter supports resets, starts, auto splitting on notations. Autosplitter does not support last split on star collect.

#Adding AutoSplitter to LiveSplit
Right Click on LiveSplit, select _Edit Layout..._. In appeared window press _+_ button, choose _Control_ > _Scriptable Auto Splitter_. Double left click on _Scriptable Auto Splitter_ item and choose script path with _Browse..._ button. Depending on hack, check Last Impact start mode. 

#List of special symbols:
(STAR_COUNT): Split will be fired on fadeout after STAR_COUNT.

[LEVEL_NUMBER]: Split will be fired on fadeout on enter to LEVEL_NUMBER.

*: Split will be fired when music stops (might not work if music just changes)

#Script Example
I have made an example for Last Impact 20 star splits. One can find them here: https://splits.io/10hx.

#TODO
Add tutorial on finding LEVEL_NUMBER
