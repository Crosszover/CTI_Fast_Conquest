// shop.sqf - Sistema de spawn de unidades
if (isNil "SHOP_CONFIG") then {
    SHOP_CONFIG = [] call {
        private _config = createHashMap;
        
        // Configuración de spawn
        _config set ["MIN_SPAWN_DISTANCE", 2];      // Distancia mínima entre unidades
        _config set ["MAX_SPAWN_ATTEMPTS", 5];      // Máximo número de intentos de spawn
        _config set ["SPAWN_RADIUS", 15];           // Radio máximo de búsqueda
        _config set ["VEHICLE_CHECK_RADIUS", 4];    // Radio para revisar vehículos cercanos
        _config set ["HEIGHT_CHECK", 3];            // Altura para verificar obstáculos
        _config set ["WATER_CHECK", true];          // Activar verificación de agua
        
        _config
    };
    
    publicVariable "SHOP_CONFIG";
};

// Sistema de logging para debug
shop_fnc_log = {
    params ["_message"];
    if (isNil "SHOP_DEBUG") then { SHOP_DEBUG = true; };
    if (SHOP_DEBUG) then {
        systemChat format ["Shop Debug: %1", _message];
        diag_log format ["Shop Debug: %1", _message];
    };
};

// Función principal para encontrar posición segura de spawn
shop_fnc_findSafeSpawnPos = {
    params ["_building"];
    ["Buscando posición de spawn"] call shop_fnc_log;
    
    // Intentar usar posición predefinida si existe
    private _spawnPos = _building getVariable ["spawnPos", nil];
    
    if (!isNil "_spawnPos") exitWith {
        ["Usando posición predefinida"] call shop_fnc_log;
        _spawnPos
    };
    
    // Si no hay posición predefinida, usar posición relativa al edificio
    private _buildingPos = getPosATL _building;
    private _dir = getDir _building;
    private _defaultPos = _buildingPos getPos [SHOP_CONFIG get "SPAWN_RADIUS", _dir];
    _defaultPos set [2, (_buildingPos select 2)]; // Mantener la misma altura que el edificio
    
    ["Usando posición relativa al edificio"] call shop_fnc_log;
    _defaultPos
};

// Función para verificar si una posición es segura
shop_fnc_isPositionSafe = {
    params ["_pos"];
    
    // Verificar agua si está configurado
    if (SHOP_CONFIG get "WATER_CHECK" && {surfaceIsWater _pos}) exitWith {
        ["Posición en agua - no segura"] call shop_fnc_log;
        false
    };
    
    // Verificar obstáculos
    private _intersects = lineIntersectsSurfaces [
        AGLToASL _pos,
        AGLToASL (_pos vectorAdd [0, 0, SHOP_CONFIG get "HEIGHT_CHECK"]),
        objNull,
        objNull,
        true,
        1,
        "GEOM"
    ];
    
    if (count _intersects > 0) then {
        ["Obstáculos detectados - posición no segura"] call shop_fnc_log;
        false
    } else {
        true
    };
};

// Función para validar y ajustar posición de spawn
shop_fnc_validateAndAdjustSpawnPos = {
    params ["_initialPos", "_building"];
    
    private _config = SHOP_CONFIG;
    private _minDist = _config get "MIN_SPAWN_DISTANCE";
    private _maxAttempts = _config get "MAX_SPAWN_ATTEMPTS";
    private _vehicleRadius = _config get "VEHICLE_CHECK_RADIUS";
    private _dir = getDir _building;
    
    private _attempts = 0;
    private _finalPos = _initialPos;
    private _found = false;
    
    while {!_found && _attempts < _maxAttempts} do {
        private _testPos = _initialPos;
        
        if (_attempts > 0) then {
            _testPos = _initialPos getPos [
                _minDist * _attempts,
                _dir + (90 * _attempts)
            ];
            _testPos set [2, (_initialPos select 2)]; // Mantener altura original
        };
        
        // Verificar unidades y vehículos cercanos
        private _nearUnits = _testPos nearEntities ["Man", _minDist];
        private _nearVehicles = _testPos nearEntities ["LandVehicle", _vehicleRadius];
        
        if (count _nearUnits == 0 && count _nearVehicles == 0) then {
            if ([_testPos] call shop_fnc_isPositionSafe) then {
                _found = true;
                _finalPos = _testPos;
                ["Posición segura encontrada"] call shop_fnc_log;
            };
        };
        
        _attempts = _attempts + 1;
    };
    
    // Si no se encontró posición segura, usar BIS_fnc_findSafePos
    if (!_found) then {
        ["Usando BIS_fnc_findSafePos como fallback"] call shop_fnc_log;
        private _safePos = [
            _initialPos,
            0,
            _config get "SPAWN_RADIUS",
            _minDist,
            0,
            0.5,
            0
        ] call BIS_fnc_findSafePos;
        
        // Asegurar que mantenemos la coordenada Z
        _safePos set [2, (_initialPos select 2)];
        _finalPos = _safePos;
    };
    
    _finalPos
};

// Función para crear la unidad
shop_fnc_spawnUnit = {
    params ["_unitClass", "_building"];
    
    ["Iniciando spawn de unidad"] call shop_fnc_log;
    
    private _spawnPos = [_building] call shop_fnc_findSafeSpawnPos;
    _spawnPos = [_spawnPos, _building] call shop_fnc_validateAndAdjustSpawnPos;
    
    if (_spawnPos isEqualTo [0,0,0]) exitWith {
        ["Error: Posición de spawn inválida"] call shop_fnc_log;
        false
    };
    
    ["Creando unidad"] call shop_fnc_log;
    private _unit = (group player) createUnit [_unitClass, _spawnPos, [], 0, "NONE"];
    
    if (!isNull _unit) then {
        // Configuración inicial de la unidad
        _unit setDir (getDir _building);
        _unit setPosATL _spawnPos;
        
        // Verificar si la unidad se creó correctamente
        if (alive _unit) then {
            ["Unidad creada exitosamente"] call shop_fnc_log;
            // Eventos post-spawn
            [_unit, _building] call shop_fnc_postSpawnInit;
            true
        } else {
            ["Error: La unidad no sobrevivió al spawn"] call shop_fnc_log;
            deleteVehicle _unit;
            false
        };
    } else {
        ["Error: No se pudo crear la unidad"] call shop_fnc_log;
        false
    };
};

// Función para inicialización post-spawn
shop_fnc_postSpawnInit = {
    params ["_unit", "_building"];
    
    // Aquí puedes añadir cualquier inicialización adicional
    // Por ejemplo, habilidades, loadout, etc.
    
    // Eventos
    _unit addEventHandler ["Killed", {
        params ["_unit"];
        ["Unidad eliminada"] call shop_fnc_log;
    }];
};

// Función para inicializar el sistema de spawn
shop_fnc_initSpawnSystem = {
    params ["_building"];
    
    // Configurar punto de spawn predefinido
    if (isNil {_building getVariable "spawnPos"}) then {
        private _buildingPos = getPosATL _building;
        private _dir = getDir _building;
        private _spawnPos = _buildingPos getPos [5, _dir];
        _spawnPos set [2, (_buildingPos select 2)];
        _building setVariable ["spawnPos", _spawnPos, true];
        
        ["Sistema de spawn inicializado"] call shop_fnc_log;
    };
    
    // Crear trigger para limpieza
    [_building] call shop_fnc_createCleanupTrigger;
};

// Función para crear trigger de limpieza
shop_fnc_createCleanupTrigger = {
    params ["_building"];
    
    private _trgCleanup = createTrigger ["EmptyDetector", getPos _building];
    _trgCleanup setTriggerArea [50, 50, 0, false];
    _trgCleanup setTriggerActivation ["NONE", "PRESENT", false];
    _trgCleanup setTriggerStatements [
        "true",
        "[]",
        "[] call shop_fnc_cleanupDeadUnits;"
    ];
};

// Función para limpiar unidades muertas
shop_fnc_cleanupDeadUnits = {
    {
        if (!alive _x) then {
            deleteVehicle _x;
        };
    } forEach (allDead select {_x isKindOf "Man"});
};

// Publicar funciones necesarias
publicVariable "shop_fnc_spawnUnit";
publicVariable "shop_fnc_initSpawnSystem";