unit userscript;

uses mteFunctions; 

const
// Settings
  createNewFile = true;

var
  aFile: IInterface;

function Process(e:IInterface): integer;
var
  itemName: string;  
  masters: TStringList;
  rec: IInterface;
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

  if (pos('Halberd', itemName) > 0) then 
  begin
    if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
    if (createNewFile = false) then rec := e;

    seev(rec, 'FULL', StringReplace(itemName, 'Halberd', 'Poleaxe', [rfReplaceAll]));
  end;

  if (pos('Spear', itemName) > 0) AND (pos('Shortspear', itemName) = 0)then 
  begin
    if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
    if (createNewFile = false) then rec := e;

    seev(rec, 'FULL', StringReplace(itemName, 'Spear', 'Half Pike', [rfReplaceAll]));
  end;

  if (pos('Quarterstaff', itemName) > 0) then 
  begin
    if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
    if (createNewFile = false) then rec := e;

    seev(rec, 'FULL', StringReplace(itemName, 'Quarterstaff', 'Short Staff', [rfReplaceAll]));
  end;

  if (pos('Half pike', itemName) > 0) then 
  begin
    if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
    if (createNewFile = false) then rec := e;

    seev(rec, 'FULL', StringReplace(itemName, 'Half pike', 'Half Pike', [rfReplaceAll]));
  end;

end;
end.
