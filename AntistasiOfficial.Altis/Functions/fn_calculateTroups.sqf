params ["_threatEval", "_targetType", "_recommendedType", "_speed"];

//Retrieve current amount of available vehicles
_currentAvailableStatic = [];
_currentAvailableAir = [];
_currentAvailableLand = [];
_currentAvailableArmor = [];
// TODO you know what to do

_staticTags = ["MORTAR"];
_airTags = ["HELI", "JET"];
_landTags = ["AT_TEAM", "AA_TEAM", "CQC_TEAM", "SPOTTER", "CAR"];
_armorTags = ["ARMOR", "TANK"];

_compisition = [];
_targetsToEliminate = nil;
_recommendedSet = ["MORTAR", "AT_TEAM",  "AA_TEAM", "CQC_TEAM", "SPOTTER", "TANK", "ARMOR", "CAR", "HELI", "JET"];
if((_targetType select 0) == "SINGLETARGET") then 
{
	_targetsToEliminate = (_targetType select 1);
	if(_speed == "LOW") then {_recommendedSet = _recommendedSet - ["HELI", "JET"]};
	if(_speed == "NORMAL") then {_recommendedSet = _recommendedSet - ["MORTAR", "AT_TEAM", "AA_TEAM", "CQC_TEAM", "SPOTTER"]};
	if(_speed == "HIGH") then {_recommendedSet = ["HELI", "JET"]};
	
	if(_recommendedType in _recommendedSet) then 
	{
		if(_recommendedType in _staticTags) then 
		{
			_compisition pushBackUnique (_currentAvailableStatic select 0);
		};
		if(_recommendedType in _landTags) then 
		{
			_land 
		};
		if(_recommendedType in _armorTags) then
		{
			_armor = nil;
			if((_threatEval select 1) select 3 > 8) then 
			{
				_armor = {if(_x in vehTank) exitWith {_x};} forEach _currentAvailableArmor;
			}
			else
			{
				//TODO select based on the recommended tag
				_armor = selectRandom _currentAvailableArmor;
			};
			_composition pushBackUnique _armor;
		};
		if(_recommendedType in _airTags) then 
		{
			_jet = {if (_x in planes) exitWith {_x};} forEach _currentAvailableAir;
			_compisition pushBackUnique _jet;
		};
	};
}; 
if((_targetType select 0) == "GROUPTARGET") then {_targetsToEliminate = (_targetType select 1)};

