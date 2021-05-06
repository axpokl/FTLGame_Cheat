windres -i FTLGame_Cheat.rc -o FTLGame_Cheat.res
fpc FTLGame_Cheat.pas -Fuwinunits-jedi -oFTLGame_Cheat32.exe -gl -Crtoi -WG
ppcrossx64 FTLGame_Cheat.pas -oFTLGame_Cheat64.exe -Os -WG
pause