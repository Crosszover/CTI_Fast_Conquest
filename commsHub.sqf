// Cargar scripts de RF
call compileFinal preprocessFileLineNumbers "commsHub_RF.sqf";
call compileFinal preprocessFileLineNumbers "commsHub_RF_V.sqf";

// Variable para controlar la inicialización
if (isNil "COMMSHUB_INITIALIZED") then {
    COMMSHUB_INITIALIZED = [];
};

// Función helper para verificar requisitos de edificios
fnc_checkBuildingRequirement = {
    params ["_buildingType", "_buildingName"];
    
    private _exists = false;
    {
        if (typeOf _x == _buildingType && {alive _x && !isNil {_x getVariable "spawnPos"}}) exitWith {
            _exists = true;
        };
    } forEach nearestObjects [OPFOR_HQ, ["Building"], 200];
    
    if (!_exists) then {
        hint format ["Necesitas construir un %1 primero.", _buildingName];
    };
    
    _exists
};

// Función principal para inicializar el centro de comunicaciones
fnc_initializeCommsHub = {
    params ["_building"];
    
    // Verificar si este edificio ya fue inicializado
    if (_building in COMMSHUB_INITIALIZED) exitWith {};
    COMMSHUB_INITIALIZED pushBack _building;
    
    // Esperar a que el sistema HC esté disponible
    waitUntil {!isNil "HC_SYSTEM_INITIALIZED"};
    
    // Limpiar acciones existentes
    {
        _building removeAction _x;
    } forEach (actionIDs _building);
    
    // Título principal
    _building addAction [
        "<t color='#FFD700'>-- Centro de Comunicaciones --</t>",
        "",
        [],
        1.6,
        true,
        false,
        "",
        "true",
        15
    ];
    
    // Acción para comprar grupo TPR FireTeam
    _building addAction [
        "<t color='#FFD700'>TPR - FireTeam (1.450$)</t>",
        {
            params ["_target", "_caller"];
            
            if !([
                "Land_Cargo_House_V1_F",
                "Centro de Reclutamiento"
            ] call fnc_checkBuildingRequirement) exitWith {};
            
            private _cost = 1450;
            private _playerMoney = _caller getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                [_target, _caller, _cost] spawn {
                    params ["_target", "_caller", "_cost"];
                    
                    private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
                    if (isNil "_spawnPos") then {
                        _spawnPos = getPosATL _target;
                    };
                    
                    private _group = [_caller, _spawnPos] call HC_fnc_createFireTeam;
                    
                    if (!isNull _group && {count (units _group) > 0}) then {
                        [_caller, -_cost] call TPR_fnc_addMoney;
                        hint format ["TPR FireTeam desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
                    } else {
                        hint "Error al crear el equipo. Por favor, inténtalo de nuevo.";
                    };
                };
            } else {
                hint format ["Fondos insuficientes. Necesitas: %1$", _cost];
            };
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    // Acción para comprar TPR MG Team
    _building addAction [
        "<t color='#FFD700'>TPR - MG Team (1.450$)</t>",
        {
            params ["_target", "_caller"];
            
            if !([
                "Land_Cargo_House_V1_F",
                "Centro de Reclutamiento"
            ] call fnc_checkBuildingRequirement) exitWith {};
            
            private _cost = 1450;
            private _playerMoney = _caller getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                [_target, _caller, _cost] spawn {
                    params ["_target", "_caller", "_cost"];
                    
                    private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
                    private _group = createGroup [side _caller, true];
                    
                    // Crear unidades del MG Team
                    private _units = [
                        ["min_rf_soldier_TL", "Team Leader"],
                        ["min_rf_soldier_AR", "Machine Gunner"],
                        ["min_rf_soldier", "Rifleman"],
                        ["min_rf_soldier_A", "Assistant"]
                    ];
                    
                    {
                        _x params ["_class", "_role"];
                        private _unit = _group createUnit [_class, _spawnPos, [], 5, "NONE"];
                        _unit setVariable ["hcRole", _role, true];
                    } forEach _units;
                    
                    // Configurar grupo
                    _group selectLeader (units _group select 0);
                    _group setGroupId [format ["TPR-MG-%1", floor(random 1000)]];
                    
                    // Configurar HC
                    [_caller, _group, _spawnPos] call HC_fnc_setupGroup;
                    
                    // Cobrar y notificar
                    [_caller, -_cost] call TPR_fnc_addMoney;
                    hint format ["MG Team desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
                };
            } else {
                hint format ["Fondos insuficientes. Necesitas: %1$", _cost];
            };
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    // Acción para comprar TPR Vodnik PK
    _building addAction [
        "<t color='#FFD700'>TPR - Vodnik PK (3.000$)</t>",
        {
            params ["_target", "_caller"];
            
            if !([
                "Land_Cargo_House_V1_F",
                "Centro de Reclutamiento"
            ] call fnc_checkBuildingRequirement) exitWith {};
            
            private _cost = 3000;
            private _playerMoney = _caller getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                [_target, _caller, _cost] spawn {
                    params ["_target", "_caller", "_cost"];
                    
                    private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
                    private _group = createGroup [side _caller, true];
                    
                    // Crear el vehículo
                    private _veh = "CUP_O_GAZ_Vodnik_PK_RU" createVehicle _spawnPos;
                    
                    // Crear tripulación
                    private _driver = _group createUnit ["min_rf_crew", _spawnPos, [], 5, "NONE"];
                    _driver moveInDriver _veh;
                    _driver setVariable ["hcRole", "Driver", true];
                    
                    private _gunner = _group createUnit ["min_rf_crew", _spawnPos, [], 5, "NONE"];
                    _gunner moveInGunner _veh;
                    _gunner setVariable ["hcRole", "Gunner", true];
                    
                    // Configurar grupo
                    _group selectLeader _driver;
                    _group setGroupId [format ["TPR-VOD-%1", floor(random 1000)]];
                    
                    // Configurar HC
                    [_caller, _group, _spawnPos] call HC_fnc_setupGroup;
                    
                    // Cobrar y notificar
                    [_caller, -_cost] call TPR_fnc_addMoney;
                    hint format ["Vodnik PK desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
                };
            } else {
                hint format ["Fondos insuficientes. Necesitas: %1$", _cost];
            };
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];

    // Inicializar acciones RF
    [_building] call RF_fnc_initializeCommsHub;
    [_building] call RF_fnc_initializeVehicleCommsHub;
};

// Exportar funciones para uso externo
commsHub_fnc_initialize = fnc_initializeCommsHub;
commsHub_fnc_initSystem = {
    params ["_building"];
    [_building] call fnc_initializeCommsHub;
    true
};