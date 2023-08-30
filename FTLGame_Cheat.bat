del *.o
del *.exe
windres -i FTLGame_Cheat.rc -o FTLGame_Cheat.res
fpc FTLGame_Cheat.pas -Fuwinunits-jedi_32 -oFTLGame_Cheat_32.exe -gl -Crtoi -WG
fpc FTLGame_Cheat_ID.pas -Fuwinunits-jedi_32 -oFTLGame_Cheat_ID_32.exe -gl -Crtoi -WG
ppcrossx64 FTLGame_Cheat.pas -Fuwinunits-jedi_64 -oFTLGame_Cheat_64.exe -Os -WG
ppcrossx64 FTLGame_Cheat_ID.pas -Fuwinunits-jedi_64 -oFTLGame_Cheat_ID_64.exe -Os -WG
pause