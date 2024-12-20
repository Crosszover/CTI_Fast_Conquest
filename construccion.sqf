// Variables globales para construcción
missionNamespace setVariable ["construccionActiva", false];
missionNamespace setVariable ["edificioFantasma", nil];
missionNamespace setVariable ["flechaSpawn", nil];
missionNamespace setVariable ["rotacionEdificio", 0];
missionNamespace setVariable ["edificioValido", false];
missionNamespace setVariable ["ruinas", nil];
missionNamespace setVariable ["construccionHandle", nil];
missionNamespace setVariable ["edificioParams", []];

// Función para verificar edificios operativos
fnc_verificarEdificiosOperativos = {
    private _edificiosDisponibles = (
        allMissionObjects "Land_Cargo_House_V1_F" + 
        allMissionObjects "Land_Cargo_HQ_V1_F" + 
        allMissionObjects "Land_Addon_05_F" +
		allMissionObjects "Land_RuggedTerminal_01_communications_hub_F"
    ) select {
        alive _x && 
        !isNil {_x getVariable "spawnPos"}
    };
    
    // Si no hay HQ y no hay edificios, fin de la misión
    if (!alive OPFOR_HQ && count _edificiosDisponibles == 0) then {
        ["OpforDerrota", false] remoteExec ["BIS_fnc_endMission", 0];
    } else {
        private _mensaje = if (alive OPFOR_HQ) then {
            format ["Quedan %1 edificios operativos + HQ", count _edificiosDisponibles];
        } else {
            format ["Quedan %1 edificios operativos", count _edificiosDisponibles];
        };
        [_mensaje] remoteExec ["hint", 0];
    };
};

// Mover el respawn inicial a OPFOR_HQ
if (!isNil "OPFOR_HQ") then {
    private _hqPos = getPos OPFOR_HQ;
    "respawn_east" setMarkerPos _hqPos;
    systemChat "Respawn inicial movido a OPFOR_HQ";
} else {
    hint "Error: OPFOR_HQ no está definido";
};

// Función para obtener posición de spawn
fnc_getPosicionSpawn = {
    params ["_edificio"];
    private _dir = getDir _edificio;
    private _pos = getPosATL _edificio;
    private _spawnPos = _pos getPos [15, _dir];
    _spawnPos
};

// Función para crear flecha de spawn
fnc_crearFlechaSpawn = {
    params ["_pos", "_dir"];
    private _flecha = createVehicle ["Sign_Arrow_F", _pos, [], 0, "CAN_COLLIDE"];
    _flecha setPosATL _pos;
    _flecha setDir _dir;
    _flecha setObjectTextureGlobal [0, "#(argb,8,8,3)color(0,1,0,1)"];
    _flecha
};

// Función para comprobar posición válida
fnc_comprobarPosicion = {
    params ["_edificio"];
    private _pos = getPosATL _edificio;
    private _cercanos = nearestObjects [_pos, ["House", "Building"], 5];
    _cercanos = _cercanos - [_edificio];
    if (count _cercanos > 0) exitWith {false};
    private _normal = surfaceNormal _pos;
    private _inclinacion = acos (_normal vectorDotProduct [0,0,1]);
    if (_inclinacion > 25) exitWith {false};
    true
};

// Función para rotar edificio
fnc_rotarEdificio = {
    params ["_direccion"];
    private _rotacionActual = missionNamespace getVariable ["rotacionEdificio", 0];
    _rotacionActual = _rotacionActual + (_direccion * 10);
    if (_rotacionActual >= 360) then {
        _rotacionActual = _rotacionActual - 360;
    };
    if (_rotacionActual < 0) then {
        _rotacionActual = 360 + _rotacionActual;
    };
    private _snapAngles = [0, 90, 180, 270];
    {
        if (abs(_rotacionActual - _x) < 5) then {
            _rotacionActual = _x;
        };
    } forEach _snapAngles;
    missionNamespace setVariable ["rotacionEdificio", _rotacionActual];
};

// Función para cancelar construcción
fnc_cancelarConstruccion = {
    private _edificioFantasma = missionNamespace getVariable ["edificioFantasma", objNull];
    private _flechaSpawn = missionNamespace getVariable ["flechaSpawn", objNull];
    
    if (!isNull _edificioFantasma) then {
        deleteVehicle _edificioFantasma;
    };
    
    if (!isNull _flechaSpawn) then {
        deleteVehicle _flechaSpawn;
    };
    
    terminate (missionNamespace getVariable ["construccionHandle", scriptNull]);
    missionNamespace setVariable ["construccionHandle", nil];
    missionNamespace setVariable ["construccionActiva", false];
    missionNamespace setVariable ["edificioFantasma", nil];
    missionNamespace setVariable ["flechaSpawn", nil];
    missionNamespace setVariable ["rotacionEdificio", 0];
    missionNamespace setVariable ["edificioValido", false];
    missionNamespace setVariable ["edificioParams", []];
    hint "Construcción cancelada";
};

// Función para confirmar construcción
fnc_confirmarConstruccion = {
    if !(missionNamespace getVariable ["edificioValido", false]) exitWith {
        hint "Posición no válida para construir";
    };
    
    private _edificioFantasma = missionNamespace getVariable ["edificioFantasma", objNull];
    private _flechaSpawn = missionNamespace getVariable ["flechaSpawn", objNull];
    
    if (isNull _edificioFantasma) exitWith {
        hint "Error: No hay edificio fantasma";
    };
    
    private _params = missionNamespace getVariable ["edificioParams", []];
    if (count _params < 6) exitWith {
        hint "Error: Parámetros de construcción no válidos";
    };
    
    _params params ["_ruinasClase", "_edificioClase", "_tiempoConstruccion", "_scriptArchivo", "_nombreEdificio", "_funcionInit"];
    
    private _pos = getPosATL _edificioFantasma;
    private _dir = getDir _edificioFantasma;
    private _spawnPos = [_edificioFantasma] call fnc_getPosicionSpawn;
    
    // Limpiar objetos temporales
    deleteVehicle _edificioFantasma;
    deleteVehicle _flechaSpawn;
    
    // Reset variables
    terminate (missionNamespace getVariable ["construccionHandle", scriptNull]);
    missionNamespace setVariable ["construccionHandle", nil];
    missionNamespace setVariable ["edificioFantasma", nil];
    missionNamespace setVariable ["flechaSpawn", nil];
    missionNamespace setVariable ["construccionActiva", false];
    missionNamespace setVariable ["rotacionEdificio", 0];
    missionNamespace setVariable ["edificioValido", false];
    
    // Crear las ruinas
    private _ruinas = createVehicle [_ruinasClase, _pos, [], 0, "CAN_COLLIDE"];
    _ruinas setPosATL _pos;
    _ruinas setDir _dir;
    
    private _ruinasId = format ["ruinas_%1", floor random 100000];
    missionNamespace setVariable [_ruinasId, _ruinas];
    
    hint format ["Iniciando construcción de %1...", _nombreEdificio];
    
    [_pos, _dir, _params, _ruinasId, _spawnPos] spawn {
        params ["_pos", "_dir", "_params", "_ruinasId", "_spawnPos"];
        _params params ["_ruinasClase", "_edificioClase", "_tiempoConstruccion", "_scriptArchivo", "_nombreEdificio", "_funcionInit"];
        
        sleep _tiempoConstruccion;
        
        private _ruinas = missionNamespace getVariable [_ruinasId, objNull];
        if (!isNull _ruinas) then {
            deleteVehicle _ruinas;
            missionNamespace setVariable [_ruinasId, nil];
            
            private _edificioFinal = createVehicle [_edificioClase, _pos, [], 0, "CAN_COLLIDE"];
            _edificioFinal setPosATL _pos;
            _edificioFinal setDir _dir;
            
            // Guardar posición de spawn en el edificio final
            _edificioFinal setVariable ["spawnPos", _spawnPos, true];
            
            // Añadir Event Handler para cuando el edificio sea destruido
            _edificioFinal addEventHandler ["Killed", {
                params ["_unit", "_killer"];
                
                // Eliminar el marcador de spawn asociado
                private _markers = allMapMarkers select {
                    _x find "respawn_east_" == 0 && 
                    (getMarkerPos _x) distance (_unit getVariable ["spawnPos", [0,0,0]]) < 1
                };
                
                {deleteMarker _x;} forEach _markers;
                
                // Verificar estado general de edificios
                [] call fnc_verificarEdificiosOperativos;
            }];
            
            // Crear marcador de spawn
            private _markerName = format ["respawn_east_%1", floor random 10000];
            private _marker = createMarker [_markerName, _spawnPos];
            _marker setMarkerType "respawn_inf";
            _marker setMarkerColor "ColorRed";
            
            [_edificioFinal] call compile preprocessFileLineNumbers _scriptArchivo;
            [_edificioFinal] call (missionNamespace getVariable [_funcionInit, {}]);
            
            hint format ["%1 construido - Nuevo punto de respawn disponible", _nombreEdificio];
            
            // Verificar edificios operativos después de la construcción
            [] call fnc_verificarEdificiosOperativos;
        };
    };
};

// Función para iniciar construcción
fnc_iniciarConstruccion = {
    params [
        "_ruinasClase",
        "_edificioClase",
        "_tiempoConstruccion",
        "_scriptArchivo",
        "_nombreEdificio",
        "_funcionInit"
    ];
    
    if (missionNamespace getVariable ["construccionActiva", false]) then {
        [] call fnc_cancelarConstruccion;
    };
    
    missionNamespace setVariable ["construccionActiva", true];
    missionNamespace setVariable ["rotacionEdificio", 0];
    missionNamespace setVariable ["edificioValido", false];
    
    private _pos = screenToWorld [0.5, 0.5];
    private _edificioFantasma = createVehicle [_ruinasClase, _pos, [], 0, "NONE"];
    _edificioFantasma enableSimulation false;
    _edificioFantasma allowDamage false;
    _edificioFantasma setDir 0;
    missionNamespace setVariable ["edificioFantasma", _edificioFantasma];
    _edificioFantasma setObjectTextureGlobal [0, "#(argb,8,8,3)color(0,1,0,0.5)"];
    
    // Crear flecha inicial
    private _spawnPos = [_edificioFantasma] call fnc_getPosicionSpawn;
    private _flecha = [_spawnPos, 0] call fnc_crearFlechaSpawn;
    missionNamespace setVariable ["flechaSpawn", _flecha];
    
    missionNamespace setVariable ["edificioParams", [_ruinasClase, _edificioClase, _tiempoConstruccion, _scriptArchivo, _nombreEdificio, _funcionInit]];
    
    private _handle = [] spawn {
        while {missionNamespace getVariable ["construccionActiva", false]} do {
            private _edificio = missionNamespace getVariable ["edificioFantasma", objNull];
            private _flecha = missionNamespace getVariable ["flechaSpawn", objNull];
            private _rotacionEdificio = missionNamespace getVariable ["rotacionEdificio", 0];
            
            if (!isNull _edificio && !isNull _flecha) then {
                private _start = AGLToASL (positionCameraToWorld [0,0,0]);
                private _end = AGLToASL (positionCameraToWorld [0,0,50]);
                private _intersect = lineIntersectsSurfaces [_start, _end, player, _edificio, true, 1];
                
                if (count _intersect > 0) then {
                    private _intersectPos = ASLToAGL ((_intersect select 0) select 0);
                    _edificio setPosATL [_intersectPos select 0, _intersectPos select 1, _intersectPos select 2];
                    
                    // Actualizar posición y rotación de la flecha
                    private _rotacion = missionNamespace getVariable ["rotacionEdificio", 0];
                    _edificio setDir _rotacion;
                    private _spawnPos = [_edificio] call fnc_getPosicionSpawn;
                    _flecha setPosATL _spawnPos;
                    _flecha setDir _rotacion;
                };
                
                private _valido = [_edificio] call fnc_comprobarPosicion;
                missionNamespace setVariable ["edificioValido", _valido];
                
                _edificio setObjectTextureGlobal [0, if (_valido) then {
                    "#(argb,8,8,3)color(0,1,0,0.5)"
                } else {
                    "#(argb,8,8,3)color(1,0,0,0.5)"
                }];
                
                hintSilent parseText format [
                    "<t size='1.2'>Modo Construcción</t><br/><br/>Rotación: <t color='#00ff00'>%1°</t><br/><t color='#00ff00'>ESPACIO</t> para colocar<br/><t color='#00ff00'>NUMPAD / y *</t> para rotar<br/><t color='#00ff00'>Click derecho</t> para cancelar<br/><br/>La flecha verde indica el punto de spawn",
                    round(_rotacionEdificio)
                ];

                if (!_valido) then {
                    _edificio setObjectTextureGlobal [0, "#(argb,8,8,3)color(1,0,0,0.5)"];
                    sleep 0.2;
                    _edificio setObjectTextureGlobal [0, "#(argb,8,8,3)color(1,0,0,0.2)"];
                    sleep 0.2;
                };
            };
            sleep 0.01;
        };
    };
    
    missionNamespace setVariable ["construccionHandle", _handle];
};

// Función para agregar menú de construcción
fnc_agregarMenuConstruccion = {
    params ["_vehiculo"];
    
    _vehiculo addAction [
        "<t color='#FF0000'>Construir Centro de Reclutamiento ($2.000)</t>",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            private _cost = 2000;
            private _playerMoney = player getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                player setVariable ["dinero", _playerMoney - _cost, true];
                ["Land_Cargo_House_V1_ruins_F", "Land_Cargo_House_V1_F", 30, "recruitment_center.sqf", "Centro de Reclutamiento", "recruitment_fnc_initSystem"] call fnc_iniciarConstruccion;
            } else {
                systemChat format ["Fondos insuficientes. Necesitas: %1$", _cost];
            };
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
	
	_vehiculo addAction [
			"<t color='#FFD700'>Construir Centro de Comunicaciones ($3.000)</t>",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				private _cost = 3000;
				private _playerMoney = player getVariable ["dinero", 0];
				
				if (_playerMoney >= _cost) then {
					player setVariable ["dinero", _playerMoney - _cost, true];
					["Land_MobileRadar_01_generator_F", "Land_MobileRadar_01_generator_F", 45, "commsHub.sqf", "Centro de Comunicaciones", "commsHub_fnc_initSystem"] call fnc_iniciarConstruccion;
				} else {
					systemChat format ["Fondos insuficientes. Necesitas: %1$", _cost];
				};
			},
			nil,
			1.5,
			true,
			true,
			"",
			"true",
			10
		];
    
    _vehiculo addAction [
        "<t color='#0000FF'>Construir Cuartel ($4.000)</t>",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            private _cost = 4000;
            private _playerMoney = player getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                player setVariable ["dinero", _playerMoney - _cost, true];
                ["Land_Cargo_HQ_V1_ruins_F", "Land_Cargo_HQ_V1_F", 60, "barracks.sqf", "Cuartel", "barracks_fnc_initSystem"] call fnc_iniciarConstruccion;
            } else {
                systemChat format ["Fondos insuficientes. Necesitas: %1$", _cost];
            };
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
    
    _vehiculo addAction [
        "<t color='#FF8C00'>Construir Centro de Vehículos ($6.000)</t>",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            private _cost = 6000;
            private _playerMoney = player getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                player setVariable ["dinero", _playerMoney - _cost, true];
                ["Land_Addon_05_ruins_F", "Land_Addon_05_F", 90, "vehicleCenter.sqf", "Centro de Vehículos", "vehicleCenter_fnc_initSystem"] call fnc_iniciarConstruccion;
            } else {
                systemChat format ["Fondos insuficientes. Necesitas: %1$", _cost];
            };
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
};

// Agregar menú al HQ
//if (!isNil "OPFOR_HQ") then {
//    [OPFOR_HQ] call fnc_agregarMenuConstruccion;
//} else {
//    hint "Error: OPFOR_HQ no está definido";
//};

// Configuración de controles
[] spawn {
    waitUntil {!isNull findDisplay 46};
    (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
        private _keySpace = 57;
        private _keyDivide = 181;
        private _keyMultiply = 55;
        if (missionNamespace getVariable ["construccionActiva", false]) then {
            switch (_key) do {
                case _keySpace: {
                    [] call fnc_confirmarConstruccion;
                    true
                };
                case _keyDivide: {
                    [-1] call fnc_rotarEdificio;
                    true
                };
                case _keyMultiply: {
                    [1] call fnc_rotarEdificio;
                    true
                };
                default {false};
            };
        } else {
            false
        };
    }];
    
    (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {
        params ["_displayOrControl", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
        if (_button == 1 && {missionNamespace getVariable ["construccionActiva", false]}) then {
            [] call fnc_cancelarConstruccion;
        };
    }];
};