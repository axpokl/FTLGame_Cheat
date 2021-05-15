del *.exe
windres -i FTLGame_Cheat.rc -o FTLGame_Cheat.res
fpc FTLGame_Cheat.pas -Fuwinunits-jedi_32 -oFTLGame_Cheat32.exe -gl -Crtoi -WG
ppcrossx64 FTLGame_Cheat.pas -Fuwinunits-jedi_64 -oFTLGame_Cheat64.exe -Os -WG
pause