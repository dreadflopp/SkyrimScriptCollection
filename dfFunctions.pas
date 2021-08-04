unit dfFunctions;

uses mteFunctions; 

function GetPlugin(PluginName : String): IInterface;
//function to get the plugin by name
var
 i : integer;
begin
	for i := 1 to Pred(FileCount) do begin
		if (GetFileName(FileByIndex(i)) = PluginName) then begin
			Result := FileByIndex(i);
			Exit;
		end;
	end;
end;

function isOneHanded(weaponType: string): boolean;
begin
	Result := True;
	
	if (weaponType = 'Greatsword') then Result := False;
	if (weaponType = 'Warhammer') then Result := False;
	if (weaponType = 'Battleaxe') then Result := False;	
	if (weaponType = 'Quarterstaff') then Result := False;
	if (weaponType = 'QtrStaff') then Result := False;
	if (weaponType = 'Halberd') then Result := False;
	if (weaponType = 'LongMace') then Result := False;
	if (weaponType = 'Pike') then Result := False;
	if (weaponType = 'Poleaxe') then Result := False;
	if (weaponType = 'Trident') then Result := False;
	
end;

function getMainMaterialShort(itemRecord: IInterface): IInterface;
var
itemSignature: string;
tmpKeywordsCollection: IInterface;
i, j: integer;

currentKeywordEDID: string;
itemName: string;
resultName: string;
begin
	itemSignature := Signature(itemRecord);
	
	if ((itemSignature = 'WEAP') or (itemSignature = 'ARMO') or (itemSignature = 'AMMO')) then 
	begin
		tmpKeywordsCollection := ElementByPath(itemRecord, 'KWDA');
		resultName := '';

        {
		// loop through each several times, first time check for special skip
		for i := 0 to ElementCount(tmpKeywordsCollection) - 1 do 
		begin
			currentKeywordEDID := GetElementEditValues(LinksTo(ElementByIndex(tmpKeywordsCollection, i)), 'EDID');
			if currentKeywordEDID = 'Skip_ench' then 
			begin
				resultName := 'Skip_ench';
				Break;	
			end;
		end;
		}
		if resultName = '' then
		begin
			for i := 0 to ElementCount(tmpKeywordsCollection) - 1 do 
			begin
				currentKeywordEDID := GetElementEditValues(LinksTo(ElementByIndex(tmpKeywordsCollection, i)), 'EDID');
				if currentKeywordEDID = 'WAF_WeapMaterialBlades' then 
				begin
					resultName := 'Blades';
					Break;
				end
				else if currentKeywordEDID = 'WAF_DLC1WeapMaterialDawnguard' then 
				begin
					resultName := 'Dawnguard';
					Break;
				end
				else if currentKeywordEDID = 'WAF_WeapMaterialForsworn' then 
				begin
					resultName := 'Forsworn';
					Break;
				end
				else if currentKeywordEDID = 'WAF_WeapMaterialRedguard' then 
				begin
					resultName := 'Redguard';
					Break;
				end
				else if currentKeywordEDID = 'WAF_WeapMaterialSkyforge' then 
				begin
					resultName := 'Skyforge';
					Break;
				end;			
			end;
		end;

        if resultName = '' then
		begin
			itemName := geev(itemRecord, 'FULL');

            if (pos('Blades', itemName) > 0) then
            begin
                resultName := 'Blades';
            end;
            if (pos('Akaviri', itemName) > 0) then
            begin
                resultName := 'Blades';
            end;
            if (pos('Dawnguard', itemName) > 0) then
            begin
                resultName := 'Dawnguard';
            end;
            if (pos('Forsworn', itemName) > 0) then
            begin
                resultName := 'Forsworn';
            end;
            if (pos('Redguard', itemName) > 0) then
            begin
                resultName := 'Redguard';
            end;
            if (pos('Skyforge', itemName) > 0) then
            begin
                resultName := 'Skyforge';
            end;
            if (pos('Anicent Nord', itemName) > 0) then
            begin
                resultName := 'Draugr';
            end;
            if (pos('Honed Anicent Nord', itemName) > 0) then
            begin
                resultName := 'DraugrHoned';
            end;
            if (pos('Nord Hero', itemName) > 0) then
            begin
                resultName := 'DraugrHoned';
            end;
            if (pos('Imperial', itemName) > 0) then
            begin
                resultName := 'Imperial';
            end;
            if (pos('Riekling', itemName) > 0) then
            begin
                resultName := 'Riekling';
            end;
            if (pos('Dragon Priest', itemName) > 0) then
            begin
                resultName := 'DragonPriest';
            end;
		end;
		
		if resultName = '' then
		begin
			for i := 0 to ElementCount(tmpKeywordsCollection) - 1 do 
			begin
				currentKeywordEDID := GetElementEditValues(LinksTo(ElementByIndex(tmpKeywordsCollection, i)), 'EDID');
				if currentKeywordEDID = 'WeapMaterialEbony' then 
				begin
					resultName := 'Ebony';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialDaedric' then 
				begin
					resultName := 'Daedric';
					Break;
				end
				else if currentKeywordEDID = 'WeapMaterialElven' then
				begin
					resultName := 'Elven';
					Break;
				end
				else if currentKeywordEDID = 'DLC2WeaponMaterialNordic' then 
				begin
					resultName := 'Nordic';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialIron' then 
				begin
					resultName := 'Iron';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialSteel' then 
				begin
					resultName := 'Steel';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialImperial' then 
				begin
					resultName := 'Imperial';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialDraugr' then 
				begin
					resultName := 'Draugr';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialDraugrHoned' then 
				begin
					resultName := 'DraugrHoned';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialDwarven' then 
				begin
					resultName := 'Dwarven';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialWood' then 
				begin
					resultName := 'Wood';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialSilver' then 
				begin
					resultName := 'Silver';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialOrcish' then 
				begin
					resultName := 'Orcish';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialGlass' then 
				begin
					resultName := 'Glass';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialFalmerHoned' then 
				begin
					resultName := 'FalmerHoned';
					Break;
				end 
				else if currentKeywordEDID = 'WeapMaterialFalmer' then 
				begin
					resultName := 'Falmer';
					Break;
				end 
				else if currentKeywordEDID = 'DLC1WeapMaterialDragonbone' then 
				begin
					resultName := 'Dragonbone';
					Break;
				end 
				else if currentKeywordEDID = 'DLC2WeaponMaterialStalhrim' then 
				begin
					resultName := 'Stalhrim';
					Break;
				end;				
			end;
		end;
	end;
	
	if resultName = '' then 
	begin
		AddMessage('no material keywords were found for - ' + Name(itemRecord));
	end
	else 
	begin
		Result := resultName;
	end;
end;

function getType(itemRecord: IInterface): IInterface;
var
itemSignature: string;
tmpKeywordsCollection: IInterface;
i, j: integer;

currentKeywordEDID: string;
resultName: string;
begin
	itemSignature := Signature(itemRecord);
	
	if ((itemSignature = 'WEAP') or (itemSignature = 'ARMO') or (itemSignature = 'AMMO')) then 
	begin
		tmpKeywordsCollection := ElementByPath(itemRecord, 'KWDA');
		resultName := '';
		// loop through each, first two loops check for special new types
		for i := 0 to ElementCount(tmpKeywordsCollection) - 1 do 
		begin
			currentKeywordEDID := GetElementEditValues(LinksTo(ElementByIndex(tmpKeywordsCollection, i)), 'EDID');
			if currentKeywordEDID = 'WeapTypeShortspear' then 
			begin
				resultName := 'Shortspear';
				Break; // break for-loop
			end
			else if currentKeywordEDID = 'WeapTypeTrident' then 
			begin
				resultName := 'Trident';
				Break; // break for-loop
			end
			else if currentKeywordEDID = 'WeapTypePoleaxe' then 
			begin
				resultName := 'Poleaxe';
				Break; // break for-loop
			end;
		end;
		
		if resultName = '' then
		begin
			for i := 0 to ElementCount(tmpKeywordsCollection) - 1 do 
			begin
				currentKeywordEDID := GetElementEditValues(LinksTo(ElementByIndex(tmpKeywordsCollection, i)), 'EDID');
				if currentKeywordEDID = 'WeapTypeSpear' then 
				begin
					resultName := 'Spear';
					Break; // break for-loop
				end
				else if currentKeywordEDID = 'WeapTypeClub' then 
				begin
					resultName := 'Club';
					Break; // break for-loop
				end
				else if currentKeywordEDID = 'WeapTypePike' then 
				begin
					resultName := 'Pike';
					Break; // break for-loop
				end
				else if currentKeywordEDID = 'WeapTypeHatchet' then 
				begin
					resultName := 'Hatchet';
					Break; // break for-loop
				end
				else if currentKeywordEDID = 'WeapTypeLongMace' then 
				begin
					resultName := 'LongMace';
					Break; // break for-loop
				end
				else if currentKeywordEDID = 'WeapTypeShortsword' then 
				begin
					resultName := 'Shortsword';
					Break; // break for-loop
				end
				else if currentKeywordEDID = 'WeapTypeMaul' then 
				begin
					resultName := 'Maul';
					Break; // break for-loop
				end
				else if currentKeywordEDID = 'WeapTypeHalberd' then 
				begin
					resultName := 'Halberd';
					Break; // break for-loop
				end
				else if currentKeywordEDID = 'WeapTypeQuarterstaff' then 
				begin
					resultName := 'Quarterstaff';
					Break; // break for-loop
				end
				else if currentKeywordEDID = 'WeapTypeQtrStaff' then 
				begin
					resultName := 'Quarterstaff';
					Break; // break for-loop
				end
				else if currentKeywordEDID = 'WeapTypeWhip' then 
				begin
					resultName := 'Whip';
					Break; // break for-loop
				end		
				else if currentKeywordEDID = 'WeapTypeClaw' then 
				begin
					resultName := 'Claw';
					Break; // break for-loop
				end		
				else if currentKeywordEDID = 'WeapTypeRapier' then 
				begin
					resultName := 'Rapier';
					Break; // break for-loop
				end
				else if currentKeywordEDID = 'WeapTypeJavelin' then 
				begin
					resultName := 'Javelin';
					Break; // break for-loop
				end;
			end;
		end;
		
		if resultName = '' then
		begin
			for i := 0 to ElementCount(tmpKeywordsCollection) - 1 do 
			begin
				currentKeywordEDID := GetElementEditValues(LinksTo(ElementByIndex(tmpKeywordsCollection, i)), 'EDID');
				if currentKeywordEDID = 'WeapTypeBattleaxe' then 
				begin
					resultName := 'Battleaxe';
					Break;
				end 
				else if currentKeywordEDID = 'WeapTypeBow' then 
				begin
					resultName := 'Bow';
					Break;
				end 
				else if currentKeywordEDID = 'WeapTypeDagger' then 
				begin
					resultName := 'Dagger';
					Break;
				end 
				else if currentKeywordEDID = 'WeapTypeGreatsword' then 
				begin
					resultName := 'Greatsword';
					Break;
				end 
				else if currentKeywordEDID = 'WeapTypeMace' then 
				begin
					resultName := 'Mace';
					Break;
				end 
				else if currentKeywordEDID = 'WeapTypeStaff' then 
				begin
					resultName := 'Staff';
					Break;
				end 
				else if currentKeywordEDID = 'WeapTypeSword' then 
				begin
					resultName := 'Sword';
					Break;
				end 
				else if currentKeywordEDID = 'WeapTypeWarAxe' then 
				begin
					resultName := 'WarAxe';
					Break;
				end 
				else if currentKeywordEDID = 'WeapTypeWarhammer' then 
				begin
					resultName := 'Warhammer';
					Break;
				end;
			end;
		end;
		
		if resultName = '' then 
		begin
			warn('no type keywords were found for - ' + Name(itemRecord));
		end 
		else 
		begin
			Result := resultName;
		end;
		// AddMessage(GetElementEditValues(itemRecord, 'EDID') + 'reported type: ' + resultName);
	end;
end;

procedure seevi(e: IInterface; ip: string; val: integer);
begin    
    SetEditValue(ElementByIP(e, ip), IntToStr(val));
end;

function geevi(e: IInterface; ip: string): integer;
begin
  Result := strtoint(GetEditValue(ElementByIP(e, ip)));
end;
end.