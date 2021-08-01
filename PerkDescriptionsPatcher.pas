unit userscript;

uses mteFunctions; 

const 
	createNewFile = true;
	capitalize = true;

var
	aFile:IInterface;

function Process(e:IInterface): integer;
var
	itemDesc: string;
	rec: IInterface;
	masters: TStringList;
	origTexts, newTexts: TStringList;
	i: integer;
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

	origTexts := TStringList.Create;
	origTexts.Add('greatswords');
	origTexts.Add('Greatswords');
	origTexts.Add('greatsword');
	origTexts.Add('Greatsword');
	origTexts.Add('swords and daggers');
	origTexts.Add('Swords and daggers');
	origTexts.Add('swords');
	origTexts.Add('Swords');
	origTexts.Add('sword');
	origTexts.Add('Sword');
	origTexts.Add('mace');
	origTexts.Add('Mace');
	origTexts.Add('War Axe');
	origTexts.Add('War axe');
	origTexts.Add('war axe');
	origTexts.Add('daggers');
	origTexts.Add('Daggers');
	origTexts.Add('dagger');
	origTexts.Add('Dagger');
	origTexts.Add('battleaxe');
	origTexts.Add('Battleaxe');
	origTexts.Add('battle axe');
	origTexts.Add('Battle axe');
	origTexts.Add('warhammer');
	origTexts.Add('Warhammer');
	origTexts.Add('war hammer');
	origTexts.Add('War hammer');

	newTexts := TStringList.Create;
	if capitalize = true then begin
		newTexts.Add('greatswords and Two-handed pole weapons');
		newTexts.Add('Greatswords and Two-handed pole weapons');
		newTexts.Add('greatsword and Two-handed pole weapon');
		newTexts.Add('Greatsword and Two-handed pole weapon');
		newTexts.Add('One-handed swords, One-handed spears, claws and daggers');
		newTexts.Add('One-handed swords, One-handed spears, claws and daggers');
		newTexts.Add('One-handed swords and spears');
		newTexts.Add('One-handed swords and spears');
		newTexts.Add('One-handed sword and spear');
		newTexts.Add('One-handed sword and spear');
		newTexts.Add('One-handed blunt weapon');
		newTexts.Add('One-handed blunt weapon');
		newTexts.Add('One-handed axe');
		newTexts.Add('One-handed axe');
		newTexts.Add('One-handed axe');
		newTexts.Add('claws and daggers');
		newTexts.Add('Claws and daggers');
		newTexts.Add('claw or dagger');
		newTexts.Add('Claw or dagger');
		newTexts.Add('Two-handed axe');
		newTexts.Add('Two-handed axe');
		newTexts.Add('Two-handed axe');
		newTexts.Add('Two-handed axe');
		newTexts.Add('Two-handed blunt weapon');
		newTexts.Add('Two-handed blunt weapon');
		newTexts.Add('Two-handed blunt weapon');
		newTexts.Add('Two-handed blunt weapon');
	end else
	begin
		newTexts.Add('greatswords and two-handed pole weapons');
		newTexts.Add('Greatswords and two-handed pole weapons');
		newTexts.Add('greatsword and two-handed pole weapon');
		newTexts.Add('Greatsword and two-handed pole weapon');
		newTexts.Add('one-handed swords, one-handed spears, claws and daggers');
		newTexts.Add('One-handed swords, one-handed spears, claws and daggers');
		newTexts.Add('one-handed swords and spears');
		newTexts.Add('One-handed swords and spears');
		newTexts.Add('one-handed sword and spear');
		newTexts.Add('One-handed sword and spear');
		newTexts.Add('one-handed blunt weapon');
		newTexts.Add('One-handed blunt weapon');
		newTexts.Add('One-handed axe');
		newTexts.Add('One-handed axe');
		newTexts.Add('one-handed axe');
		newTexts.Add('claws and daggers');
		newTexts.Add('Claws and daggers');
		newTexts.Add('claw or dagger');
		newTexts.Add('Claw or dagger');
		newTexts.Add('two-handed axe');
		newTexts.Add('Two-handed axe');
		newTexts.Add('two-handed axe');
		newTexts.Add('Two-handed axe');
		newTexts.Add('two-handed blunt weapon');
		newTexts.Add('Two-handed blunt weapon');
		newTexts.Add('two-handed blunt weapon');
		newTexts.Add('Two-handed blunt weapon');
	end;
	


	for i := 0 to origTexts.count - 1 do
	begin
		itemDesc := geev(e, 'DESC');
		if (pos(origTexts[i], itemDesc) > 0) then 
		begin
			if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
			if (createNewFile = false) then rec := e;
			seev(rec, 'DESC', StringReplace(itemDesc, origTexts[i], newTexts[i], [rfReplaceAll]));
			break;
		end;
	end;	
end;
end.
