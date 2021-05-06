{$Apptype GUI}
{$R FTLGame_Cheat.res}
program FTLGame_Cheat;

uses JwaPsApi,windows,display;

var phnd:HANDLE;
var flthw:hwnd;

function EnumWindowsProc(hw:HWND;lp:LParam):LongBool;StdCall;
const fltclass='SILWindowClass';
var position:byte;
    fltname:pchar;
begin
GetMem(fltname,256);
GetClassName(hw,fltname,256);
position:=pos(fltclass,fltname);
if position>0 then flthw:=hw;
//if position>0 then writeln(hw,#9,fltname);
EnumWindowsProc:=true;
end;

procedure getwin2();
begin
repeat
flthw:=0;
EnumWindows(@EnumWindowsProc,0);
sleep(1);
until (flthw>0) or not(IsWin());
//writeln(flthw);
end;

procedure getwin();
const fltclass='SILWindowClass';
var position:byte;
    fltname:pchar;
begin
repeat
flthw:=GetForegroundWindow();
GetMem(fltname,256);
GetClassName(flthw,fltname,256);
position:=pos(fltclass,fltname);
sleep(1);
until (position>0) or not(IsWin());
//writeln(flthw);
end;

procedure getphnd();
var pid:DWORD=0;
begin
GetWindowThreadProcessId(flthw,@pid);
phnd:=OpenProcess(PROCESS_ALL_ACCESS,false,pid);
if getlasterror=5 then
  begin
  msgbox('Access Denied while attaching FLTGame.exe, Please run FTLGame_Cheat.exe as Administrator');
  halt;
  end;
//writeln(phnd);
end;


//const maxbuf=$100;
//var buf:array[0..maxbuf]of char;
var hmods:array[0..$1000]of longword;
var cb:longword;
//var cbi:longword;
//var modinfo:TMODULEINFO;

function getbaseaddr():longword;
begin
{
GetProcessImageFileName(phnd,buf,length(buf));
writeln(buf);
EnumProcessModules(phnd,hmods,sizeof(hmods),cb);
for cbi:=0 to cb div 4 do
begin
write(cbi,#9);
write(i2hs(hmods[cbi]),#9);
GetModuleInformation(phnd,hmods[cbi],modinfo,sizeof(modinfo));
write(i2hs(longword(modinfo.lpBaseOfDll)),#9);
write(i2hs(longword(modinfo.sizeofimage)),#9);
write(i2hs(longword(modinfo.entrypoint)),#9);
GetModuleFileNameEx(phnd,hmods[cbi],buf,length(buf));
write(buf,#9);
writeln();
end;
}
{
GetModuleInformation(phnd,0,modinfo,sizeof(modinfo));
getbaseaddr:=longword(modinfo.lpBaseOfDll);
}
EnumProcessModules(phnd,@hmods[0],sizeof(hmods),cb);
getbaseaddr:=hmods[0];
end;

var addrnum:SIZE_T;

function getaddr0(base:longword;offset:array of longint;var addr0:longword):boolean;
var addri:shortint;
var addrl,addrp:longword;
begin
getaddr0:=ReadProcessMemory(phnd,pointer(base),@addrl,sizeof(addrl),addrnum);
if getaddr0=false then exit;
for addri:=0 to length(offset)-2 do
  begin
  {$Q-}addrp:=addrl+offset[addri];{$Q+}
  getaddr0:=ReadProcessMemory(phnd,pointer(addrp),@addrl,sizeof(addrl),addrnum);
  if getaddr0=false then exit;
  end;
if length(offset)>0 then
  begin
  addri:=length(offset)-1;
  {$Q-}addrp:=addrl+offset[addri];{$Q+}
  end;
addr0:=addrp;
end;

function getaddr(base:longword;offset:array of longint;var data:longword):boolean;
var addr0:longword;
begin
getaddr:=getaddr0(base,offset,addr0);
if getaddr=false then exit;
if length(offset)>0 then getaddr:=ReadProcessMemory(phnd,pointer(addr0),@data,sizeof(data),addrnum)
end;

function setaddr(base:longword;offset:array of longint;data:longword):boolean;
var addr0:longword;
begin
setaddr:=getaddr0(base,offset,addr0);
if setaddr=false then exit;
if length(offset)>0 then setaddr:=WriteProcessMemory(phnd,pointer(addr0),@data,sizeof(data),addrnum);
end;

function setaddr(base:longword;offset:array of longint;data:longword;offset0:longint):boolean;
var addr0:longword;
begin
setaddr:=getaddr0(base,offset,addr0);
if setaddr=false then exit;
if length(offset)>0 then setaddr:=ReadProcessMemory(phnd,pointer(addr0+offset0),@data,sizeof(data),addrnum);
if setaddr=false then exit;
if length(offset)>0 then setaddr:=WriteProcessMemory(phnd,pointer(addr0),@data,sizeof(data),addrnum);
end;

const ihull=1;
      ishld=2;
      ijump=3;
      iengy=4;
      iscrp=5;
      ifuel=6;
      imsle=7;
      idron=8;
      ipwer=9;
      istat=10;
      icldn=11;
      iwpon=12;
      ihack=13;
      ihide=14;
      imind=15;
      ihumn=16;
      iskil=17;
      ioxyg=18;
const maxitem=18;
const itemc:array[0..maxitem]of ansistring=(
'ALL',
'HULL',
'SHIELD',
'JUMP',
'REACTOR',
'SCRAP',
'FUEL',
'MISSILE',
'DRONE',
'POWER',
'STATUS',
'COOLDOWN',
'WEAPON',
'HACKING',
'INVISIBLE',
'MIND',
'HUMAN',
'SKILL',
'OXYGEN');
var itemb:array[0..maxitem]of shortint;
var itemi:longword;
const szw=200;szh=40;
var mousedown:boolean;
var mousex,mousey:longint;

procedure getact();
var imouse:longword;
begin
mousex:=GetMousePosX();
mousey:=GetMousePosY();
while IsNextMsg() do
  begin
  If IsMsg(WM_LBUTTONDOWN) then mousedown:=true;
  If IsMsg(WM_LBUTTONUP) then mousedown:=false;
  If IsMsg(WM_LBUTTONUP) then
    begin
    if (mousex>szh) and (mousey div szh>=0) and (mousey div szh<=maxitem) then
      if itemb[mousey div szh]=0 then itemb[mousey div szh]:=1;
    if (mousex<=szh) and (mousey div szh>=0) and (mousey div szh<=maxitem) then
      if itemb[mousey div szh]=2 then itemb[mousey div szh]:=0
      else if itemb[mousey div szh]>=0 then itemb[mousey div szh]:=2;
    if mousey div szh=0 then for imouse:=1 to maxitem do itemb[imouse]:=itemb[0];
    end;
  end;
end;

procedure drawall();
var idraw:longword;
var tcolor:longword;
begin
Clear();
for idraw:=0 to maxitem do
  begin
  if itemb[idraw]=-1 then tcolor:=$3F3F3F;
  if itemb[idraw]=0 then tcolor:=$7F7F7F;
  if itemb[idraw]=1 then tcolor:=$0000FF;
  if itemb[idraw]=2 then tcolor:=$FFFFFF;
  Bar(0+1,szh*idraw+1,szh-2,szh-2,tcolor,transparent);
  if itemb[idraw]=2 then Circle(szh div 2,szh*idraw+1+szh div 2,szh div 6,tcolor);
//  if itemb[idraw]=2 then Line(0+1,szh*idraw+1,szh-2,szh-2,tcolor);
//  if itemb[idraw]=2 then Line(szh-1,szh*idraw+1,2-szh,szh-2,tcolor);
  if itemb[idraw]=0 then
    if (mousex>szh) and ((mousey div szh=idraw) or (mousey div szh=0)) then
      begin if mousedown then tcolor:=$7FFF7F else tcolor:=$7F7FFF end;
  DrawtextXY(itemc[idraw],szh,szh*idraw,tcolor);
  end;
FreshWin();
end;

procedure draw();
var timeold:longword;
var frame:longword=0;
var frametime:longword=30;
begin
CreateWin(szh+szw,(maxitem+1)*szh,blue);
SetTitle('FTL Cheater by ax_pokl');
SetWindowPos(_hw,HWND_TOPMOST,getscrwidth()-szh-szw,0,0,0,SWP_NOSIZE);
SetFontName('Consolas');
SetFontHeight(szh);
timeold:=gettime();
repeat
getact();
if gettime-timeold>frame*frametime then
  begin
  while gettime-timeold>frame*frametime do frame:=frame+1;
  drawall();
  end;
sleep(1);
until not(IsWin());
end;

function f2l(f:single):longword;
var pf:^single;pl:^longword;l:longword;
begin
pf:=@f;
pl:=pointer(pf);
l:=pl^;
f2l:=l;
end;

var baseaddr:longword;
var data:longword;
var addri,addrj,addrm:longword;

var maxsys:longword;
var maxman:longword;
//var man1,man2:longword;
var oxgn1,oxgn2,oxgnn:longword;
const crew:array[1..9]of longword=(
$616D7568,
$69676E65,
$736F6867,
$72656E65,
$6B636F72,
$67756C73,
$746E616D,
$65616E61,
$73797263);
var crewi:shortint;
var crewb:boolean;

begin
for itemi:=0 to maxitem do itemb[itemi]:=-1;
newthread(@draw);
while not(isWin()) do sleep(1);
repeat
for itemi:=0 to maxitem do itemb[itemi]:=-1;
getwin();
getphnd();
baseaddr:=getbaseaddr();
if getaddr(baseaddr+$0051348C,[],data) then for itemi:=0 to maxitem do itemb[itemi]:=0;
repeat
data:=1;getaddr(baseaddr+$00513020,[$10],data);
if data=0 then
  begin
  //for itemi:=0 to maxitem do if itemb[itemi]=0 then itemb[itemi]:=2;
  maxsys:=0;
  repeat
  data:=0;
  getaddr(baseaddr+$0051348C,[$18,$4*maxsys,$1C],data);
  maxsys:=maxsys+1;
  until data<>f2l(150);
  //getaddr(baseaddr+$0051348C,[$64],man1);
  //getaddr(baseaddr+$0051348C,[$68],man2);
  //maxman:=(man2-man1)div 4;
  getaddr(baseaddr+$00513020,[$C,$1288],maxman);
  getaddr(baseaddr+$0051348C,[$24,$1C4],oxgn1);
  getaddr(baseaddr+$0051348C,[$24,$1C8],oxgn2);
  oxgnn:=(oxgn2-oxgn1)div 4;
  for itemi:=1 to maxitem do
    begin
    if itemb[itemi]>=1 then
      case itemi of
      ihull:setaddr(baseaddr+$0051348C,[$CC],30);
      ishld:setaddr(baseaddr+$0051348C,[$44,$1E8],f2l(2));
      ijump:setaddr(baseaddr+$0051348C,[$48C],f2l(85));
      iengy:setaddr(baseaddr+$0051AB20,[$0],0);
      iscrp:setaddr(baseaddr+$0051348C,[$4D4],99999);
      ifuel:setaddr(baseaddr+$0051348C,[$494],999);
      imsle:setaddr(baseaddr+$0051348C,[$48,$1E8],999);
      idron:
        begin
        setaddr(baseaddr+$0051348C,[$800],999);
        setaddr(baseaddr+$0051348C,[$4C,$1CC],999);
        end;
      ipwer:
        for addri:=0 to maxsys-1 do
          begin
          data:=0;
          getaddr(baseaddr+$0051348C,[$18,$4*addri,$28],data);
          if (data<>$70616577) and (data<>$6E6F7264) then
            setaddr(baseaddr+$0051348C,[$18,$4*addri,$50],0,4);
        end;
      istat:for addri:=0 to maxsys-1 do setaddr(baseaddr+$0051348C,[$18,$4*addri,$100],0,4);
      icldn:for addri:=0 to maxsys-1 do setaddr(baseaddr+$0051348C,[$18,$4*addri,$134],f2l(5));
      iwpon:for addri:=0 to 3 do setaddr(baseaddr+$0051348C,[$48,$1C8,$4*addri,$62C],1);
      ihack:setaddr(baseaddr+$0051348C,[$3C,$7B0],0);
      ihide:setaddr(baseaddr+$0051348C,[$2C,$1CC],0);
      imind:setaddr(baseaddr+$0051348C,[$34,$1C0],0);
      ihumn:
        begin
        addri:=0;
        addrm:=0;
        repeat
        data:=0;
        crewb:=false;
        getaddr(baseaddr+$00514E4C,[$4*addri,$1B8],data);
        for crewi:=1 to 9 do if data=crew[crewi] then crewb:=true;
        data:=0;
        getaddr(baseaddr+$00514E4C,[$4*addri,$4],data);
        if data<>0 then crewb:=false;
        if crewb=true then
          begin
          addrm:=addrm+1;
          setaddr(baseaddr+$00514E4C,[$4*addri,$28],0,4);
          end;
        addri:=addri+1;
        until (addrm=maxman) or (addri=maxman+3);
        end;
      iskil:
        begin
        addri:=0;
        addrm:=0;
        repeat
        data:=0;
        crewb:=false;
        getaddr(baseaddr+$00514E4C,[$4*addri,$1B8],data);
        for crewi:=1 to 9 do if data=crew[crewi] then crewb:=true;
        data:=0;
        getaddr(baseaddr+$00514E4C,[$4*addri,$4],data);
        if data<>0 then crewb:=false;
        if crewb=true then
          begin
          addrm:=addrm+1;
          for addrj:=0 to 5 do setaddr(baseaddr+$00514E4C,[$4*addri,$314,$8*addrj],0,4);
          end;
        addri:=addri+1;
        until (addrm=maxman) or (addri=maxman+5);
        end;
      ioxyg:for addri:=0 to oxgnn do setaddr(baseaddr+$0051348C,[$24,$1C4,$4*addri],f2l(100));
      end;
//    writeln('@',itemi,itemb[itemi]);
    end;
  for itemi:=0 to maxitem do if itemb[itemi]=1 then itemb[itemi]:=0;
  sleep(1);
  end;
sleep(1);
until not(getaddr(baseaddr+$0051348C,[],data)) or (not(iswin()));
sleep(1);
until not(iswin());
{
//other status?
//other human?
//dron
}

end.
