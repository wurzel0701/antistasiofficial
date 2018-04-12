private ["_marker","_threat","_isMarker","_position","_isFIA","_analyzed","_size"];

_threat = 0;


{if (_x in unlockedWeapons) then {_threat = 5};} forEach genAALaunchers;


_marker = _this select 0;
_isMarker = true;
if (_marker isEqualType []) then {_isMarker = false; _position = _marker} else {_position = getMarkerPos _marker};


//Check if attacked position is under FIA control
_isFIA = false;
if (_isMarker) then {
	if (_marker in mrkAAF) then {
		{
			if (getMarkerPos _x distance _position < (distanciaSPWN*1.5)) then {
				//If not under FIA control, check if valuable target
				if ((_x in bases) or (_x in aeropuertos)) then {_threat = _threat + 3} else {_threat = _threat + 1};
			};
		} forEach (controles + puestos + colinas + bases + aeropuertos - mrkFIA);
	} else {_isFIA = true;};
} else { _isFIA = true;};

//If it is under FIA control
if (_isFIA) then {
	{
		if (getMarkerPos _x distance _position < distanciaSPWN) then {
			_analyzed = _x;
			_garrison = garrison getVariable [_analyzed,[]];
			_threat = _threat + (floor((count _garrison)/4));
			_size = [_analyzed] call sizeMarker;
			_staticWeapons = staticsToSave select {_x distance (getMarkerPos _analyzed) < _size};
			if (count _staticWeapons > 0) then {
				_threat = _threat + ({typeOf _x in statics_allMGs} count _staticWeapons) + (5*({typeOf _x in statics_allAAs} count _staticWeapons));
			};
		};
	} forEach (mrkFIA - ciudades - controles - colinas - puestosFIA);
};

//Check the attacking forces
if (not _isFIA) then {
	//Add threat for every AI and Player attacking the position
	{
		if(isPlayer _x) then 
		{
			_threat = _threat + 3;
		}
		else 
		{
			_threat = _threat + 0.1 * (server getVariable [skillFIA, 1]);
		};
		//Detect FIA/NATO vehicles
	} forEach ([500,0,_position,"BLUFORSpawn"] call distanceUnits);
	
	//Reduce threat for every AAF unit defending the position
	{
		_threat = _threat - 0.1 * (server getVariable [skillAAF, 1]);
	}forEach ([500,0,_position,"OPFORSpawn"]);

};



_threat