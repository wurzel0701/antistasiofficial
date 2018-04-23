params ["_marker", "_target",["_type", ""]];

_isMarker = !(typeName _marker == "ARRAY");
_markerPos = _marker;
if (typeName _marker == "STRING") then {_markerPos = getMarkerPos (_marker)};

_threatLevelInfa = 0;
_threatLevelAA = 0;
_threatLevelAT = 0;
_threatLevelAir = 0;
_threatLevelGround = 0;
_detectedAIRVehicles = [];
_detectedARMOREDVehicles = [];
_detectedCARVehicles = [];

//vehicleClass[] = {Men, Car, Armored, Air, Support, Camera, Objects, Ammo, Sounds, Mines};

//Calculate the current threat of the given situation by enemy forces
{
	if(!(_x isKindOf "Men")) then 
	{
		//Vehicle active
		if(_x isKindOf "Air") then 
		{
			if(_x in heli_unarmed) then {_threatLevelAir += 1};
			if(_x in heli_armed) then {_threatLevelAir += 5; _threatLevelAT += 5};
			if(_x in planes) then {_threatLevelAir += 10; _threatLevelAA += 5; _threatLevelAT += 3;};
			if(_x in planesNATO) then {_threatLevelAir += 5; _threatLevelAA += 2; _threatLevelAT += 2;};
			_detectedAIRVehicles pushbackUnique _x;
		};
		if(_x isKindOf "Armored") then
		{
			if(_x in vehAPC) then {_threatLevelGround += 5; _threatLevelAA +=2; _threatLevelAT +=5;}; //Gorgon transport
			if(_x in vehIFV) then {_threatLevelGround += 6; _threatLevelAT += 6;}; //Mora tank
			if(_x in vehTank) then {_threatLevelGround += 10; _threatLevelAT += 10;}; //Kuma tank
			if(_x in vehNATO) then {_threatLevelGround += 5; _threatLevelAT += 2; _threatLevelAA += 2;};
			_detectedARMOREDVehicles pushbackUnique _x;
		};
		if(_x isKindOf "Car") then
		{
			if(_x in vehPatrol) then {_threatLevelGround += 2}; //Stryder or something
			_detectedCARVehicles pushbackUnique _x;
		};
	}
	else
	{
		if(isPlayer _x) then 
		{
			_threatLevelInfa += 3;
			_threatLevelGround += 2; 
		}
		else
		{
			_threatLevelInfa = _threatLevelInfa + 0.1 * (server getVariable [skillFIA, 1]);
			_threatLevelGround +=1;
		}
		if(secondaryWeapon _x in genAALaunchers) then {_threatLevelAA = _threatLevelAA + 2};
		if(secondaryWeapon _x in genATLaunchers) then {_threatLevelAT = _threatLevelAT + 2};
	};
} forEach ([800,0,_markerPos, "BLUFORSPAWN"] call distanceUnits)

//Decrease threat for every active AAF unit
{
	if(!(_x isKindOf "Men")) then 
	{
		//Vehicle active
		if(_x isKindOf "Air") then 
		{
			if(_x in heli_unarmed) then {_threatLevelAir -= 1;};
			if(_x in heli_armed) then {_threatLevelAir -= 4; _threatLevelGround -= 2;};
			if(_x in planes) then {_threatLevelAir -= 8; _threatLevelGround -= 3;};
		};
		if(_x isKindOf "Armored") then
		{
			if(_x in vehAPC) then {_threatLevelGround -= 4; _threatLevelAir -= 2;}; //Gorgon transport
			if(_x in vehIFV) then {_threatLevelGround -= 5;}; //Mora tank
			if(_x in vehTank) then {_threatLevelGround -= 8;}; //Kuma tank
		};
		if(_x isKindOf "Car") then
		{
			if(_x in vehPatrol) then {_threatLevelGround -= 1}; //Stryder or something
		};
	}
	else
	{
		_threatLevelInfa = _threatLevelInfa - 0.1 * (server getVariable [skillAAF, 1]);
		_threatLevelGround -= 0.5;
	};
} forEach ([500,0,_markerPos, "OPFORSPAWN"] call distanceUnits)

//Calculated the attacking force

//Checking the need of reinforcements
_threatRatioInfa = 0;
if((_threatLevelGround + _threatLevelAir) != 0) then {_threatRatioInfa = _threatLevelInfa / (_threatLevelGround + _threatLevelAir);} else {_threatRatioInfa = _threadLevelInfa;};
//_threatRatioInfa is now holding the ratio between the amount of infantry units and used vehicles
//If _threatRatioInfa < 1 means alot of vehicles with only one or two persons in it (ineffectiv to operate)
//If _threatRatioInfa > 1 means alot of infantry with only a few weak vehicles 
//If _threatRatioInfa = 0 means infantry troup equal strength with unknown vehicles

_threatRatioVehicles = 0;
if((_threatLevelAir != 0) then {_threatRatioVehicles = _threatLevelGround/_threatLevelAir;} else {_threatRatioVehicles = _threatLevelGround;};
//_threatRatioVehicles is now holding the ratio between the amount of ground and air vehicles
//If _threatRatioVehicles < 1 means alot of air vehicles
//If _threatRatioVehicles > 1 means alot of ground vehicles
//If _threatRatioVehicles = 0 means no ground vehicle but unknown air amount

_threatRatioDefense = 0;
if(_threatLevelAA != 0) then {_threatRatioDefense = _threatLevelAT / _threatLevelAA;} else {_threatRatioDefense = _threatLevelAT;};
//_threatRatioDefense is now holding the ratio between the amount of AA defense and AT defense
//If _threatRatioDefense < 1 means alot of AA present
//If _threatRatioDefense > 1 means alot of AT present
//If _threatRatioDefense = 0 means no AT defense with unknown AA present

_reinforcementsNeeded = false;
if((0 max _threadLevelInfa) * _threatRatioInfa + (0 max _threatLevelGround) + (0 max _threatLevelAir) > 1) then {_reinforcementsNeeded = true;};

_mortarRecommended = false;
if (_threatRatioInfa > 1 AND _threatRatioDefense < 1.5 AND defenseFactor > 0.5 AND _threatLevelAT > 10 AND _threatLevelGround > 15) then {_mortarRecommended = true;}; //Well structured enemy forces, use mortar to decimize

_antiVehicleStrike = false;
if(_threatRatioInfa < 1 AND (_detectedARMOREDVehicles count > 3) then {_antiVehicleStrike = true;}; //Multiple vehicles, get in with anti vehicle teams (static tank, air support)

_airAssault = false;
if(_threatRatioDefense > 1.5 AND _threatLevelAA < 10) then {_airAssault = true;}; //Alot of AT, attack with Air vehicles

_groundAssault = false;
if(_threatRatioDefense < 0.5 AND _threatLevelAT < 10) then {_groundAssault = true;}; // Alot of AA, attack with Ground forces

//Recommendations done, prepare to return data
_recommendations = [_reinforcementsNeeded, _mortarRecommended, _antiVehicleStrike, _airAssault, _groundAssault];
_threatLevels = [_threadLevelInfa, _threatLevelGround, _threatLevelAir, _threatLevelAT, _threatLevelAA];
_detectedVehicles = [_detectedCARVehicles, _detectedARMOREDVehicles, _detectedAIRVehicles];

_result = [_recommendations, _threatLevels, _detectedVehicles];

//Returning data
_result
