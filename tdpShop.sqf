// tdpShop.sqf
params ["_target", "_caller", "_actionId", "_arguments"];
private _mode = _arguments select 0;

systemChat format ["Modo seleccionado: %1", _mode];  // Debug

private _prices = [
    ["CUP_O_RU_Soldier_MSV_VSR93", 200],
    ["CUP_O_RU_Soldier_AT_MSV_VSR93", 300],
    ["CUP_O_RU_Soldier_AR_MSV_VSR93", 350],
    ["CUP_O_RU_Soldier_Medic_MSV_VSR93", 400],
    ["CUP_O_RU_Soldier_MG_MSV_VSR93", 450],
    ["CUP_O_RU_Soldier_Engineer_MSV_VSR93", 500],
    ["CUP_O_RU_Soldier_TL_MSV_VSR93", 600]
];

private _findSafeSpawnPos = {
    params ["_isVehicle"];
    
    private _basePos = getPosATL _target;
    systemChat format ["Buscando posición de spawn segura..."];
    
    if (_basePos isEqualTo [0,0,0]) exitWith {
        systemChat "Error: No se puede determinar posición de spawn";
        _basePos
    };
    
    private _minRadius = if (_isVehicle) then { 15 } else { 5 };
    private _maxRadius = if (_isVehicle) then { 30 } else { 15 };
    private _checkRadius = if (_isVehicle) then { 8 } else { 3 };
    
    private _radius = _minRadius;
    private _found = false;
    private _finalPos = _basePos;
    private _attempts = 0;
    private _maxAttempts = 50;
    
    while {!_found && _attempts < _maxAttempts} do {
        _attempts = _attempts + 1;
        
        private _angle = random 360;
        private _testPos = [
            (_basePos select 0) + (_radius * cos _angle),
            (_basePos select 1) + (_radius * sin _angle),
            0
        ];
        
        _testPos set [2, getTerrainHeightASL (getPos _target)];
        private _surfaceHeight = getTerrainHeightASL _testPos;
        _testPos set [2, _surfaceHeight];
        
        private _nearUnits = nearestObjects [_testPos, ["Man"], _checkRadius];
        private _nearVehicles = nearestObjects [_testPos, ["LandVehicle"], _checkRadius * 2];
        private _nearBuildings = nearestObjects [_testPos, ["Building"], _checkRadius];
        
        if (count _nearUnits == 0 && count _nearVehicles == 0 && count _nearBuildings == 0) then {
            _found = true;
            _finalPos = ASLtoATL _testPos;
            _finalPos set [2, 0];
        } else {
            if (_radius < _maxRadius) then {
                _radius = _radius + 2;
            } else {
                _radius = _minRadius;
            };
        };
    };
    
    if (!_found) then {
        systemChat "Advertencia: No se encontró posición óptima, usando mejor posición disponible";
    };
    
    _finalPos
};

private _buyUnit = {
    params ["_unitClass"];
    private _price = 0;
    {
        if (_x select 0 == _unitClass) exitWith {
            _price = _x select 1;
        };
    } forEach _prices;
    
    private _playerMoney = player getVariable ["dinero", 0];
    systemChat format ["Intentando comprar: %1 por %2$", _unitClass, _price];
    
    if (_playerMoney >= _price) then {
        private _spawnPos = [false] call _findSafeSpawnPos;
        private _unit = (group player) createUnit [_unitClass, _spawnPos, [], 0, "NONE"];
        if (!isNull _unit) then {
            if (_unitClass == "CUP_O_RU_Survivor_MSV_VSR93") then {
                _unit forceAddUniform "CUP_U_O_RUS_VSR93_MSV_rolled_up";
            };
            player setVariable ["dinero", _playerMoney - _price, true];
            systemChat format ["Unidad creada. Fondos restantes: %1$", player getVariable "dinero"];
        } else {
            systemChat "Error al crear unidad";
        };
    } else {
        systemChat format ["Fondos insuficientes. Necesitas: %1$", _price];
    };
};

switch (_mode) do {
    case "buy_rifleman_tdp": {["CUP_O_RU_Soldier_MSV_VSR93"] call _buyUnit};
    case "buy_at_tdp": {["CUP_O_RU_Soldier_AT_MSV_VSR93"] call _buyUnit};
    case "buy_ar_tdp": {["CUP_O_RU_Soldier_AR_MSV_VSR93"] call _buyUnit};
    case "buy_medic_tdp": {["CUP_O_RU_Soldier_Medic_MSV_VSR93"] call _buyUnit};
    case "buy_mg_tdp": {["CUP_O_RU_Soldier_MG_MSV_VSR93"] call _buyUnit};
    case "buy_engineer_tdp": {["CUP_O_RU_Soldier_Engineer_MSV_VSR93"] call _buyUnit};
    case "buy_tl_tdp": {["CUP_O_RU_Soldier_TL_MSV_VSR93"] call _buyUnit};
    // Para vehículos, usar el sistema de preview
    case "buy_uaz_tdp": {["CUP_O_UAZ_Unarmed_RU", 500] call shop_fnc_startPreview};
    case "buy_truck_tdp": {["CUP_V3S_Open_NAPA", 1000] call shop_fnc_startPreview};
    case "buy_btr60_tdp": {["CUP_O_BTR60_Green_RU", 4000] call shop_fnc_startPreview};
    case "buy_tank_tdp": {["CUP_O_T55_CHDKZ", 8000] call shop_fnc_startPreview};
    default {
        systemChat format ["Modo no reconocido: %1", _mode];
    };
};

[] spawn {
    disableSerialization;
    private _display = uiNamespace getVariable "MoneyDisplay";
    if (!isNil "_display") then {
        private _ctrl = _display displayCtrl 1100;
        _ctrl ctrlSetText format ["Fondos: %1$", player getVariable ["dinero", 0]];
    };
};