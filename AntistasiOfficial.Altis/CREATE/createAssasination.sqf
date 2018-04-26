params ["_threatEval", "_target"];

if(vehicle _target != _target) then {_target = vehicle _target};

_targetPosition = getPos _target;
_targetSpeed = speed _target;
_composition = [];
if(_target isKindOf "Men") then
{
	_composition = [_threatEval, ["SINGLETARGET", _target], "MORTAR", "LOW"] call AS_fnc_calculateTroups;
	_attackPlan = [_composition, _threatEval, ["SINGLETARGET", _target], "LOW"] call AS_fnc_calculateFight;
};
if(_target isKindOf "Car") then
{
	_speed = "LOW";
	if(_targetSpeed > 30) then {_speed = "NORMAL"};
	_composition = [_threatEval, ["SINGLETARGET", _target], "", _speed] call AS_fnc_calculateTroups;
	_attackPlan = [_composition, _threatEval, ["SINGLETARGET", _target], _speed] call AS_fnc_calculateFight;
};
if(_target isKindOf "Air") then 
{
	_composition = [_threatEval, ["SINGLETARGET", _target], "JET", "HIGH"] call AS_fnc_calculateTroups;
	_attackPlan = [_composition, _threatEval, ["SINGLETARGET", _target], "HIGH"] call AS_fnc_calculateFight;
};
if(_target isKindOf "Armored") then 
{
	_composition = [_threatEval, ["SINGLETARGET", _target], "JET", "HIGH"] call AS_fnc_calculateTroups;
	_attackPlan = [_composition, _threatEval, ["SINGLETARGET", _target], "HIGH"] call AS_fnc_calculateFight;
};

[_composition, _attackPlan] remoteExec ["executeAttack", AS_fnc_getNextWorker];

