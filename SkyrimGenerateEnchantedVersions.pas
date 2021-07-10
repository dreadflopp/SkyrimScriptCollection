{
	Script generates 31 enchanted copies of selected weapons per each, adds enchantment, alters new records value, and adds respected Suffixes for easy parsing and replace.
	For armors script will make only one enchanted copy per each, for now.
	
	All enchanted versions will have it's proper Temper COBJ records as well.
	Also, for each selected WEAP/ARMO record, will be created a Leveled List, with Base item + all it's enchanted versions. Each with count of 1, and based on enchantment level requirement
	NOTE: Should be applied on records inside WEAPON/ARMOR (WEAP/ARMO) category of plugin you want to edit (script will not create new plugin)
	NOTE: So script works with Weapons/Shields/Bags/Bandanas/Armor/Clothing/Amulets/Wigs... every thing, but script won't find right item requirements for tempering wig or amulet... probably... However it will make a recipe, and it will log a message with link on that recipe, in this case, you can simply delete Tempering record or edit it... that is your Skyrim after all :O)
}

unit GenerateEnchantedVersions;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows, SkyrimUtils, mtefunctions;

// =Settings
const
// should generator add MagicDisallowEnchanting keyword to the enchanted versions? (boolean)
setMagicDisallowEnchanting = false;
// on how much the enchanted versions value should be multiplied (integer or real (aka float))
enchantedValueMultiplier = 1;
// Heavy Armory Tweaks
HeavyArmoryTweaks = false;
// Animated Armoury Tweaks
AnimatedArmouryTweaks = true;
// Skyrim Spear Mechanic tweaks
SSMTweaks = false;
// waccf
waccf = false;
// hllr
hllr = false;

var
pluginGenerated, pluginSelected, keywordQS: IInterface;
allWeaponTypes: TStringList;

function getMainMaterialShort(itemRecord: IInterface): IInterface;
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
		warn('no material keywords were found for - ' + Name(itemRecord));
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

// creates an enchanted copy of the weapon record and returns it
function createEnchantedVersion(baseRecord: IInterface; objEffect: string; suffix: string; enchantmentAmount: integer): IInterface;
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
	
	// set it's value, cause enchantments are more expensive
		// Vanilla formula [Total Value] = [Base Item Value] + 0.12*[Charge] + [Enchantment Value]
		// credits: http://www.uesp.net/wiki/Skyrim_talk:Generic_Magic_Weapons
	// don't know how to make [Enchantment Value] without hardcoding every thing, so made it just for similar results, suggestions are welcome :O)
	{
	SetElementEditValues(
	enchRecord,
	'DATA\Value',
	round(
	getPrice(baseRecord)
	+ (0.12 * enchantmentAmount)
	+ (1.4 * (enchantmentAmount / GetElementEditValues(enchantment, 'ENIT\Enchantment Cost')))  // 1.4 * <number of uses>
	* enchantedValueMultiplier
	)
	}
	
	// suffix the FULL, for easy finding and manual editing
	if ((objEffect = '0005B46C') OR (objEffect = '0005B46D') OR (objEffect = '0005B46E') OR (objEffect = '0005B46F') OR (objEffect = '0005B470') OR (objEffect = '000BF3F5')) then
		SetElementEditValues(enchRecord, 'FULL', suffix + ' ' + GetElementEditValues(baseRecord, 'FULL'));		
	SetElementEditValues(enchRecord, 'FULL', GetElementEditValues(baseRecord, 'FULL') + ' of ' + suffix);
	
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
	if (enchType = 'Fire') AND not (weaponType = 'Dagger') AND not (weaponType = 'Claw') then
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
	
	//AddMessage('... finished processing sublist: ' + 'SublistEnch' + material + weaponType + enchType);
end;

procedure createLItemLists(
material: string; 
weaponType: string;
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
		normalLnormalListMidist := createList('LItemEnchWeapon' + weaponType + 'Mid');
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
			normalListLowMid(dlc2BestList, LItemEnchMaterialWeapon, 1);			
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
				normalListLowMid(dlc2BestList, LItemEnchMaterialWeapon, 2);			
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
				normalListLowMid(dlc2BestList, LItemEnchMaterialWeapon, 1);			
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
			normalListLowMid(dlc2BestList, LItemEnchMaterialWeapon, 1);			
			normalListMid(dlc2BestList, LItemEnchMaterialWeapon, 1);		
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
			normalListLowMid(dlc2BestList, LItemEnchMaterialWeapon, 1);			
			normalListMid(dlc2BestList, LItemEnchMaterialWeapon, 1);		
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
			normalListLowMid(dlc2BestList, LItemEnchMaterialWeapon, 1);			
			normalListMid(dlc2BestList, LItemEnchMaterialWeapon, 1);		
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
	if not ((recordSignature = 'WEAP') or (recordSignature = 'ARMO')) then
	Exit;
	
	// Create plugin if needed
	if not Assigned(pluginGenerated) then begin
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
	if recordSignature = 'WEAP' then begin
	
	weaponType := getType(selectedRecord);
	
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
	
	// bali if ssm and
	if SSMTweaks = true then
	begin
		if (weaponType = 'Javelin') then
		Exit;
		
		if (Pos('Dummy', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
		
		if (Pos('Elder', GetElementEditValues(selectedRecord, 'EDID')) > 0) then
		Exit;
	end;
	
	material := getMainMaterialShort(selectedRecord);
	if (material = 'Blades') OR (material = 'Draugr') OR (material = 'DraugrHoned') OR (material = 'Dawnguard') OR (material = 'Falmer') OR (material = 'FalmerHoned') OR (material = 'Forsworn') OR (material = 'Redguard') OR (material = 'Silver') OR (material = 'Skyforge') OR (material = 'Imperial') OR (material = 'Dragonbone') OR (material = 'Skip_ench') then
	Exit;	
	
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
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Imperial' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Steel' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Dwarven' then
	begin
		tier1 := 0;
		tier2 := 13;
		tier3 := 15;
		tier4 := 17;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 1000;
		charge3 := 1500;
		charge4 := 2000;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Orcish' then
	begin
		tier1 := 0;
		tier2 := 7;
		tier3 := 9;
		tier4 := 11;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 1000;
		charge3 := 1500;
		charge4 := 2000;
		charge5 := 0;
		charge6 := 0;
	end
	else if (material = 'Elven') OR (material='Nordic') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 20;
		tier4 := 22;
		tier5 := 25;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 1500;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 0;
	end
	else if material = 'Glass' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 28;
		tier4 := 31;
		tier5 := 34;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 1500;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 0;
	end
	else if (material = 'Stalhrim') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 36;
		tier5 := 40;
		tier6 := 43;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 3000;
	end
	else if (material = 'Ebony') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 37;
		tier5 := 40;
		tier6 := 43;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 3000;
	end
	else if material = 'Daedric' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 47;
		tier5 := 50;
		tier6 := 53;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 3000;
	end
	else if (material = 'Draugr') OR (material = 'DraugrHoned')then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if (material = 'Falmer') OR (material = 'FalmerHoned') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Dragonbone' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end;
	
	enchType := 'AbsorbH';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA145', 'Absorption', charge2), tier2);
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15A', 'Consuming', charge3), tier3);
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15B', 'Devouring', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15C', 'Leeching', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15D', 'the Vampire', charge6), tier6);
	
	
	// Absorb Magica
	enchType := 'AbsorbM';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA158', 'Siphoning', charge2), tier2);
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15E', 'Harrowing', charge3), tier3);
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA15F', 'Winnowing', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA160', 'Evoking', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA161', 'the Sorcerer', charge6), tier6);
	
	// Absorb Stamina
	enchType := 'AbsorbS';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA159', 'Gleaning', charge2), tier2);
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA162', 'Reaping', charge3), tier3);
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA163', 'Harvesting', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA164', 'Garnering', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000AA165', 'Subsuming', charge6), tier6);
	
	// Banish
	if material = 'Iron' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Imperial' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Steel' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Dwarven' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Orcish' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if (material = 'Elven') OR (material='Nordic') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 22;
		tier5 := 25;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 0;
	end
	else if material = 'Glass' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 31;
		tier5 := 34;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 0;
	end
	else if (material = 'Stalhrim') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 36;
		tier5 := 40;
		tier6 := 43;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 3000;
	end
	else if (material = 'Ebony') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 37;
		tier5 := 40;
		tier6 := 43;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 3000;
	end
	else if material = 'Daedric' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 47;
		tier5 := 50;
		tier6 := 53;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 3000;
	end
	else if (material = 'Draugr') OR (material = 'DraugrHoned')then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if (material = 'Falmer') OR (material = 'FalmerHoned') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Dragonbone' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end;
	
	// Banish
	enchType := 'Banish';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBB7', 'Banishing', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBB8', 'Expelling', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBB9', 'Annihilating', charge6), tier6);
	
	// Paralyze
	enchType := 'Paralyze';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBBA', 'Stunning', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBBB', 'Immobilizing', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000ACBBC', 'Petrifying', charge6), tier6);	
	
	// Chaos
	if material = 'Iron' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Imperial' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Steel' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Dwarven' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Orcish' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Elven' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material='Nordic' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 20;
		tier4 := 22;
		tier5 := 25;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 1500;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 0;
	end
	else if material = 'Glass' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Ebony' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Stalhrim' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 36;
		tier5 := 40;
		tier6 := 43;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 3000;
	end
	else if material = 'Daedric' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if (material = 'Draugr') OR (material = 'DraugrHoned')then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if (material = 'Falmer') OR (material = 'FalmerHoned') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Dragonbone' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end;
	
	enchType := 'Chaos';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0402C46F', 'Chaos', charge3), tier3);
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0402C470', 'High Chaos', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0402C471', 'High Chaos', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0402C472', 'Ultimate Chaos', charge6), tier6);
	
	if material = 'Iron' then
	begin
		tier1 := 1;
		tier2 := 4;
		tier3 := 6;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 500;
		charge2 := 1000;
		charge3 := 1500;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Imperial' then
	begin
		tier1 := 4;
		tier2 := 6;
		tier3 := 8;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 200;
		charge2 := 300;
		charge3 := 400;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Steel' then
	begin
		tier1 := 4;
		tier2 := 6;
		tier3 := 8;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 500;
		charge2 := 1000;
		charge3 := 15000;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Dwarven' then
	begin
		tier1 := 0;
		tier2 := 13;
		tier3 := 15;
		tier4 := 17;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 1000;
		charge3 := 1500;
		charge4 := 2000;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Orcish' then
	begin
		tier1 := 0;
		tier2 := 7;
		tier3 := 9;
		tier4 := 11;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 1000;
		charge3 := 1500;
		charge4 := 2000;
		charge5 := 0;
		charge6 := 0;
	end
	else if (material = 'Elven') OR (material='Nordic') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 20;
		tier4 := 22;
		tier5 := 25;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 1500;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 0;
	end
	else if material = 'Glass' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 28;
		tier4 := 31;
		tier5 := 34;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 1500;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 0;
	end
	else if (material = 'Stalhrim') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 36;
		tier5 := 40;
		tier6 := 43;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 3000;
	end
	else if (material = 'Ebony') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 37;
		tier5 := 40;
		tier6 := 43;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 3000;
	end
	else if material = 'Daedric' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 47;
		tier5 := 50;
		tier6 := 53;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 3000;
	end
	else if (material = 'Draugr') OR (material = 'DraugrHoned')then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 20;
		tier4 := 22;
		tier5 := 25;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 1500;
		charge4 := 2000;
		charge5 := 2500;
		charge6 := 0;
	end
	else if (material = 'Falmer') OR (material = 'FalmerHoned') then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end
	else if material = 'Dragonbone' then
	begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
	end;
	
	// Fear
	enchType := 'Fear';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000FBFF7', 'Dismay', charge1), tier1);
	if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B466', 'Cowardice', charge2), tier2);
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B467', 'Fear', charge3), tier3);
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B468', 'Despair', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B469', 'Dread', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B46A', 'Terror', charge6), tier6);
	
	// Fire
	enchType := 'Fire';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00049BB7', 'Embers', charge1), tier1);
	if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C2A', 'Burning', charge2), tier2);
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C2C', 'Scorching', charge3), tier3);
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C2D', 'Flames', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C30', 'the Blaze', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C35', 'the Inferno', charge6), tier6);
	
	// Frost
	enchType := 'Frost';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C36', 'Chills', charge1), tier1);
	if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C37', 'Frost', charge2), tier2);
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045C39', 'Ice', charge3), tier3);
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045D4B', 'Freezing', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045D56', 'Blizzards', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045D58', 'Winter', charge6), tier6);
	
	// Magicka Damage
	enchType := 'Magica';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B453', 'Sapping', charge1), tier1);
	if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B454', 'Draining', charge2), tier2);
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B455', 'Diminishing', charge3), tier3);
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B456', 'Depleting', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B457', 'Enervating', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B458', 'Nullifying', charge6), tier6);	
	
	// Shock		
	enchType := 'Shock';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	
	if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045D59', 'Sparks', charge1), tier1); 
	if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045D97', 'Arcing', charge2), tier2); 
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045F6F', 'Shocks', charge3), tier3); 
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045F89', 'Thunderbolts', charge4), tier4); 
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045F8D', 'Lightning', charge5), tier5); 
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '00045F9E', 'Storms', charge6), tier6);
	
	// Soul Trap
	enchType := 'SoulTrap';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45F', 'Souls', charge1), tier1);
	if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B460', 'Soul Snares', charge2), tier2); 
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B461', 'Binding', charge3), tier3);
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B462', 'Animus', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B463', 'Malediction', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B464', 'Damnation', charge6), tier6);
	
	// Stamina Damage
	enchType := 'Stamina';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B459', 'Fatigue', charge1), tier1);
	if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45A', 'Weariness', charge2), tier2);
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45B', 'Torpor', charge3), tier3);
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45C', 'Debilitation', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45D', 'Lethargy', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B45E', 'Exhaustion', charge6), tier6);
	
	// Turn Undead
	enchType := 'Turn';
	if (tier1 > 0) OR (tier2 > 0) OR (tier3 > 0) OR (tier4 > 0) OR (tier5 > 0) OR (tier6 > 0) then
	begin
		sublist := createList('SublistEnch' + material + weaponType + enchType);
		processSublist(sublist, enchType, material, weaponType);
	end;
	
	if tier1 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B46C', 'Blessed', charge1), tier1);
	if tier2 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B46D', 'Sanctified', charge2), tier2); 
	if tier3 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B46E', 'Reverent', charge3), tier3);
	if tier4 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B46F', 'Hallowed', charge4), tier4);
	if tier5 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '0005B470', 'Virtuous', charge5), tier5);
	if tier6 > 0 then addToLeveledList(sublist, createEnchantedVersion(selectedRecord, '000BF3F5', 'Holy', charge6), tier6);
	
	// Create LItem list structure and add to vanilla lists
	createLItemLists(material, weaponType);
	
	{
		if material = 'Iron' then
		begin
		tier1 := ;
		tier2 := ;
		tier3 := ;
		tier4 =;
		tier5 := ;
		tier6 := ;
		charge1 := ;
		charge2 := ;
		charge3 := ;
		charge4 := ;
		charge5 := ;
		charge6 := ;
		end
		else if material = 'Imperial' then
		begin
		tier1 := ;
		tier2 := ;
		tier3 := ;
		tier4 =;
		tier5 := ;
		tier6 := ;
		charge1 := ;
		charge2 := ;
		charge3 := ;
		charge4 := ;
		charge5 := ;
		charge6 := ;
		end
		else if material = 'Steel' then
		begin
		tier1 := ;
		tier2 := ;
		tier3 := ;
		tier4 =;
		tier5 := ;
		tier6 := ;
		charge1 := ;
		charge2 := ;
		charge3 := ;
		charge4 := ;
		charge5 := ;
		charge6 := ;
		end
		else if material = 'Dwarven' then
		begin
		tier1 := ;
		tier2 := ;
		tier3 := ;
		tier4 =;
		tier5 := ;
		tier6 := ;
		charge1 := ;
		charge2 := ;
		charge3 := ;
		charge4 := ;
		charge5 := ;
		charge6 := ;
		end
		else if material = 'Orcish' then
		begin
		tier1 := ;
		tier2 := ;
		tier3 := ;
		tier4 =;
		tier5 := ;
		tier6 := ;
		charge1 := ;
		charge2 := ;
		charge3 := ;
		charge4 := ;
		charge5 := ;
		charge6 := ;
		end
		else if (material = 'Elven') OR (material='Nordic') then
		begin
		tier1 := ;
		tier2 := ;
		tier3 := ;
		tier4 =;
		tier5 := ;
		tier6 := ;
		charge1 := ;
		charge2 := ;
		charge3 := ;
		charge4 := ;
		charge5 := ;
		charge6 := ;
		end
		else if material = 'Glass' then
		begin
		tier1 := ;
		tier2 := ;
		tier3 := ;
		tier4 =;
		tier5 := ;
		tier6 := ;
		charge1 := ;
		charge2 := ;
		charge3 := ;
		charge4 := ;
		charge5 := ;
		charge6 := ;
		end
		else if (material = 'Ebony') OR (material = 'Stalhrim') then
		begin
		tier1 := ;
		tier2 := ;
		tier3 := ;
		tier4 =;
		tier5 := ;
		tier6 := ;
		charge1 := ;
		charge2 := ;
		charge3 := ;
		charge4 := ;
		charge5 := ;
		charge6 := ;
		end
		else if material = 'Daedric' then
		begin
		tier1 := ;
		tier2 := ;
		tier3 := ;
		tier4 =;
		tier5 := ;
		tier6 := ;
		charge1 := ;
		charge2 := ;
		charge3 := ;
		charge4 := ;
		charge5 := ;
		charge6 := ;
		end
		else if (material = 'Draugr') OR (material = 'DraugrHoned')then
		begin
		tier1 := 0;
		tier2 := 0;
		tier3 := 0;
		tier4 := 0;
		tier5 := 0;
		tier6 := 0;
		charge1 := 0;
		charge2 := 0;
		charge3 := 0;
		charge4 := 0;
		charge5 := 0;
		charge6 := 0;
		end
		else if (material = 'Falmer') OR (material = 'FalmerHoned') then
		begin
		tier1 := ;
		tier2 := ;
		tier3 := ;
		tier4 =;
		tier5 := ;
		tier6 := ;
		charge1 := ;
		charge2 := ;
		charge3 := ;
		charge4 := ;
		charge5 := ;
		charge6 := ;
		end
		else if material = 'Dragonbone' then
		begin
		tier1 := ;
		tier2 := ;
		tier3 := ;
		tier4 =;
		tier5 := ;
		tier6 := ;
		charge1 := ;
		charge2 := ;
		charge3 := ;
		charge4 := ;
		charge5 := ;
		charge6 := ;
		end
	}
	
	end else if recordSignature = 'ARMO' then begin
	SetElementEditValues(enchLevelList, 'EDID', 'LItemArmorEnch' + GetElementEditValues(selectedRecord, 'EDID'));
	
	// Fire Resistence Effects
	addToLeveledList(
	enchLevelList,
	createEnchantedVersion(
	selectedRecord, // baseRecord,
	'0004950B', // EnchArmorResistFire01
	'Fire01', // suffix
	800 // enchantmentAmount
	),
	1 // required level
	);
	
	// =Adding enchantments for ARMO records
	
	end;
	
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
