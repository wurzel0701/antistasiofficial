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

if(_type == "REINFORCE") exitWith
{
	//Position needs reinforcement, should be an easy task
	if(count (_threatEval select 2) == 0) then 
	{
		//send reinforcement in truck with a small chance of small escort
		_escort = nil;
		//How do I extract vehicles from the actual AAF pool
		if(random 100 < 15) then {_escort = selectRandom (vehPatrol - ["I_Heli_light_03_unarmed_F"])};
		//[_markerPos, _escort] remoteExec ["createReinforcements", AS_fnc_getNextWorker] //Active when script is ready
	}; 
};
if(_type == "ASSASINATE") exitWith
{
	if (_target == nil) exitWith {diag_log "No reference of target passed for assasination in calculateForces.sqf"};
	//[_threatEval, _target] remoteExec ["createAssasination" , AS_fnc_getNextWorker]; //Activate when script is ready
};
if(_type == "QRF") exitWith
{
	_landBasedQRF = ((_threatEval select 1) select 3) < ((_threatEval select 1) select 4);
	//If relative AT defense is less then AA defense, attack land based 
	//[_threatEval, _markerPos, _landBasedQRF] remoteExec ["createQRF", AS_fnc_getNextWorker]; //Active when script is ready
};
if(_type == "ATTACK" OR _type == "MAJORATTACK") exitWith
{
	_major = (_type == "MAJORATTACK");
	//[_threatEval, _markerPos, _major] remoteExec ["createAttack", AS_fnc_getNextWorker]; //Activate when script is ready
};
if(_type == "SPOT" OR _type == "") exitWith 
{
	//[_markerPos] remoteExec ["createSpotterTeam", AS_fnc_getNextWorker]; //Pretty sure you know the drill
}