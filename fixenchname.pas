unit userscript;

uses mteFunctions; 

const
// Settings
  createNewFile = false;

var
  aFile: IInterface;

function Process(e:IInterface): integer;
var
  itemName: string;  
  masters: TStringList;
  rec: IInterface;
  newName: string;
begin

  // Create plugin if needed
  if not Assigned(aFile) then begin
    if (createNewFile = true) then 
    begin
      aFile := AddNewFile;
      
      // add masters
      masters := TStringList.Create;
      AddMastersToList(GetFile(e), masters);		
      AddMastersToFile(aFile, masters, False);		
    end else
    begin
      aFile := GetFile(e);
    end;
  end;

  itemName := geev(e, 'FULL');   

  if (pos('of Blessed', itemName) > 0) then 
  begin
    if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
    if (createNewFile = false) then rec := e;

    newName := 'Blessed ' + StringReplace(itemName, 'of Blessed', '', [rfReplaceAll]);

    seev(rec, 'FULL', newName);
  end;

  if (pos('of Sanctified', itemName) > 0) then 
  begin
    if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
    if (createNewFile = false) then rec := e;

    newName := 'Sanctified ' + StringReplace(itemName, 'of Sanctified', '', [rfReplaceAll]);

    seev(rec, 'FULL', newName);
  end;

  if (pos('of Reverent', itemName) > 0) then 
  begin
    if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
    if (createNewFile = false) then rec := e;

    newName := 'Reverent ' + StringReplace(itemName, 'of Reverent', '', [rfReplaceAll]);

    seev(rec, 'FULL', newName);
  end;

  if (pos('of Hallowed', itemName) > 0) then 
  begin
    if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
    if (createNewFile = false) then rec := e;

    newName := 'Hallowed ' + StringReplace(itemName, 'of Hallowed', '', [rfReplaceAll]);

    seev(rec, 'FULL', newName);
  end;

  if (pos('of Virtuous', itemName) > 0) then 
  begin
    if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
    if (createNewFile = false) then rec := e;

    newName := 'Virtuous ' + StringReplace(itemName, 'of Virtuous', '', [rfReplaceAll]);

    seev(rec, 'FULL', newName);
  end;

  if (pos('of Holy', itemName) > 0) then 
  begin
    if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
    if (createNewFile = false) then rec := e;

    newName := 'Holy ' + StringReplace(itemName, 'of Holy', '', [rfReplaceAll]);

    seev(rec, 'FULL', newName);
  end;

 
end;
end.
