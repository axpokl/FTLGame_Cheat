//{$Apptype GUI}
{$R FTLGame_Cheat.res}
program FTLGame_Cheat;

uses JwaPsApi,windows,display;

var multb:boolean=false;
var phnd:HANDLE;
var flthw:hwnd;

function EnumWindowsProc(hw:HWND;lp:LParam):LongBool;StdCall;
const fltclass='SILWindowClass';
      flttitle='Mult';
var position:byte;
    fltname:pchar;
begin
GetMem(fltname,256);
GetClassName(hw,fltname,256);
position:=pos(fltclass,fltname);
if position>0 then
  begin
  flthw:=hw;
  position:=0;
  GetWindowTextA(flthw,fltname,256);
  position:=pos(flttitle,fltname);
  multb:=(position>0);
  end;
EnumWindowsProc:=true;
end;

procedure getwin2();
begin
repeat
flthw:=0;
EnumWindows(@EnumWindowsProc,0);
sleep(1);
until (flthw>0) or not(IsWin());
end;

procedure getwin();
const fltclass='SILWindowClass';
      flttitle='Mult';
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
end;


var hmods:array[0..$1000]of longword;
var cb:longword;

function getbaseaddr():longword;
begin
EnumProcessModules(phnd,@hmods[0],sizeof(hmods),cb);
getbaseaddr:=hmods[0];
end;

var addrnum:SIZE_T;

function getaddr0(base:longword;offset:array of longint;var addr0:longword):boolean;
var addri:shortint;
var addrl,addrp:longword;
begin
getaddr0:=ReadProcessMemory(phnd,pointer(PtrUInt(base)),@addrl,sizeof(addrl),addrnum);
if getaddr0=false then exit;
for addri:=0 to length(offset)-2 do
  begin
  {$Q-}addrp:=addrl+offset[addri];{$Q+}
  getaddr0:=ReadProcessMemory(phnd,pointer(PtrUInt(addrp)),@addrl,sizeof(addrl),addrnum);
  if getaddr0=false then exit;
  end;
if length(offset)>0 then
  begin
  addri:=length(offset)-1;
  {$Q-}addrp:=addrl+offset[addri];{$Q+}
  end
else
  addrp:=addrl;
addr0:=addrp;
end;

function getaddr(base:longword;offset:array of longint;var data:longword):boolean;
var addr0:longword;
begin
getaddr:=getaddr0(base,offset,addr0);
if getaddr=false then exit;
if length(offset)>0 then getaddr:=ReadProcessMemory(phnd,pointer(PtrUInt(addr0)),@data,sizeof(data),addrnum)
else data:=addr0;
end;

function setaddr(base:longword;offset:array of longint;data:longword):boolean;
var addr0:longword;
begin
setaddr:=getaddr0(base,offset,addr0);
if setaddr=false then exit;
if length(offset)>0 then setaddr:=WriteProcessMemory(phnd,pointer(PtrUInt(addr0)),@data,sizeof(data),addrnum);
end;

function setaddr(base:longword;offset:array of longint;data:longword;offset0:longint):boolean;
var addr0:longword;
begin
setaddr:=getaddr0(base,offset,addr0);
if setaddr=false then exit;
if length(offset)>0 then setaddr:=ReadProcessMemory(phnd,pointer(PtrUInt(longword(addr0+offset0))),@data,sizeof(data),addrnum);
if setaddr=false then exit;
if length(offset)>0 then setaddr:=WriteProcessMemory(phnd,pointer(PtrUInt(addr0)),@data,sizeof(data),addrnum);
end;

const
      irebl=1;
      ijump=2;
      iengy=3;
      ihull=4;
      ishld=5;
      iscrp=6;
      ifuel=7;
      imsle=8;
      idron=9;
      ipwer=10;
      istat=11;
      icldn=12;
      iwpon=13;
      iclon=14;
      ihack=15;
      ihide=16;
      imind=17;
      ibatt=18;
      ittan=19;
      ioxyg=20;
      ihumn=21;
      imove=22;
      iskil=23;
const maxitem=23;
const itemc:array[0..maxitem]of ansistring=(
'ALL',
'REBEL',
'JUMP',
'REACTOR',
'HULL',
'SHIELD',
'SCRAP',
'FUEL',
'MISSILE',
'DRONE',
'POWER',
'STATUS',
'COOLDOWN',
'WEAPON',
'CLONE',
'HACKING',
'INVISIBLE',
'MIND',
'BATTERY',
'TITAN',
'OXYGEN',
'HUMAN',
'MOVE',
'SKILL');
var itemb:array[0..maxitem]of shortint;
var itemi:longword;
const szw=160;szh=32;
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

function l2f(l:longword):single;
var pf:^single;pl:^longword;f:single;
begin
pl:=@l;
pf:=pointer(pl);
f:=pf^;
l2f:=f;
end;

var baseaddr:longword;
var baseoffset:longword;
var engyoffset:longword;
var crewoffset:longword;
var data:longword;
var addri,addrj,addrm:longword;

var maxsys:longint;
var maxman:longword;
var oxgn1,oxgn2,oxgnn:longword;
{
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
}
var crewb:boolean;
var sys,power,powermax,powerstat,powerzelta:longword;
var wponmax,dronmax:longword;
var wponcount,droncount:longint;
var wponid,dronid:longword;

begin
for itemi:=0 to maxitem do itemb[itemi]:=-1;
newthread(@draw);
while not(isWin()) do sleep(1);
repeat
for itemi:=0 to maxitem do itemb[itemi]:=-1;
getwin2();
getphnd();
baseaddr:=getbaseaddr();
if multb then baseoffset:=$004C548C else baseoffset:=$0051348C;
if multb then engyoffset:=$75B4 else engyoffset:=$7694;
if multb then crewoffset:=$19C0 else crewoffset:=$19C0;
if multb then wponid:=$E78C else wponid:=$C540;
if multb then dronid:=$01470000 else dronid:=$01470000;
if getaddr(baseaddr+baseoffset,[],data) then for itemi:=0 to maxitem do itemb[itemi]:=0;
repeat
data:=1;getaddr(baseaddr+baseoffset-$46C,[$10],data);
if data=0 then
  begin
  maxsys:=-1;
  repeat
  data:=0;
  maxsys:=maxsys+1;
  getaddr(baseaddr+baseoffset,[$18,$4*maxsys,$1C],data);
  until data<>f2l(150);
  getaddr(baseaddr+baseoffset+$19B4,[],maxman);
  getaddr(baseaddr+baseoffset,[$24,$1C4],oxgn1);
  getaddr(baseaddr+baseoffset,[$24,$1C8],oxgn2);
  oxgnn:=(oxgn2-oxgn1)div 4;

  wponcount:=-1;
  repeat
  wponcount:=wponcount+1;
  data:=0;
  getaddr(baseaddr+baseoffset,[$48,$1C8,$4*wponcount,0],data);
  until (data and $FFFF)<>wponid;
  wponmax:=0;
  if wponcount>0 then for addri:=0 to wponcount-1 do
    begin
    data:=0;
    getaddr(baseaddr+baseoffset,[$48,$1C8,$4*addri,$F8],data);
    wponmax:=wponmax+data;
    end;

  droncount:=-1;
  repeat
  droncount:=droncount+1;
  data:=0;
  getaddr(baseaddr+baseoffset,[$4C,$1C0,$4*droncount,0],data);
  until (data and $FFFF0000)<>dronid;
  dronmax:=0;
  if droncount>0 then for addri:=0 to droncount-1 do
    begin
    data:=0;
    getaddr(baseaddr+baseoffset,[$4C,$1C0,$4*addri,$10],data);
    dronmax:=dronmax+data;
    end;

  for itemi:=1 to maxitem do
    begin
    if itemb[itemi]>=1 then
      case itemi of
      irebl:setaddr(baseaddr+baseoffset+$C,[$80],longword(-1000));
      ijump:setaddr(baseaddr+baseoffset,[$48C],f2l(85));
      iengy:
        begin
        setaddr(baseaddr+baseoffset+engyoffset,[$0],0);
        if multb then setaddr(baseaddr+baseoffset+engyoffset,[$4],60)
        else setaddr(baseaddr+baseoffset+engyoffset,[$4],30);
        end;
      ihull:
        begin
        data:=30;
        getaddr(baseaddr+baseoffset,[$CC+4],data);
        setaddr(baseaddr+baseoffset,[$CC],data);
        end;
      ishld:
        begin
        data:=0;
        getaddr(baseaddr+baseoffset,[$44,$1E8],data);
        if data>0 then setaddr(baseaddr+baseoffset,[$44,$1E8],f2l(2));
        end;
      iscrp:setaddr(baseaddr+baseoffset,[$4D4],99999);
      ifuel:setaddr(baseaddr+baseoffset,[$494],999);
      imsle:setaddr(baseaddr+baseoffset,[$48,$1E8],999);
      idron:
        begin
        setaddr(baseaddr+baseoffset,[$800],999);
        setaddr(baseaddr+baseoffset,[$4C,$1CC],999);
        end;
      ipwer:
        for addri:=0 to maxsys-1 do
          begin
          data:=0;
          setaddr(baseaddr+baseoffset,[$18,$4*addri,$11C],1000);
          getaddr(baseaddr+baseoffset,[$18,$4*addri,$28],sys);
          getaddr(baseaddr+baseoffset,[$18,$4*addri,$1A0],powermax);
          getaddr(baseaddr+baseoffset,[$18,$4*addri,$170],powerzelta);
          getaddr(baseaddr+baseoffset,[$18,$4*addri,$100],powerstat);
          if (sys=$70616577) then power:=max(8,wponmax)	//weapon
          else if (sys=$6E6F7264) then power:=max(8,dronmax)	//drone
          else
            begin
              if (sys=$65696873) then power:=16	//shield
              else if (sys=$6E6F6C63) then power:=3	//clone
              else if (sys=$6264656D) then power:=3	//medbay
              else if (sys=$6B636168) then power:=3	//hack
              else if (sys=$616F6C63) then power:=6	//hide
              else if (sys=$646E696D) then power:=3	//mind
              else if (sys=$6F6C6970) then power:=3	//stear
              else if (sys=$74746162) then power:=12	//battery
              else if (sys=$6779786F) then power:=6	//oxygen
              else power:=powermax;
            setaddr(baseaddr+baseoffset,[$18,$4*addri,$50],max(power-powerzelta,0));
            setaddr(baseaddr+baseoffset,[$18,$4*addri,$16C],max(power-powerzelta,0));
            end;
          setaddr(baseaddr+baseoffset,[$18,$4*addri,$54],power);
          setaddr(baseaddr+baseoffset,[$18,$4*addri,$104],power);
          setaddr(baseaddr+baseoffset,[$18,$4*addri,$100],0,4);
          end;
      istat:for addri:=0 to maxsys-1 do setaddr(baseaddr+baseoffset,[$18,$4*addri,$100],0,4);
      icldn:for addri:=0 to maxsys-1 do setaddr(baseaddr+baseoffset,[$18,$4*addri,$134],f2l(5));
      iwpon:if wponcount>0 then for addri:=0 to wponcount-1 do setaddr(baseaddr+baseoffset,[$48,$1C8,$4*addri,$62C],1);
      iclon:begin
            data:=0;
            getaddr(baseaddr+baseoffset,[$38,$1C0],data);
            if l2f(data)>0 then setaddr(baseaddr+baseoffset,[$38,$1C0],0,8);
            end;
      ihack:setaddr(baseaddr+baseoffset,[$3C,$7B0],0);
      ihide:setaddr(baseaddr+baseoffset,[$2C,$1CC],0);
      imind:begin
            data:=0;
            getaddr(baseaddr+baseoffset,[$34,$1C0],data);
            if l2f(data)<14 then setaddr(baseaddr+baseoffset,[$34,$1C0],0);
            end;
      ibatt:setaddr(baseaddr+baseoffset,[$30,$1CC],0);
      ittan:begin
            getaddr(baseaddr+baseoffset,[$58,$0,$1C0,$8+4],data);
            setaddr(baseaddr+baseoffset,[$58,$0,$1C0,$8],longword(data-1));
            end;
      ioxyg:for addri:=0 to oxgnn do setaddr(baseaddr+baseoffset,[$24,$1C4,$4*addri],f2l(100));
      ihumn..iskil:
        begin
        addri:=0;
        addrm:=0;
        repeat
        crewb:=false;
        data:=1;
        getaddr(baseaddr+baseoffset+crewoffset,[$4*addri,$4],data);
        crewb:=(data=0);
        getaddr(baseaddr+baseoffset+crewoffset,[$4*addri,$88],data);
        if data=$FFFFFFFF then crewb:=false;
        if multb then
          begin
          getaddr(baseaddr+baseoffset+crewoffset,[$4*addri,$0],data);
          if data and $FFFF<>$B58C then crewb:=false;
          end;
        if crewb=true then
          begin
          addrm:=addrm+1;
          case itemi of
            ihumn:setaddr(baseaddr+baseoffset+crewoffset,[$4*addri,$28],0,4);
            imove:begin setaddr(baseaddr+baseoffset+crewoffset,[$4*addri,$8],0,$10);setaddr(baseaddr+baseoffset+crewoffset,[$4*addri,$C],0,$10);end;
            iskil:for addrj:=0 to 5 do setaddr(baseaddr+baseoffset+crewoffset,[$4*addri,$314,$8*addrj],0,4);
            end;
          end;
        addri:=addri+1;
        until (addrm=maxman) or (addri>=32);
        end;
      end;
    end;
  for itemi:=0 to maxitem do if itemb[itemi]=1 then itemb[itemi]:=0;
  sleep(1);
  end;
sleep(1);
until not(getaddr(baseaddr+baseoffset,[],data)) or (not(iswin()));
sleep(1);
until not(iswin());

end.
