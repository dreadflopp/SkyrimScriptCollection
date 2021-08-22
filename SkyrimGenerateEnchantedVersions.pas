
unit GenerateEnchantedVersions;

interface
implementation
uses SkyrimUtils, mtefunctions, dfFunctions;

// =Settings
const
// should generator add MagicDisallowEnchanting keyword to the enchanted versions? (boolean)
setMagicDisallowEnchanting = false;

HeavyArmoryTweaks = false;
AnimatedArmouryTweaks = false;
SSMTweaks = true;
waccf = true;
hllr = false;
summermyst = true;
vanilla = true;
summermyst_filename = 'Summermyst - Enchantments of Skyrim.esp';

var
pluginGenerated, pluginSelected, keywordQS: IInterface;
allWeaponTypes: TStringList;
summermyst_index: string;


// creates empty list with name
function createList(name: string): IInterface;
var
lvllist, group: IInterface;
enchLevelListGroup: IInterface;
begin 
	group := GroupBySignature(pluginGenerated, 'LVLI');
	lvllist := MainRecordByEditorID(group, name);
	
	// create lvllist for
	if not assigned(lvllist) then
	begin
		lvllist := createRecord(pluginGenerated,'LVLI');
		
		// set the flags
		SetElementEditValues(lvllist, 'LVLF', 11); // 11 => Calculate from all levels, and for each item in count
		
		// define items group inside the Leveled List
		Add(lvllist, 'Leveled List Entries', true);
		
		enchLevelListGroup := ElementByPath(lvllist, 'Leveled List Entries');
		
		// remove automatic zero entry
		removeInvalidEntries(lvllist);	
		
		SetElementEditValues(lvllist, 'EDID', name);
	end;
	
	Result := lvllist;
end;

function createEnchantedVersion(baseRecord: IInterface; objEffect: string; suffix: string; enchantmentAmount: integer; prefix: boolean): IInterface;
var
enchRecord, enchRecordLeftClaw, recLeftClaw, group, clawList, enchantment, keyword: IInterface;
isClaw: boolean;
durationStr, magnitudeStr, suffixShorted: string;
duration, magnitude: Double;
begin
	
	isClaw := false;
	
	enchRecord := wbCopyElementToFile(baseRecord, pluginGenerated, true, true);
	
	// Check if claws
	if (getType(enchRecord) = 'Claw') then
	begin
		isClaw := true;
		group := GroupBySignature(pluginSelected, 'WEAP');
		recLeftClaw := MainRecordByEditorID(group, GetElementEditValues(baseRecord, 'EDID') + 'Left');
		enchRecordLeftClaw := wbCopyElementToFile(recLeftClaw, pluginGenerated, true, true);
	end;
	
	// find record for Object Effect ID
	enchantment := getRecordByFormID(objEffect);
	
	// add object effect
	SetElementEditValues(enchRecord, 'EITM', GetEditValue(enchantment));
	
	// add template
	SetElementEditValues(enchRecord, 'CNAM', Name(baseRecord));
	
	// set enchantment amount
	SetElementEditValues(enchRecord, 'EAMT', enchantmentAmount);
	
	// suffix the FULL, for easy finding and manual editing
	
	//if ((objEffect = '0005B46C') OR (objEffect = '0005B46D') OR (objEffect = '0005B46E') OR (objEffect = '0005B46F') OR (objEffect = '0005B470') OR (objEffect = '000BF3F5')) then
	//	SetElementEditValues(enchRecord, 'FULL', suffix + ' ' + GetElementEditValues(baseRecord, 'FULL'));

	if (prefix = false)	then	
		SetElementEditValues(enchRecord, 'FULL', GetElementEditValues(baseRecord, 'FULL') + ' of ' + suffix);
	if (prefix = true) then
		SetElementEditValues(enchRecord, 'FULL', suffix + ' ' + GetElementEditValues(baseRecord, 'FULL'));
	
	// change name by adding suffix
	if (Pos('the', suffix) > 0) then
	begin
		suffixShorted := StringReplace(suffix,' ','',[rfReplaceAll, rfIgnoreCase]);
	end
	else
		suffixShorted := suffix;
	SetElementEditValues(enchRecord, 'EDID', GetElementEditValues(baseRecord, 'EDID') + 'Ench' + suffixShorted);
	
	// makeTemperable(enchRecord);
	
	if setMagicDisallowEnchanting = true then begin
		// add MagicDisallowEnchanting [KYWD:000C27BD] keyword if not present
		addKeyword(enchRecord, getRecordByFormID('000C27BD'));
	end;
	
	// mimic if claw
	if (isClaw = true) then 
	begin
		SetElementEditValues(enchRecordLeftClaw, 'EITM', GetEditValue(enchantment));
		SetElementEditValues(enchRecordLeftClaw, 'CNAM', Name(recLeftClaw));
		SetElementEditValues(enchRecordLeftClaw, 'EAMT', enchantmentAmount);
		SetElementEditValues(enchRecordLeftClaw, 'EDID', GetElementEditValues(enchRecordLeftClaw, 'EDID') + 'Ench' + suffix);
		SetElementEditValues(enchRecordLeftClaw, 'FULL', GetElementEditValues(enchRecordLeftClaw, 'FULL') + ' of ' + suffix);
		if setMagicDisallowEnchanting = true then begin
		// add MagicDisallowEnchanting [KYWD:000C27BD] keyword if not present
		addKeyword(enchRecordLeftClaw, getRecordByFormID('000C27BD'));
		end;
	end;
	
	// Add keywords if nescessary
	if (AnimatedArmouryTweaks = true) AND (getType(baseRecord) = 'Quarterstaff') then
		addKeyword(enchRecord, keywordQS);
	
	// return it
	if (isClaw = true) then
	begin
		clawList := createList('LItem' + getMainMaterialShort(baseRecord) + suffix + 'Claws');
		addToLeveledList(clawList, enchRecord, 1);
		addToLeveledList(clawList, enchRecordLeftClaw, 1);
		
		// set the flags
		SetElementEditValues(clawList, 'LVLF', 0);
		SetElementEditValues(clawList, 'LVLF\Use All', 1);
		
		Result := clawList;
	end
	else
		Result := enchRecord;
end;

procedure processSublist(
sublist: IInterface;
enchType: string;
material: string; 
weaponType: string;
);
var
LItemEnchMaterialWeapon, LItemEnchMaterialWeaponBoss, LItemEnchSteelWeaponDremoraFire, LItemEnchIronWeaponDremoraFire, LItemEnchGlassWeaponDremoraFire, LItemEnchEbonyWeaponDremoraFire, LItemEnchDaedricWeaponDremoraFire: IInterface;
i: integer;
begin	
	// Normal LItem list
	LItemEnchMaterialWeapon := createList('LItemEnch' + material + weaponType);
	addToLeveledList(LItemEnchMaterialWeapon, sublist, 1);
	
	// Boss list
	if not (weaponType = 'Dagger') AND not (weaponType = 'Claw') then 
	begin
		if (enchType = 'Fire') OR (enchType = 'Frost') OR (enchType = 'Magica') OR (enchType = 'Shock') OR (enchType = 'Stamina') then 
		begin
			//AddMessage('   Adding ' + material + ' '  + enchType + ' ' + weaponType + 's to boss lists');
			LItemEnchMaterialWeaponBoss := createList('LitemEnch' + material + weaponType + 'Boss');
			addToLeveledList(LItemEnchMaterialWeaponBoss, sublist, 1);
		end;
	end;
	
	// Dremora LItem list
	if (enchType = 'Fire') OR (enchType = 'FireDmgLingering') OR (enchType = 'FireHazard') then
	begin
		if not (weaponType = 'Dagger') AND not (weaponType = 'Claw') then
		begin
		
			//AddMessage('   Adding ' + material + ' '  + enchType + ' ' + weaponType + 's to Dremora lists');
			
			// Add to level lists
			if (material = 'Iron') then 
			begin 
				LItemEnchIronWeaponDremoraFire := wbCopyElementToFile(getRecordByFormID('00017003'), pluginGenerated, false, true);
				addToLeveledList(LItemEnchIronWeaponDremoraFire, sublist, 1); 
			end
			else if (material = 'Steel') then 
			begin 
				LItemEnchSteelWeaponDremoraFire := wbCopyElementToFile(getRecordByFormID('00017002'), pluginGenerated, false, true);
				addToLeveledList(LItemEnchSteelWeaponDremoraFire, sublist, 1); 
			end
			else if (material = 'Glass') then 
			begin 
				LItemEnchGlassWeaponDremoraFire := wbCopyElementToFile(getRecordByFormID('00017004'), pluginGenerated, false, true);
				addToLeveledList(LItemEnchGlassWeaponDremoraFire, sublist, 1); 
			end
			else if (material = 'Ebony') then 
			begin 
				LItemEnchEbonyWeaponDremoraFire := wbCopyElementToFile(getRecordByFormID('00017005'), pluginGenerated, false, true);
				addToLeveledList(LItemEnchEbonyWeaponDremoraFire, sublist, 1); 
			end
			else if (material = 'Daedric') then 
			begin 
				LItemEnchDaedricWeaponDremoraFire := wbCopyElementToFile(getRecordByFormID('00017006'), pluginGenerated, false, true);
				addToLeveledList(LItemEnchDaedricWeaponDremoraFire, sublist, 1); 
			end;
		end;
	end;	
	
	//AddMessage('... finished processing sublist: ' + 'SublistEnch' + material + weaponType + enchType);
end;

procedure createLItemLists(
material: string; 
weaponType: string
);
var
LItemEnchMaterialWeapon, blacksmithList, normalList, normalListLowMid, normalListMid, dlc2NormalList, daedric05List, daedric05BestList, specialList, dlc2SpecialList, dlc2BestList, tmpGroup, DLC2LItemEnchWeapon1H, DLC2LItemEnchWeapon2H, DLC2LItemEnchWeaponAnySpecial, DLC2LItemEnchWeaponAnyBest, LItemEnchWeapon1H, LItemEnchWeapon1HSpecial, LItemEnchWeapon2HSpecial, LItemEnchWeaponBlacksmith1H, LItemEnchWeaponBlacksmith2H, LItemEnchWeapon2H, glass05List, GlassBest05List, stalhrim05List, ebony05List, ebonyBest05List: IInterface;
i: integer;
begin
	//AddMessage('Adding ' + material + ' ' + weaponType + 's to LItem lists...');
	
	// Initiate level lists
	LItemEnchMaterialWeapon := createList('LItemEnch' + material + weaponType);
	
	blacksmithList := createList('LItemEnchWeapon' + weaponType + 'BlackSmith');
	normalList := createList('LItemEnchWeapon' + weaponType);
	dlc2NormalList := createList('DLC2LitemEnchWeapon' + weaponType);
	specialList := createList('LItemEnchWeapon' + weaponType + 'Special');
	dlc2SpecialList := createList('DLC2LitemEnchWeapon' + weaponType + 'Special');
	dlc2BestList := createList ('DLC2LitemEnchWeapon' + weaponType + 'Best');
	
	if (hllr = true) then
	begin
		normalListLowMid := createList('LItemEnchWeapon' + weaponType + 'LowMid');
		normalListMid := createList('LItemEnchWeapon' + weaponType + 'Mid');
	end;
	
	// Add to level lists
	if material = 'Iron' then
	begin
		for i := 0 to 3 do
		begin
			addToLeveledList(blacksmithList, LItemEnchMaterialWeapon, 1);
		end;
		for i := 0 to 2 do
		begin
			addToLeveledList(normalList, LItemEnchMaterialWeapon, 1);
			addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 1);
		end;
		addToLeveledList(specialList, LItemEnchMaterialWeapon, 1);
		addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 1);
		addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, 1);
		if (hllr = true) then 
		begin
			addToLeveledList(normalListLowMid, LItemEnchMaterialWeapon, 1);			
		end;
	end 
	else if material = 'Steel' then
	begin
		if ((HeavyArmoryTweaks = true) AND (weaponType = 'Quarterstaff')) then
		begin
			addToLeveledList(blacksmithList, LItemEnchMaterialWeapon, 1);
			for i := 5 to 6 do
			begin
				addToLeveledList(normalList, LItemEnchMaterialWeapon, i);
				addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, i);
				addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, i);
			end;
			addToLeveledList(normalList, LItemEnchMaterialWeapon, 1);
			addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 1);
			addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, 1);
			addToLeveledList(specialList, LItemEnchMaterialWeapon, 1);
			addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 1);
			if (hllr = true) then 
			begin
				addToLeveledList(normalListLowMid, LItemEnchMaterialWeapon, 1);
				addToLeveledList(normalListLowMid, LItemEnchMaterialWeapon, 1);
			end;
		end		
		else
		begin
			addToLeveledList(blacksmithList, LItemEnchMaterialWeapon, 4);
			for i := 4 to 6 do
			begin
				addToLeveledList(normalList, LItemEnchMaterialWeapon, i);
				addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, i);
				addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, i);
			end;
			addToLeveledList(specialList, LItemEnchMaterialWeapon, 4);
			addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 4);
			if (hllr = true) then 
			begin
				addToLeveledList(normalListLowMid, LItemEnchMaterialWeapon, 1);	
			end;
		end;		
	end 
	else if material = 'Orcish' then 
	begin
		if (waccf = true) then
		begin
			addToLeveledList(blacksmithList, LItemEnchMaterialWeapon, 20);
			addToLeveledList(normalList, LItemEnchMaterialWeapon, 20);
			addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 20);
			addToLeveledList(specialList, LItemEnchMaterialWeapon, 20);
			addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 20);
			addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, 22);
			
		end
		else
		begin
			addToLeveledList(blacksmithList, LItemEnchMaterialWeapon, 7);
			addToLeveledList(normalList, LItemEnchMaterialWeapon, 7);
			addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 7);
			addToLeveledList(specialList, LItemEnchMaterialWeapon, 7);
			addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 7);
			addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, 7);
		end;
		if (hllr = true) then 
		begin
			addToLeveledList(normalListLowMid, LItemEnchMaterialWeapon, 1);		
			addToLeveledList(normalListMid, LItemEnchMaterialWeapon, 1);
		end;
	end
	else if material = 'Dwarven' then 
	begin
		if (waccf = true) then
		begin
			addToLeveledList(blacksmithList, LItemEnchMaterialWeapon, 7);
			addToLeveledList(normalList, LItemEnchMaterialWeapon, 7);
			addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 7);
			addToLeveledList(specialList, LItemEnchMaterialWeapon, 7);
			addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 7);
			addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, 7);	
		end
		else
		begin
			addToLeveledList(blacksmithList, LItemEnchMaterialWeapon, 13);
			addToLeveledList(normalList, LItemEnchMaterialWeapon, 13);
			addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 13);
			addToLeveledList(specialList, LItemEnchMaterialWeapon, 13);
			addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 13);
			addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, 14);		
		end;
		if (hllr = true) then 
		begin
			addToLeveledList(normalListLowMid, LItemEnchMaterialWeapon, 1);
			addToLeveledList(normalListMid, LItemEnchMaterialWeapon, 1);		
		end;
	end
	else if material = 'Nordic' then 
	begin
		addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 19);
		addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 19);
	end
	else if material = 'Elven' then 
	begin
		if (waccf = true) then
		begin
			addToLeveledList(blacksmithList, LItemEnchMaterialWeapon, 13);
			addToLeveledList(normalList, LItemEnchMaterialWeapon, 13);
			addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 13);
			addToLeveledList(specialList, LItemEnchMaterialWeapon, 13);
			addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 13);
			addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, 14);
		end
		else
		begin
			addToLeveledList(blacksmithList, LItemEnchMaterialWeapon, 20);
			addToLeveledList(normalList, LItemEnchMaterialWeapon, 20);
			addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 20);
			addToLeveledList(specialList, LItemEnchMaterialWeapon, 20);
			addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 20);
			addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, 22);
		end;
		if (hllr = true) then 
		begin
			addToLeveledList(normalListLowMid, LItemEnchMaterialWeapon, 1);
			addToLeveledList(normalListMid, LItemEnchMaterialWeapon, 1);	
		end;
	end
	else if material = 'Glass' then 
	begin
		if (hllr = true) then
		begin
			// create 05
			glass05List := createList('SublistEnchWeapon' + weaponType + 'Glass05');
			tmpGroup := Add(glass05List, 'Leveled List Entries', true);
		
			// if empty, fill 05
			if ElementCount(tmpGroup) = 0 then
			begin
				for i := 0 to 3 do
				begin
					addToLeveledList(glass05List, normalListLowMid, 1);
				end;
				addToLeveledList(glass05List, LItemEnchMaterialWeapon, 1);
			end;
		
			// create Best05
			GlassBest05List := createList('SublistEnchWeapon' + weaponType + 'GlassBest05');
			tmpGroup := Add(GlassBest05List, 'Leveled List Entries', true);
		
			// if empty, fill Best05
			if ElementCount(tmpGroup) = 0 then
			begin
				for i := 0 to 3 do
				begin
					addToLeveledList(GlassBest05List, normalListMid, 1);
				end;
				addToLeveledList(GlassBest05List, LItemEnchMaterialWeapon, 1);
			end;	
			
			addToLeveledList(blacksmithList, glass05List, 28);
			addToLeveledList(normalList, glass05List, 28);
			addToLeveledList(dlc2NormalList, glass05List, 28);
			addToLeveledList(specialList, glass05List, 28);
			addToLeveledList(dlc2SpecialList, glass05List, 28);
			addToLeveledList(dlc2BestList, GlassBest05List, 31);
		end
		else
		begin
			addToLeveledList(blacksmithList, LItemEnchMaterialWeapon, 28);
			addToLeveledList(normalList, LItemEnchMaterialWeapon, 28);
			addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 28);
			addToLeveledList(specialList, LItemEnchMaterialWeapon, 28);
			addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 28);
			addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, 31);
		end;
	end
	else if material = 'Stalhrim' then 
	begin
		if (hllr = true) then
		begin
			// create 05
			stalhrim05List := createList('SublistEnchWeapon' + weaponType + 'Stalhrim05');
			tmpGroup := Add(stalhrim05List, 'Leveled List Entries', true);
		
			// if empty, fill 05
			if ElementCount(tmpGroup) = 0 then
			begin
				for i := 0 to 8 do
				begin
					addToLeveledList(stalhrim05List, normalListLowMid, 1);
				end;
				addToLeveledList(stalhrim05List, LItemEnchMaterialWeapon, 1);
			end;				
			addToLeveledList(dlc2NormalList, stalhrim05List, 36);
			addToLeveledList(dlc2SpecialList, stalhrim05List, 36);
		end
		else begin
		addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 36);
		addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 36);
		end;
	end
	else if material = 'Ebony' then 
	begin
		if (hllr = true) then
		begin
			// create 05
			ebony05List := createList('SublistEnchWeapon' + weaponType + 'Ebony05');
			tmpGroup := Add(ebony05List, 'Leveled List Entries', true);
		
			// if empty, fill 05
			if ElementCount(tmpGroup) = 0 then
			begin
				for i := 0 to 8 do
				begin
					addToLeveledList(ebony05List, normalListLowMid, 1);
				end;
				addToLeveledList(ebony05List, LItemEnchMaterialWeapon, 1);
			end;
		
			// create Best05
			ebonyBest05List := createList('SublistEnchWeapon' + weaponType + 'EbonyBest05');
			tmpGroup := Add(ebonyBest05List, 'Leveled List Entries', true);
		
			// if empty, fill Best05
			if ElementCount(tmpGroup) = 0 then
			begin
				for i := 0 to 8 do
				begin
					addToLeveledList(ebonyBest05List, normalListMid, 1);
				end;
				addToLeveledList(ebonyBest05List, LItemEnchMaterialWeapon, 1);
			end;
			addToLeveledList(blacksmithList, ebony05List, 37);
			addToLeveledList(normalList, ebony05List, 37);
			addToLeveledList(dlc2NormalList, ebony05List, 37);
			addToLeveledList(specialList, ebony05List, 37);
			addToLeveledList(dlc2SpecialList, ebony05List, 37);
			addToLeveledList(dlc2BestList, ebonyBest05List, 41);
		end
		else begin		
			addToLeveledList(blacksmithList, LItemEnchMaterialWeapon, 37);
			addToLeveledList(normalList, LItemEnchMaterialWeapon, 37);
			addToLeveledList(dlc2NormalList, LItemEnchMaterialWeapon, 37);
			addToLeveledList(specialList, LItemEnchMaterialWeapon, 37);
			addToLeveledList(dlc2SpecialList, LItemEnchMaterialWeapon, 37);
			addToLeveledList(dlc2BestList, LItemEnchMaterialWeapon, 41);
		end;
	end
	else if material = 'Daedric' then
	begin
		
		// create daedric05
		daedric05List := createList('SublistEnchWeapon' + weaponType + 'Daedric05');
		tmpGroup := Add(daedric05List, 'Leveled List Entries', true);
		
		// if empty, fill daedric05
		if ElementCount(tmpGroup) = 0 then
		begin
			for i := 0 to 18 do
			begin
				addToLeveledList(daedric05List, blacksmithList, 1);
			end;
			addToLeveledList(daedric05List, LItemEnchMaterialWeapon, 1);
		end;
		
		// create daedricBest05
		daedric05BestList := createList('SublistEnchWeapon' + weaponType + 'DaedricBest05');
		tmpGroup := Add(daedric05BestList, 'Leveled List Entries', true);
		
		// if empty, fill daedricBest05
		if ElementCount(tmpGroup) = 0 then
		begin
			for i := 0 to 18 do
			begin
				addToLeveledList(daedric05BestList, normalList, 1);
			end;
			addToLeveledList(daedric05BestList, LItemEnchMaterialWeapon, 1);
		end;
		
		// add to list
		addToLeveledList(normalList, daedric05List, 47);	
		addToLeveledList(dlc2NormalList, daedric05List, 47);	
		addToLeveledList(specialList, daedric05List, 47);		
		addToLeveledList(dlc2SpecialList, daedric05List, 47);
		addToLeveledList(dlc2BestList, daedric05BestList, 52);
	end;
	
	//AddMessage('...finished');
	
end;

procedure addToVanillaLists(weaponType: string);
var
blacksmithList, normalList, dlc2NormalList, specialList, dlc2SpecialList, dlc2BestList, DLC2LItemEnchWeapon1H, DLC2LItemEnchWeapon2H, DLC2LItemEnchWeaponAnySpecial, DLC2LItemEnchWeaponAnyBest, LItemEnchWeapon1H, LItemEnchWeapon1HSpecial, LItemEnchWeapon2HSpecial, LItemEnchWeaponBlacksmith1H, LItemEnchWeaponBlacksmith2H, LItemEnchWeapon2H: IInterface;
i: integer;
begin
	//AddMessage('Adding to vanilla lists...');
	
	// Initiate level lists
	
	blacksmithList := createList('LItemEnchWeapon' + weaponType + 'BlackSmith');
	normalList := createList('LItemEnchWeapon' + weaponType);
	dlc2NormalList := createList('DLC2LitemEnchWeapon' + weaponType);
	specialList := createList('LItemEnchWeapon' + weaponType + 'Special');
	dlc2SpecialList := createList('DLC2LitemEnchWeapon' + weaponType + 'Special');
	dlc2BestList := createList ('DLC2LitemEnchWeapon' + weaponType + 'Best');
	
	// Add to vanilla lists
	if (isOneHanded(weaponType)) then
	begin
		LItemEnchWeapon1H := wbCopyElementToFile(getRecordByFormID('0004B58B'), pluginGenerated, false, true);
		addToLeveledList(LItemEnchWeapon1H, normalList, 1);
		if not (weaponType = 'Dagger') AND not (weaponType = 'Claw') then addToLeveledList(LItemEnchWeapon1H, normalList, 1);	
		
		LItemEnchWeapon1HSpecial := wbCopyElementToFile(getRecordByFormID('001031A8'), pluginGenerated, false, true);
		addToLeveledList(LItemEnchWeapon1HSpecial, specialList, 1);
		if not (weaponType = 'Dagger') AND not (weaponType = 'Claw') then addToLeveledList(LItemEnchWeapon1HSpecial, specialList, 1);
		
		LItemEnchWeaponBlacksmith1H := wbCopyElementToFile(getRecordByFormID('00000ED5'), pluginGenerated, false, true);
		addToLeveledList(LItemEnchWeaponBlacksmith1H, blacksmithList, 1);
		if not (weaponType = 'Dagger') AND not (weaponType = 'Claw') then addToLeveledList(LItemEnchWeaponBlacksmith1H, blacksmithList, 1);
		
		DLC2LItemEnchWeapon1H := wbCopyElementToFile(getRecordByFormID('0402BC0A'), pluginGenerated, false, true);
		addToLeveledList(DLC2LItemEnchWeapon1H, dlc2NormalList, 1);
		if not (weaponType = 'Dagger') AND not (weaponType = 'Claw') then addToLeveledList(DLC2LItemEnchWeapon1H, dlc2NormalList, 1);
	end;	
	
	
	if not (isOneHanded(weaponType)) then 
	begin
		LItemEnchWeapon2H := wbCopyElementToFile(getRecordByFormID('00089932'), pluginGenerated, false, true);
		addToLeveledList(LItemEnchWeapon2H, normalList, 1);	
		
		LItemEnchWeapon2HSpecial := wbCopyElementToFile(getRecordByFormID('001031A9'), pluginGenerated, false, true);
		addToLeveledList(LItemEnchWeapon2HSpecial, specialList, 1);
		
		LItemEnchWeaponBlacksmith2H := wbCopyElementToFile(getRecordByFormID('00000EDA'), pluginGenerated, false, true);
		addToLeveledList(LItemEnchWeaponBlacksmith2H, blacksmithList, 1);
		
		DLC2LItemEnchWeapon2H := wbCopyElementToFile(getRecordByFormID('0402BC0B'), pluginGenerated, false, true);
		addToLeveledList(DLC2LItemEnchWeapon2H, dlc2NormalList, 1);
	end;
	
	DLC2LItemEnchWeaponAnySpecial := wbCopyElementToFile(getRecordByFormID('0402BC38'), pluginGenerated, false, true);
	addToLeveledList(DLC2LItemEnchWeaponAnySpecial, dlc2SpecialList, 1);
	
	
	DLC2LItemEnchWeaponAnyBest := wbCopyElementToFile(getRecordByFormID('0401FF1A'), pluginGenerated, false, true);
	addToLeveledList(DLC2LItemEnchWeaponAnyBest, dlc2BestList, 1);
	
	//AddMessage('...finished');
	
end;

// runs on script start
function Initialize: integer;
begin
	AddMessage('---Starting Generator---');
	allWeaponTypes := TStringList.Create;
	allWeaponTypes.Sorted := True;
	allWeaponTypes.Duplicates := dupIgnore;

	if (summermyst = true) then
		summermyst_index := IntToHex(GetLoadOrder(GetPlugin(summermyst_filename)), 2);

	Result := 0;
end;

// for every record selected in xEdit
function Process(selectedRecord: IInterface): integer;
var
material, weaponType, ench, enchType: string;
sublist, enchLevelListGroup: IInterface;
recordSignature: string;
slMasters: TStringList;
i, tier1, tier2, tier3, tier4, tier5, tier6, charge1, charge2, charge3, charge4, charge5, charge6: integer;

begin
	pluginSelected := GetFile(selectedRecord);
	recordSignature := Signature(selectedRecord);
	
	
	// filter selected records, which are invalid for script
	if not (recordSignature = 'WEAP') then
	Exit;
	
	// Create plugin if needed
	if not Assigned(pluginGenerated) then 
	begin
		pluginGenerated := AddNewFile;
		
		// add masters
		slMasters := TStringList.Create;
		AddMastersToList(GetFile(selectedRecord), slMasters);
		
		AddMastersToFile(pluginGenerated, slMasters, False);
		AddMasterIfMissing(pluginGenerated, 'Skyrim.esm');
		AddMasterIfMissing(pluginGenerated, 'Update.esm');
		AddMasterIfMissing(pluginGenerated, 'Dawnguard.esm');
		AddMasterIfMissing(pluginGenerated, 'Hearthfires.esm');
		AddMasterIfMissing(pluginGenerated, 'Dragonborn.esm');

		if (summermyst = true) then
			AddMasterIfMissing(pluginGenerated, summermyst_filename);
		
		// If Animated Armoury, add Quarterstaff keyword
		if AnimatedArmouryTweaks = true then
		begin
			//group = GroupBySignature(pluginGenerated, 'KYWD');
			keywordQS := createRecord(pluginGenerated, 'KYWD');
			Add(keywordQS, 'CNAM', true);
			Add(keywordQS, 'EDID', true);
			SetElementEditValues(keywordQS, 'EDID', 'WeapTypeQuarterstaff');
		end;
		
	end;
	
	if not Assigned(pluginGenerated) then
	Exit;  
	
	//------------------------
		// =SKYRIM OBJECT EFFECTS
	//------------------------
	weaponType := getType(selectedRecord);
	material := getMainMaterialShort(selectedRecord);

	// bail if aa and...
	if AnimatedArmouryTweaks = true then
	begin
		if (weaponType = 'Whip') then
		Exit;
		
		if (Pos('Left', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
		
		if (Pos('Akaviri', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
		
		if (Pos('Forsworn', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
	
		if (Pos('Skyforge', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
		
		if (Pos('Redguard', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
		
		if (Pos('Dawnguard', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
		
		if (Pos('DragonPriestClaws', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
		
		if (Pos('DBClaws', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
		
		if (Pos('Invis', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
		
		if (Pos('Bound', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
	end;

	// bail if ssm and...
	if SSMTweaks = true then
	begin
		if (weaponType = 'Javelin') then
		Exit;
		
		if (Pos('Dummy', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
		
		if (Pos('Elder', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
	end;	

	// bail if any of these materials
	if (material = 'Blades') OR (material = 'Draugr') OR (material = 'DraugrHoned') OR (material = 'Dawnguard') OR (material = 'Falmer') OR (material = 'FalmerHoned') OR (material = 'Forsworn') OR (material = 'Redguard') OR (material = 'Silver') OR (material = 'Skyforge') OR (material = 'Imperial') OR (material = 'Dragonbone') OR (material = 'Skip_ench') then
	Exit;

	// Set charge
	charge1 := 500;
	charge2 := 1000;
	charge3 := 1500;
	charge4 := 2000;
	charge5 := 2500;
	charge6 := 3000;

	if (material = 'Imperial') then
	begin
		charge1 := 200;
		charge2 := 300;
		charge3 := 400;
		charge4 := 500;
		charge5 := 500;
		charge6 := 700;
	end;

	if (summermyst = true) then
	begin

		allWeaponTypes.Add(weaponType);
			
		// Weapons added to Absorb Stamina lists
		if material = 'Iron' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 13;
			tier3 := 15;
			tier4 := 17;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 7;
			tier3 := 9;
			tier4 := 11;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 20;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end	
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 28;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 36;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 13;
				tier3 := 15;
				tier4 := 17;
				tier5 := 0;
				tier6 := 0;
			end
			else if material = 'Dwarven' then
			begin
				tier1 := 0;
				tier2 := 7;
				tier3 := 9;
				tier4 := 11;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 20;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end
		end;

		enchType := 'AbsorbArmor';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0510DD', 'Electrolysis', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0510DD', 'Chrome', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05111F', 'Anodization', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051120', 'Electroplating', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051121', 'Galvanization', charge6, false), tier6);

		enchType := 'Balefire';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513F9', 'Balefire', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513FA', 'Hellfire', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513FB', 'Abaddon', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513FC', 'Blackfire', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513FD', 'the Pit', charge6, false), tier6);

		enchType := 'IllusoryBurden';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511A8', 'Burdens', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511A9', 'Weight', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511AA', 'Encumbrance', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511AB', 'Ballast', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511AC', 'Mass', charge6, false), tier6);

		enchType := 'Beaconbound';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05143D', 'Azura', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051440', 'Greybeards', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051441', 'Labyrinthian', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051436', 'Winterhold', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05143C', 'Energies', charge6, false), tier6);
			
		// Weapons added to paralyze
		if material = 'Iron' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end	
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 36;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 0;
				tier4 := 0;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 0;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end
		end;

		enchType := 'AbsorbSpeed';
		if (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051119', 'Cunning', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05111B', 'Wile', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051121', 'Mischief', charge6, false), tier6);

		enchType := 'DrainMagicResist';
		if (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05111C', 'Razing', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05111D', 'Subjugation', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05111E', 'Oppression', charge6, false), tier6);

		enchType := 'StealWeapon';
		if (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051195', 'Grappling', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051196', 'Hooks', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051197', 'Snatching', charge6, false), tier6);

		enchType := 'HiddenSerpent';
		if (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511C5', 'Vipers', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511C6', 'Adders', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511C7', 'Asps', charge6, false), tier6);

		enchType := 'Heal';
		if (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05110C', 'Healing', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05110D', 'Mercy', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05110E', 'Compassion', charge6, false), tier6);		

		// Weapons added to stamina
		if material = 'Iron' then
		begin
			tier1 := 1;
			tier2 := 4;
			tier3 := 6;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 4;
			tier2 := 6;
			tier3 := 8;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 4;
			tier2 := 6;
			tier3 := 8;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 13;
			tier3 := 15;
			tier4 := 17;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 7;
			tier3 := 9;
			tier4 := 11;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 20;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end	
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 28;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 36;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 13;
				tier3 := 15;
				tier4 := 17;
				tier5 := 0;
				tier6 := 0;
			end
			else if material = 'Dwarven' then
			begin
				tier1 := 0;
				tier2 := 7;
				tier3 := 9;
				tier4 := 11;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 20;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end
		end;

		enchType := 'DrainArmor';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513E4', 'Denting', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05118F', 'Crushing', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051190', 'Bending', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051191', 'Buckling', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051192', 'Crumpling', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051193', 'Dismantling', charge6, false), tier6);

		enchType := 'BattleHunger';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511F5', 'Anger', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511F6', 'Ire', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511F7', 'Jinxes', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511F8', 'Curses', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511F9', 'Hexes', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511FA', 'Hate', charge6, false), tier6);

		enchType := 'Momentum';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051222', 'Momentum', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051223', 'Dominance', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051224', 'Authority', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051225', 'Superiority', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051226', 'Repression', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051227', 'Supremacy', charge6, false), tier6);

		enchType := 'HaltRegen';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05116F', 'Dying', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05116C', 'Wasting', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05116D', 'Withering', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05116E', 'Wilting', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513E9', 'Atrophy', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513EA', 'Putrefaction', charge6, false), tier6);	

		// Weapons added to magica
		if material = 'Iron' then
		begin
			tier1 := 1;
			tier2 := 4;
			tier3 := 6;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 4;
			tier2 := 6;
			tier3 := 8;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 4;
			tier2 := 6;
			tier3 := 8;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 13;
			tier3 := 15;
			tier4 := 17;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 7;
			tier3 := 9;
			tier4 := 11;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 20;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end	
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 13;
				tier3 := 15;
				tier4 := 17;
				tier5 := 0;
				tier6 := 0;
			end
			else if material = 'Dwarven' then
			begin
				tier1 := 0;
				tier2 := 7;
				tier3 := 9;
				tier4 := 11;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 20;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end
		end;

		enchType := 'Berserking';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051219', 'Bloodstained', charge1, true), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05121A', 'Executioner''s', charge2, true), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05121B', 'Rage', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05121C', 'Decimation', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513ED', 'Fury', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05121E', 'Viscera', charge6, false), tier6);	

		enchType := 'PoisonDmg';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;

		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051230', 'Venom', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051231', 'Blight', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051232', 'Rot', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051234', 'Corruption', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051233', 'Miasma', charge6, false), tier6);	

		enchType := 'PoisonDmgCumulative';
		if (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05125D', 'Infection', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05125E', 'Infirmity', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05125F', 'Sickness', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051260', 'Malady', charge6, false), tier6);

		enchType := 'DiseaseDmg';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051400', 'Blistering', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051403', 'Bubbling', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051404', 'Festering', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051405', 'Seething', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051406', 'Ulceration', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051407', 'Necrosis', charge6, false), tier6);

		// Weapons added to turn
		
		enchType := 'CmdDaedra';
		if (tier1 > 0) OR(tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513E5', 'Command', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513E6', 'Domination', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513E7', 'the Conjurer', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051179', 'the coven', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05117A', 'the Summoner', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05117B', 'the Warlock', charge6, false), tier6);	

		enchType := 'Discharge';
		if (tier1 > 0) OR(tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511CC', 'Discharching', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511CD', 'Shorting', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511CE', 'Spoliation', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511CF', 'Depletion', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511D0', 'Interference', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511D0', 'Disenchanting', charge6, false), tier6);	

		enchType := 'SunDamage';
		if (tier1 > 0) OR(tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051160', 'Dawn', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051161', 'Daylight', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051162', 'Noon', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051163', 'Radiance', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051164', 'Resplendence', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051165', 'Brilliance', charge6, false), tier6);	

		// Weapons added to Fear
		
		enchType := 'DeathsDoor';
		if (tier1 > 0) OR(tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513EB', 'Death''s Door', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513EC', 'the Threads', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513ED', 'Mortality', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513EE', 'the Fates', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513EF', 'the Wyress', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051510', 'the Broken Crown', charge6, false), tier6);	

		enchType := 'ThresholdThrow';
		if (tier1 > 0) OR(tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0510FD', 'Throwing', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0510FE', 'Slinging', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0510FF', 'Havoc', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051198', 'Hurling', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051199', 'Catapulting', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05119A', 'Launching', charge6, false), tier6);

		enchType := 'Might';
		if (tier1 > 0) OR(tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513F0', 'Might', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513F1', 'Valor', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513F2', 'Muscle', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513F3', 'Despotism', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513F4', 'Tyranny', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513F5', 'Quietus', charge6, false), tier6);

		enchType := 'DimVision';
		if (tier1 > 0) OR(tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513EC', 'Dimming', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513ED', 'Blinding', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513EE', 'Blackness', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051189', 'Phantoms', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05118A', 'Wights', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05118B', 'Shadows', charge6, false), tier6);

		// Weapons added to Absorb Magicka
		if material = 'Iron' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 13;
			tier3 := 15;
			tier4 := 17;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 7;
			tier3 := 9;
			tier4 := 11;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 20;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end	
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 28;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 13;
				tier3 := 15;
				tier4 := 17;
				tier5 := 0;
				tier6 := 0;
			end
			else if material = 'Dwarven' then
			begin
				tier1 := 0;
				tier2 := 7;
				tier3 := 9;
				tier4 := 11;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 20;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end
		end;

		enchType := 'Clumsy';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511A3', 'Clumsiness', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511A4', 'Twitching', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051105', 'Spasming', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051106', 'Incompetence', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051107', 'Idiocy', charge6, false), tier6);	

		enchType := 'Karma';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05112B', 'Spite', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05112C', 'Retribution', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05112D', 'Reckoning', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05112E', 'Justice', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05112F', 'Karma', charge6, false), tier6);	

		enchType := 'Sound';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511B4', 'Noise', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511B5', 'Annoyance', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051151', 'Irritation', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051152', 'Clamor', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051153', 'Ruckus', charge6, false), tier6);

		enchType := 'Counterspell';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051133', 'Cancellation', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051134', 'Grounding', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051135', 'Frustration', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051136', 'Abjuration', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051137', 'Disjunction', charge6, false), tier6);

		// Weapons added to Absorb Health
		if material = 'Iron' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 13;
			tier3 := 15;
			tier4 := 17;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 7;
			tier3 := 9;
			tier4 := 11;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 20;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end	
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 13;
				tier3 := 15;
				tier4 := 17;
				tier5 := 0;
				tier6 := 0;
			end
			else if material = 'Dwarven' then
			begin
				tier1 := 0;
				tier2 := 7;
				tier3 := 9;
				tier4 := 11;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 20;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end
		end;

		enchType := 'DrainAtkDmg';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05119E', 'Frailty', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511A0', 'Stifling', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511A1', 'Weakness', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511A2', 'Futility', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05119F', 'Incapacitation', charge6, false), tier6);

		enchType := 'ThesholdWail';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511AF', 'Wailing', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511B0', 'Screaming', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511B1', 'Shrieking', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511B2', 'Keening', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511B3', 'Howling', charge6, false), tier6);

		enchType := 'DampenSkills';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0513E8', 'Sorrow', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051454', 'Grief', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051455', 'Faiure', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051456', 'Misery', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051457', 'Tears', charge6, false), tier6);

		enchType := 'Resonance';
		if (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051417', 'Harmonies', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051416', 'Dirges', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051418', 'Elegies', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051419', 'Coronachs', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05141A', 'Threnodies', charge6, false), tier6);

		// Weapons added to Fire
		if material = 'Iron' then
		begin
			tier1 := 1;
			tier2 := 4;
			tier3 := 6;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 4;
			tier2 := 6;
			tier3 := 8;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 4;
			tier2 := 6;
			tier3 := 8;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 13;
			tier3 := 15;
			tier4 := 17;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 7;
			tier3 := 9;
			tier4 := 11;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 20;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end	
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 13;
				tier3 := 15;
				tier4 := 17;
				tier5 := 0;
				tier6 := 0;
			end
			else if material = 'Dwarven' then
			begin
				tier1 := 0;
				tier2 := 7;
				tier3 := 9;
				tier4 := 11;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 20;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end
		end;

		enchType := 'FireDmgLingering';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511D7', 'Smoldering	', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511D8', 'Slow Burning', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511D9', 'Lingering Fire', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511DA', 'Everlasting Fire', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511DB', 'Enduring Fire', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511DC', 'Eternal Fire', charge6, false), tier6);
		
		enchType := 'FireHazard';
		if (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;

		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051245', 'Scorching Blasts', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051246', 'Fire Blasts', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051247', 'Blazing Blasts', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051248', 'Inferno Blasts', charge6, false), tier6);

		// Weapons added to Frost

		enchType := 'FrostDmgPiercing';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511FF', 'Shards	', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051200', 'Crystals', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051201', 'Fragments', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051202', 'Hail', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051204', 'Black Frost', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051203', 'Black ice', charge6, false), tier6);
		
		enchType := 'FrostHazard';
		if(tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;

		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05124B', 'Ice Blasts', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05124C', 'Freezing Blasts', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05124D', 'Chilling Blasts', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05124E', 'Winter Blasts', charge6, false), tier6);

		// Weapons added to Shock

		enchType := 'ShockDmgWild';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511EA', 'Static	', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511EB', 'Jolts', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511EC', 'Voltage', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511ED', 'Surges', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511EE', 'Wrath', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0511EF', 'Electrocution', charge6, false), tier6);
		
		enchType := 'ShockHazard';
		if (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;

		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051251', 'Shock Blasts', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051252', 'Thunder Blasts', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051253', 'Lightning Blasts', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051254', 'Storm Blasts', charge6, false), tier6);

		// Weapons added to Banish
		if material = 'Iron' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 20;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end	
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 0;
				tier4 := 0;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 20;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end
		end;

		enchType := 'Insult';
		if (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05117F', 'Insults', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051180', 'Indignities', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051181', 'Scorn', charge6, false), tier6);

		enchType := 'PowerSurge';
		if (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0510F2', 'Unbound', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0510F4', 'Unfettered', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '0510F3', 'Unleashed', charge6, false), tier6);

		enchType := 'Imprison';
		if (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051122', 'Imprisonment', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051123', 'Dungeon', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051124', 'Penance', charge6, false), tier6);

		// Weapons added to Soul Trap
		if material = 'Iron' then
		begin
			tier1 := 1;
			tier2 := 4;
			tier3 := 6;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 4;
			tier2 := 6;
			tier3 := 8;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 4;
			tier2 := 6;
			tier3 := 8;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 13;
			tier3 := 15;
			tier4 := 17;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 7;
			tier3 := 9;
			tier4 := 11;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 20;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end	
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 13;
				tier3 := 15;
				tier4 := 17;
				tier5 := 0;
				tier6 := 0;
			end
			else if material = 'Dwarven' then
			begin
				tier1 := 0;
				tier2 := 7;
				tier3 := 9;
				tier4 := 11;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 20;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end
		end;

		enchType := 'ShiftingEarth';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051506', 'Soil', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051507', 'Mud', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051508', 'Clay', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051214', 'the Land', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051215', 'Loam', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051216', 'Kaolin', charge6, false), tier6);

		enchType := 'Killstreak';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051209', 'Slaying', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05120A', 'Carnage', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05120B', 'Butchery', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05120C', 'Gore', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05120D', 'Extermination', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05120E', 'Prey', charge6, false), tier6);

		enchType := 'ThresholdDeath';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051116', 'Doom', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051117', 'Culling', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051118', 'Teeth', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051125', 'Agony', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051126', 'Screams', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051127', 'Annihilation', charge6, false), tier6);

		enchType := 'Skyhook';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '05141F', 'Lifting', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051420', 'Force', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051421', 'Orbits', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051422', 'Repulsion', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051423', 'Flux', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, summermyst_index + '051424', 'Levitation', charge6, false), tier6);

	end;

	if (vanilla = true) then
	begin
	
		allWeaponTypes.Add(weaponType);
		
		// Absorb Health		
		if material = 'Iron' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 13;
			tier3 := 15;
			tier4 := 17;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 7;
			tier3 := 9;
			tier4 := 11;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 20;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end	
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 28;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 36;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 13;
				tier3 := 15;
				tier4 := 17;
				tier5 := 0;
				tier6 := 0;
			end
			else if material = 'Dwarven' then
			begin
				tier1 := 0;
				tier2 := 7;
				tier3 := 9;
				tier4 := 11;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 20;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end
		end;
		
		enchType := 'AbsorbH';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA145', 'Absorption', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15A', 'Consuming', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15B', 'Devouring', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15C', 'Leeching', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15D', 'the Vampire', charge6, false), tier6);
		
		
		// Absorb Magica
		enchType := 'AbsorbM';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA158', 'Siphoning', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15E', 'Harrowing', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15F', 'Winnowing', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA160', 'Evoking', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA161', 'the Sorcerer', charge6, false), tier6);
		
		// Absorb Stamina
		enchType := 'AbsorbS';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA159', 'Gleaning', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA162', 'Reaping', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA163', 'Harvesting', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA164', 'Garnering', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA165', 'Subsuming', charge6, false), tier6);
		
		// Banish
		if material = 'Iron' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 36;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 0;
				tier4 := 0;
				tier5 := 0;
				tier6 := 0;
			end
			else if material = 'Dwarven' then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 0;
				tier4 := 0;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 0;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end
		end;
		
		// Banish
		enchType := 'Banish';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBB7', 'Banishing', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBB8', 'Expelling', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBB9', 'Annihilating', charge6, false), tier6);
		
		// Paralyze
		enchType := 'Paralyze';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBBA', 'Stunning', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBBB', 'Immobilizing', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBBC', 'Petrifying', charge6, false), tier6);	
		
		// Chaos
		if material = 'Iron' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Elven' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material='Nordic' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 20;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Ebony' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Stalhrim' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 36;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end;	
		
		enchType := 'Chaos';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0402C46F', 'Chaos', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0402C470', 'High Chaos', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0402C471', 'Extreme Chaos', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0402C472', 'Ultimate Chaos', charge6, false), tier6);
		
		if material = 'Iron' then
		begin
			tier1 := 1;
			tier2 := 4;
			tier3 := 6;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Imperial' then
		begin
			tier1 := 4;
			tier2 := 6;
			tier3 := 8;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Steel' then
		begin
			tier1 := 4;
			tier2 := 6;
			tier3 := 8;
			tier4 := 0;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Dwarven' then
		begin
			tier1 := 0;
			tier2 := 13;
			tier3 := 15;
			tier4 := 17;
			tier5 := 0;
			tier6 := 0;
		end
		else if material = 'Orcish' then
		begin
			tier1 := 0;
			tier2 := 7;
			tier3 := 9;
			tier4 := 11;
			tier5 := 0;
			tier6 := 0;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 20;
			tier4 := 22;
			tier5 := 25;
			tier6 := 0;
		end
		else if material = 'Glass' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 28;
			tier4 := 31;
			tier5 := 34;
			tier6 := 0;
		end
		else if (material = 'Stalhrim') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 36;
			tier5 := 40;
			tier6 := 43;
		end
		else if (material = 'Ebony') then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 37;
			tier5 := 40;
			tier6 := 43;
		end
		else if material = 'Daedric' then
		begin
			tier1 := 0;
			tier2 := 0;
			tier3 := 0;
			tier4 := 47;
			tier5 := 50;
			tier6 := 53;
		end;

		if (waccf = true) then
		begin
			if material = 'Elven' then
			begin
				tier1 := 0;
				tier2 := 13;
				tier3 := 15;
				tier4 := 17;
				tier5 := 0;
				tier6 := 0;
			end
			else if material = 'Dwarven' then
			begin
				tier1 := 0;
				tier2 := 7;
				tier3 := 9;
				tier4 := 11;
				tier5 := 0;
				tier6 := 0;
			end
			else if (material = 'Orcish') then
			begin
				tier1 := 0;
				tier2 := 0;
				tier3 := 20;
				tier4 := 22;
				tier5 := 25;
				tier6 := 0;
			end;
		end;
		
		// Fear
		enchType := 'Fear';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000FBFF7', 'Dismay', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B466', 'Cowardice', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B467', 'Fear', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B468', 'Despair', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B469', 'Dread', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B46A', 'Terror', charge6, false), tier6);
		
		// Fire
		enchType := 'Fire';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00049BB7', 'Embers', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C2A', 'Burning', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C2C', 'Scorching', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C2D', 'Flames', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C30', 'the Blaze', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C35', 'the Inferno', charge6, false), tier6);
		
		// Frost
		enchType := 'Frost';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C36', 'Chills', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C37', 'Frost', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C39', 'Ice', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045D4B', 'Freezing', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045D56', 'Blizzards', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045D58', 'Winter', charge6, false), tier6);
		
		// Magicka Damage
		enchType := 'Magica';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B453', 'Sapping', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B454', 'Draining', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B455', 'Diminishing', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B456', 'Depleting', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B457', 'Enervating', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B458', 'Nullifying', charge6, false), tier6);	
		
		// Shock		
		enchType := 'Shock';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045D59', 'Sparks', charge1, false), tier1); 
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045D97', 'Arcing', charge2, false), tier2); 
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045F6F', 'Shocks', charge3, false), tier3); 
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045F89', 'Thunderbolts', charge4, false), tier4); 
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045F8D', 'Lightning', charge5, false), tier5); 
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045F9E', 'Storms', charge6, false), tier6);
		
		// Soul Trap
		enchType := 'SoulTrap';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45F', 'Souls', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B460', 'Soul Snares', charge2, false), tier2); 
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B461', 'Binding', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B462', 'Animus', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B463', 'Malediction', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B464', 'Damnation', charge6, false), tier6);
		
		// Stamina Damage
		enchType := 'Stamina';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B459', 'Fatigue', charge1, false), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45A', 'Weariness', charge2, false), tier2);
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45B', 'Torpor', charge3, false), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45C', 'Debilitation', charge4, false), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45D', 'Lethargy', charge5, false), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45E', 'Exhaustion', charge6, false), tier6);
		
		// Turn Undead
		enchType := 'Turn';
		if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
		begin
			sublist := createList('SublistEnch' + material + weaponType + enchType);
			processSublist(sublist, enchType, material, weaponType);
		end;
		
		if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B46C', 'Blessed', charge1, true), tier1);
		if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B46D', 'Sanctified', charge2, true), tier2); 
		if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B46E', 'Reverent', charge3, true), tier3);
		if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B46F', 'Hallowed', charge4, true), tier4);
		if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B470', 'Virtuous', charge5, true), tier5);
		if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000BF3F5', 'Holy', charge6, true), tier6);			
		
	end;

	// Create LItem list structure and add to vanilla lists
	createLItemLists(material, weaponType);
	
	Result := 0;

end;

// runs in the end
function Finalize: integer;
var
i: integer;
begin
	for i := 0 to allWeaponTypes.Count-1 do
	begin
		addToVanillaLists(allWeaponTypes[i]);
	end;
	FinalizeUtils();
	AddMessage('---Ending Generator---');
	Result := 0;
end;

end.
