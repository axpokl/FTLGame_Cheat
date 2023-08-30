program FTLGame_Cheat_ID;
uses Windows;

procedure sendkey(key:short;shift:boolean);
begin
if shift then keybd_event(VK_SHIFT,MapVirtualKey(VK_SHIFT,0),0,0);
keybd_event(key,MapVirtualKey(key,0),0,0);
windows.sleep(16);
keybd_event(key,MapVirtualKey(key,0),2,0);
if shift then keybd_event(VK_SHIFT,MapVirtualKey(VK_SHIFT,0),2,0);
end;

procedure sendkey(key:char);
var vk:short;
begin
vk:=VkKeyScan(key);
sendkey(lobyte(vk),hibyte(vk)=0);
end;

procedure sendstring(str: string);
var i:longint;
begin
for i:=1 to Length(str) do sendkey(str[i]);
sendkey(#13);
windows.sleep(10);
end;

procedure sendstring2(str: string);
var
  Input: array of TInput;
  i, j, Len: Integer;
  vk: SHORT;
begin
  SendKey('\');
  Len := Length(str);
  SetLength(Input, Len * 4);
  j:=0;
  for i := 1 to Len do
  begin
    vk := VkKeyScan(str[i]);
    if HIBYTE(vk) = 0 then
    begin
      Input[j]._type := INPUT_KEYBOARD;
      Input[j].ki.wVk := VK_SHIFT;
      Input[j].ki.dwFlags := 0;
      Inc(j);
    end;
    Input[j]._type := INPUT_KEYBOARD;
    Input[j].ki.wVk := LOBYTE(vk);
    Input[j].ki.dwFlags := 0;
    Inc(j);
    Input[j]._type := INPUT_KEYBOARD;
    Input[j].ki.wVk := LOBYTE(vk);
    Input[j].ki.dwFlags := KEYEVENTF_KEYUP;
    Inc(j);
    if HIBYTE(vk) = 0 then
    begin
      Input[j]._type := INPUT_KEYBOARD;
      Input[j].ki.wVk := VK_SHIFT;
      Input[j].ki.dwFlags := KEYEVENTF_KEYUP;
      Inc(j);
    end;
  end;
  Input[j]._type := INPUT_KEYBOARD;
  Input[j].ki.wVk := VK_RETURN;
  Input[j].ki.dwFlags := 0;
  Inc(j);
  Input[j]._type := INPUT_KEYBOARD;
  Input[j].ki.wVk := VK_RETURN;
  Input[j].ki.dwFlags := KEYEVENTF_KEYUP;
  Inc(j);
  SendInput(j, @Input[0], SizeOf(TInput));
end;

var f: TextFile;
    line: string;
begin
sleep(1000);
assign(f, 'FTLGame_Cheat_ID.txt');
reset(f);
while not eof(f) do
  begin
  readln(f, line);
  sendstring2(line);
  sleep(50);
  end;
close(f);
end.
