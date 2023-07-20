# PerkDescriptuinPatcher
Patches perk mods. Replaces text in the perk descriptions with new text. All keywords that are added to originTexts are replaced by the ones in newTexts. Add new ones if need to automatically patch perk mods. The first entry in originTexts are replaced by the first one in newTexts, and so on. Change:
	createNewFile = true;
	capitalize = true
to false if you want to edit the original file or don't want the words capitalized

# SkyrimGenerateEnchantedVersions
Generates enchanted versions of all weapons in various mods. Change the following to your liking:
	HeavyArmoryTweaks = false;
	AnimatedArmouryTweaks = false;
	SSMTweaks = true;
	waccf = true;
	hllr = false;
	summermyst = true;
	vanilla = true;
	summermyst_filename = 'Summermyst - Enchantments of Skyrim.esp';
If vanilla or summermyst, either or both, are set to true, the enchantments from those mods will be used when creating enchanted versions. This is a large script, and you'll have to add new weapons to it, if any special rules should be applied to them. You could try and just run the script and see if it works.

# SkyrimUtils & mteFunctions 
Used by other scipts, include them in the script folder. These scriptz are not created by me.

# dfFunctions 
Contains functions used by some of my scripts. You may have to add new weapons to these functions. The function isOneHanded for example checks wheter a weapon is one handed or not. The function getType returns a standardized type of the weapon based on the KWDA entry of the record. WeapTypeHalberd is replaced by Halberd, and so on.

# dfRenameWeapons
Renames weapons. Add more entries if needed. Example:
	if (pos('Quarterstaff', itemName) > 0) then 
	  begin
		if (createNewFile = true) then rec :=wbCopyElementToFile(e, aFile, false, true);
		if (createNewFile = false) then rec := e;

		seev(rec, 'FULL', StringReplace(itemName, 'Quarterstaff', 'Short Staff', [rfReplaceAll]));
	 end;
The above code means, if item name coontains Quarterstaff (case sensitive), replace Quarterstaff with Short Staff.

# dfWeaponBalancingScript
Sets weapon damage based on iron weapons. Reads material of weapons and sets damage to that of and Iron variant + the offset value. Later down the script are the speed/reach/etc values for each weapon type. Add new ones here and edit the values if you want.

# dfWeaponBalancingScriptWACCF 
WACCF version of the above script

# fixenchname 
Edits some of the enchanted versions item names. Iron sword of Sanctified is changed to Sanctified Iron sword, and so on.
