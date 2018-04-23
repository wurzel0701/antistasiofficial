params ["_threatEval", "_marker", "_target", ["_type", ""]];

private _markerPos;
if (_target != nil) then 
{
	_markerPos = getPos _target;
};
if (_marker != nil) then 
{
	_isMarker = !(typeName _marker == "ARRAY");
	_markerPos = _marker;
	if (typeName _marker == "STRING") then {_markerPos = getMarkerPos (_marker)};
};

if(_type == "REINFORCE") then 
{
	//Position needs reinforcement, should be an easy task
	if(count (_threatEval select 2) == 0) then 
	{
		//send reinforcement in truck with a small chance of small escort
		_escort = nil;
		if(random 100 < 15) then {_escort = selectRandom (vehPatrol - ["I_Heli_light_03_unarmed_F"])};
	}; 
};