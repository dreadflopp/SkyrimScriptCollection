unit dfWeaponBalancingScript;

uses mteFunctions, dfFunctions; 

const
// Settings
  createNewFile = true;
  debug = true;

var
  aFile: IInterface;

function getDamageOffset(rec:IInterface): integer;
var 
  material: string;
  offset: integer;
begin
  material := getMainMaterialShort(rec);
  offset := 0;

    if material = 'Iron' then begin offset := 0; end
    else if material = 'Riekling' then begin offset := -1; end
    else if material = 'Steel' then begin offset := 1; end
    else if material = 'Silver' then begin offset := 1; end
    else if material = 'Draugr' then begin offset := 1; end
    else if material = 'Imperial' then begin offset := 2; end
    else if material = 'Orcish' then begin offset := 2; end
    else if material = 'DragonPriest' then begin offset := 2; end
    else if material = 'Dwarven' then begin offset := 3; end
    else if material = 'Falmer' then begin offset := 3; end
    else if material = 'Forsworn' then begin offset := 3; end
    else if material = 'Dawnguard' then begin offset := 3; end
    else if material = 'Nordhero' then begin offset := 4; end
    else if material = 'Skyforge' then begin offset := 4; end
    else if material = 'Elven' then begin offset := 4; end 
    else if material = 'Nordic' then begin offset := 4; end
    else if material = 'Blades' then begin offset := 4; end
    else if material = 'DraugrHoned' then begin offset := 4; end
    else if material = 'Redguard' then begin offset := 4; end
    else if material = 'Glass' then begin offset := 5; end
    else if material = 'FalmerHoned' then begin offset := 5; end
    else if material = 'Ebony' then begin offset := 6; end
    else if material = 'Stalhrim' then begin offset := 6; end
    else if material = 'Tempest' then begin offset := 6; end
    else if material = 'Daedric' then begin offset := 7; end
    else if material = 'Dragonbone' then begin offset := 8; end
    else begin AddMessage('Failed to set offset for weapon ' + geev(rec, 'EDID')); end;
  
  if isOneHanded(getType(rec)) = false then begin
    if not (material = 'Iron') then offset := (offset + 1);
    if ((material = 'Stalhrim') OR (material = 'Daedric') OR (material = 'Dragonbone')) then  offset := (offset + 1);
  end;

  if (getType(rec) = 'Whip') OR (getType(rec) = 'Claw') then
  begin
    if(pos(geev(rec, 'FULL'), 'Talons of Woe') > 0 ) then offset := 8;
    if(pos(geev(rec, 'FULL'), 'Dark Talons') > 0 ) then  offset := 5;
    if(pos(geev(rec, 'FULL'), 'Vampire Slayer') > 0 )  then offset := 3;
    if(pos(geev(rec, 'FULL'), 'Tempest') > 0 )  then offset := 8;
    if(pos(geev(rec, 'FULL'), 'Wildfire') > 0 )  then offset := 8;
    if(pos(geev(rec, 'FULL'), 'Borealis') > 0 )  then offset := 8;

  end;

  mess('GetDamageOffset for' + geev(rec, 'EDID') + ' : ' + IntToStr(offset));
  Result := offset;

end;

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

    // we retrieve entire record name here, this is how it appears in game. And do checks depending on it further in the script. 
    itemName := geev(e, 'FULL');

    mess('Process started for ' + itemName);

    if (pos('Bound', itemName) > 0) then Exit;

    if (createNewFile = true) then rec := wbCopyElementToFile(e, aFile, false, true);
    if (createNewFile = false) then rec := e;

    // pos() is a function which allows us to know if name contains specific word, namely, position of word in phrase. Returns 0 if there isn't one.
    // DNAM\* expressions is the path in xEdit to specifc field value. For example to adjust damage we would write 'DATA\Damage' as it's in DATA block, under Damage row.
    
    // changes swords
    mess('...is sword?');
    if (pos('Sword', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.0');
      seev(rec, 'DNAM\Reach', '1.0');
      seev(rec, 'DNAM\Stagger', '0.75');
      seevi(rec, 'DATA\Damage', 7 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;
    if (pos('Katana', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.05');
      seev(rec, 'DNAM\Reach', '1.0');
      seev(rec, 'DNAM\Stagger', '0.7');
      seevi(rec, 'DATA\Damage', 7 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

     mess('...is shortsword?');
    // changes Shortswords
    if (pos('Shortsword', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.1');
      seev(rec, 'DNAM\Reach', '0.85');
      seev(rec, 'DNAM\Stagger', '0.6');
      seevi(rec, 'DATA\Damage', 6 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;
    if (pos('Wakizashi', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.15');
      seev(rec, 'DNAM\Reach', '0.85');
      seev(rec, 'DNAM\Stagger', '0.5');
      seevi(rec, 'DATA\Damage', 6 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

     // changes Rapiers
      mess('...is rapier?');
    if (pos('Rapier', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.05');
      seev(rec, 'DNAM\Reach', '1.10');
      seev(rec, 'DNAM\Stagger', '0.2');
      seevi(rec, 'DATA\Damage', 5 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', 10 + (GetDamageOffset(rec) div 2));
    end;

    // changes War Axes
     mess('...is war axe?');
    if (pos('War Axe', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.9');
      seev(rec, 'DNAM\Reach', '1.0');
      seev(rec, 'DNAM\Stagger', '0.85');
      seevi(rec, 'DATA\Damage', 8 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes Hatchets
    mess('...is hatchet?');
    if (pos('Hatchet', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.1');
      seev(rec, 'DNAM\Reach', '0.8');
      seev(rec, 'DNAM\Stagger', '0.7');
      seevi(rec, 'DATA\Damage', 7 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes Maces
    mess('...is mace?');
    if ((pos('Mace', itemName) > 0) AND (pos('Long Mace', itemName) = 0)) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.8');
      seev(rec, 'DNAM\Reach', '1.0');
      seev(rec, 'DNAM\Stagger', '1.0');
      seevi(rec, 'DATA\Damage', 9 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes Mauls
    mess('...is maul?');
    if (pos('Maul', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.75');
      seev(rec, 'DNAM\Reach', '1.0');
      seev(rec, 'DNAM\Stagger', '1.1');
      seevi(rec, 'DATA\Damage', 10 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes clubs
    mess('...is club?');
    if (pos('Club', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.0');
      seev(rec, 'DNAM\Reach', '1.0');
      seev(rec, 'DNAM\Stagger', '0.9');
      seevi(rec, 'DATA\Damage', 7 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes daggers
    mess('...is dagger?');
    if (pos('Dagger', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.3');
      seev(rec, 'DNAM\Reach', '0.7');
      seev(rec, 'DNAM\Stagger', '0.0');
      seevi(rec, 'DATA\Damage', 4 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;
    if (pos('Tanto', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.3');
      seev(rec, 'DNAM\Reach', '0.7');
      seev(rec, 'DNAM\Stagger', '0.0');
      seevi(rec, 'DATA\Damage', 4 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes claws
    mess('...is claw?');
    if (pos('Claw', itemName) > 0) OR (pos('Talon', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.3');
      seev(rec, 'DNAM\Reach', '1.0');
      seev(rec, 'DNAM\Stagger', '0.0');
      seevi(rec, 'DATA\Damage', 5 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', 1 + (GetDamageOffset(rec) div 2));
    end;

    // changes greatswords
    mess('...is greatsword?');
    if (pos('Greatsword', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.75');
      seev(rec, 'DNAM\Reach', '1.3');
      seev(rec, 'DNAM\Stagger', '1.1');
      seevi(rec, 'DATA\Damage', 15 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;
    if (pos('Dai-Katana', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.75');
      seev(rec, 'DNAM\Reach', '1.3');
      seev(rec, 'DNAM\Stagger', '1.1');
      seevi(rec, 'DATA\Damage', 15 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
      end;

    // changes half pikes
    mess('...is half pike?');
    if (pos('Half Pike', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.8');
      seev(rec, 'DNAM\Reach', '1.4');
      seev(rec, 'DNAM\Stagger', '0.3');
      seevi(rec, 'DATA\Damage', 13 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage',  9 + (GetDamageOffset(rec) div 2));
    end;

    // changes glaives
    mess('...is glaive?');
    if (pos('Glaive', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.75');
      seev(rec, 'DNAM\Reach', '1.45');
      seev(rec, 'DNAM\Stagger', '0.65');
      seevi(rec, 'DATA\Damage', 13 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;
    
      // changes Tridents
      mess('...is trident?');
    if (pos('Trident', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.75');
      seev(rec, 'DNAM\Reach', '1.4');
      seev(rec, 'DNAM\Stagger', '0.5');
      seevi(rec, 'DATA\Damage', 14 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage',  10 + (GetDamageOffset(rec) div 2));
    end;

    // changes Pikes
    mess('...is pike?');
    if (pos('Pike', itemName) > 0) AND (pos('Half Pike', itemName) = 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.7');
      seev(rec, 'DNAM\Reach', '1.65');
      seev(rec, 'DNAM\Stagger', '0.4');
      seevi(rec, 'DATA\Damage', 12 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', 9 + (GetDamageOffset(rec) div 2));
    end;

     // changes battleaxes
     mess('...is battleaxe?');
    if (pos('Battleaxe', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.7');
      seev(rec, 'DNAM\Reach', '1.3');
      seev(rec, 'DNAM\Stagger', '1.15');
      seevi(rec, 'DATA\Damage', 16 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes Poleaxes, renamed Halberds from HeavyArmory mod
    mess('...is poleaxe?');
    if (pos('Poleaxe', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.7');
      seev(rec, 'DNAM\Reach', '1.4');
      seev(rec, 'DNAM\Stagger', '1.05');
      seevi(rec, 'DATA\Damage', 15 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes Halberds
    mess('...is halberd?');
    if (pos('Halberd', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.65');
      seev(rec, 'DNAM\Reach', '1.55');
      seev(rec, 'DNAM\Stagger', '0.9');
      seevi(rec, 'DATA\Damage', 14 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes Warhammers
    mess('...is warhammer?');
    if (pos('Warhammer', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.6');
      seev(rec, 'DNAM\Reach', '1.3');
      seev(rec, 'DNAM\Stagger', '1.25');
      seevi(rec, 'DATA\Damage', 18 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes Long Maces
    mess('...is long mace?');
    if (pos('Long Mace', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.65');
      seev(rec, 'DNAM\Reach', '1.3');
      seev(rec, 'DNAM\Stagger', '1.2');
      seevi(rec, 'DATA\Damage', 17 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes Short Staffs
    mess('...is short staff?');
    if (pos('Short Staff', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.0');
      seev(rec, 'DNAM\Reach', '1.0');
      seev(rec, 'DNAM\Stagger', '1.0');
      seevi(rec, 'DATA\Damage', 12 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes Quartertaffs
    mess('...is quarterstaff?');
    if (pos('Quarterstaff', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.0');
      seev(rec, 'DNAM\Reach', '1.2');
      seev(rec, 'DNAM\Stagger', '1.0');
      seevi(rec, 'DATA\Damage', 11 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

    // changes one handed Shortspears
    mess('...is shortspear?');
    if (pos('Shortspear', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.0');
      seev(rec, 'DNAM\Reach', '1.2');
      seev(rec, 'DNAM\Stagger', '0.2');
      seevi(rec, 'DATA\Damage', 7 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

     // changes one handed Spear
     mess('...is spear?');
    if (pos('Spear', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.1');
      seev(rec, 'DNAM\Reach', '1.3');
      seev(rec, 'DNAM\Stagger', '0.3');
      seevi(rec, 'DATA\Damage', 6 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', geevi(rec,'DATA\Damage') div 2);
    end;

     // changes whips
     mess('...is whip?');
    if (pos('Whip', itemName) > 0) OR (pos('Whip', geev(e, 'EDID')) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '0.9');
      seev(rec, 'DNAM\Reach', '2.0');
      seev(rec, 'DNAM\Stagger', '0.4');
      seevi(rec, 'DATA\Damage', 7 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', 1 + (GetDamageOffset(rec) div 2));
    end;       

     // changes javelins
     mess('...is javelin?');
    if (pos('Javelin', itemName) > 0) then begin
      mess('changing' + itemName);
      seev(rec, 'DNAM\Speed', '1.2');
      seev(rec, 'DNAM\Reach', '1.0');
      seev(rec, 'DNAM\Stagger', '0.3');
      seevi(rec, 'DATA\Damage', 4 + GetDamageOffset(rec));
      seevi(rec, 'CRDT\Damage', GetDamageOffset(rec) div 3);
      if(geevi(rec, 'CRDT\Damage') = 0) then seevi(rec, 'CRDT\Damage', '1');
    end;     

    // adjusts stagger for Stalhrim weapons, in vanilla Stalhrim has 'hidden' bonus of higher stagger value.
    if (pos('Stalhrim Short Staff', itemName) > 0) then seev(rec, 'DNAM\Stagger', '1.1');
    if (pos('Stalhrim Half Pike', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.35');
    if (pos('Stalhrim Shortsword', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.65');
    if (pos('Stalhrim Hatchet', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.75');
    if (pos('Stalhrim Maul', itemName) > 0) then seev(rec, 'DNAM\Stagger', '1.2');
    if (pos('Stalhrim Poleaxe', itemName) > 0) then seev(rec, 'DNAM\Stagger', '1.15');
    if (pos('Stalhrim Shortspear', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.25');
    if (pos('Stalhrim Trident', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.55');
    if (pos('Stalhrim Rapier', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.25');
    if (pos('Stalhrim Pike', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.45');
    if (pos('Stalhrim Halberd', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.95');
    if (pos('Stalhrim Quarterstaff', itemName) > 0) then seev(rec, 'DNAM\Stagger', '1.1');
    if (pos('Stalhrim Claws', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.05');if (pos('Stalhrim Whip', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.45');    
     if (pos('Stalhrim Spear', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.05');if (pos('Stalhrim Whip', itemName) > 0) then seev(rec, 'DNAM\Stagger', '0.35');  
  end;

procedure mess(s: string);
begin
    if debug = true then AddMessage(s);
end;

end.
