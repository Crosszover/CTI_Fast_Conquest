// Inicializar variables globales
if (isServer) then {
    // Crear el OPFOR_HQ 
    private _hqMarkers = allMapMarkers select {_x select [0, 7] == "hq_pos_"};
    if (count _hqMarkers > 0) then {
        private _selectedMarker = selectRandom _hqMarkers;
        private _spawnPos = getMarkerPos _selectedMarker;
        
        OPFOR_HQ = createVehicle ["CUP_O_BTR90_HQ_RU", _spawnPos, [], 0, "NONE"];
        OPFOR_HQ setDir (random 360);
        publicVariable "OPFOR_HQ";
        
        // Ocultar los marcadores de spawn
        {
            _x setMarkerAlpha 0;
        } forEach _hqMarkers;
    };
    
    missionNamespace setVariable ["TPR_systemInitialized", false, true];
};

// Debug logs
diag_log "Iniciando carga de sistemas...";

// Cargar HQ_spawn para configurar los event handlers y el arsenal
[] execVM "hq_spawn.sqf";
waitUntil {!isNil "OPFOR_HQ"};
diag_log "HQ configurado, continuando con otros sistemas...";

// Cargar primero el sistema de shop y esperar a que esté disponible
[] execVM "shop.sqf";
diag_log "Shop.sqf ejecutado, esperando funciones...";
waitUntil {!isNil "shop_fnc_spawnUnit"};
diag_log "Shop cargado completamente, continuando con otros sistemas...";

// Cargar construcción y esperar a que esté disponible
[] execVM "construccion.sqf";
waitUntil {!isNil "fnc_agregarMenuConstruccion"};
[OPFOR_HQ] call fnc_agregarMenuConstruccion;

// Cargar el resto de sistemas
[] execVM "vehicleShop.sqf";
[] execVM "barracks.sqf";
//[] execVM "aircraftSpawn.sqf";
[] execVM "vehicleCenter.sqf";

// Inicializar funciones globales de dinero
TPR_fnc_addMoney = {
    params ["_player", "_amount"];
    private _currentMoney = _player getVariable ["dinero", 0];
    _player setVariable ["dinero", _currentMoney + _amount, true];
};

TPR_fnc_getMoney = {
    params ["_player"];
    _player getVariable ["dinero", 0]
};

TPR_fnc_setMoney = {
    params ["_player", "_amount"];
    _player setVariable ["dinero", _amount, true];
};

if (isServer) then {
    // Sistema de jugadores - Dinero inicial unificado
    addMissionEventHandler ["PlayerConnected", {
        params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
        {
            if (isPlayer _x && {isNil {_x getVariable "dinero"}}) then {
                [_x, 50000] call TPR_fnc_setMoney;
            };
        } forEach allUnits;
    }];

    // Sistema de recompensas por eliminaciones
    addMissionEventHandler ["EntityKilled", {
        params ["_killed", "_killer", "_instigator"];
        
        if (isNull _instigator) then {
            _instigator = _killer;
        };
        
        private _className = typeOf _killed;
        if (side _killed == independent || side _killed == resistance || 
            (_className select [0, 2]) == "I_" || (_className select [0, 5]) == "CUP_I") then {
            
            private _playerToReward = objNull;
            private _reward = 0;
            
            // Determinar jugador a recompensar
            if (isPlayer _instigator) then {
                _playerToReward = _instigator;
            } else {
                private _groupLeader = leader group _instigator;
                if (isPlayer _groupLeader) then {
                    _playerToReward = _groupLeader;
                };
            };
            
            // Calcular recompensa
            if (!isNull _playerToReward) then {
                _reward = switch true do {
                    case (_killed isKindOf "CAManBase"): {
                        if (leader (group _killed) == _killed) then {250} else {100}
                    };
                    case (_killed isKindOf "Tank"): {1000};
                    case (_killed isKindOf "Car"): {500};
                    default {300};
                };
                
                [_playerToReward, _reward] call TPR_fnc_addMoney;
                
                private _message = if (_killed isKindOf "CAManBase") then {
                    format ["Enemigo eliminado: +%1$", _reward]
                } else {
                    format ["Vehículo enemigo destruido: +%1$", _reward]
                };
                
                [_message] remoteExec ["systemChat", _playerToReward];
            };
        };
    }];

    // Iniciar sistema de defensa guerrillero
    [] execVM "guerrilla_defense.sqf";
    
    // Marcar sistema como inicializado
    missionNamespace setVariable ["TPR_systemInitialized", true, true];
};

// Interfaz de usuario para el dinero
if (hasInterface) then {
    waitUntil {!isNull player && {missionNamespace getVariable ["TPR_systemInitialized", false]}};
    
    // Solo inicializar dinero si no existe
    if (isNil {player getVariable "dinero"}) then {
        [player, 50000] call TPR_fnc_setMoney;
    };
    
    // UI para mostrar dinero
    [] spawn {
        disableSerialization;
        while {true} do {
            if (isNull (uiNamespace getVariable ["MoneyDisplay", displayNull])) then {
                cutRsc ["MoneyDisplay", "PLAIN"];
            };
            
            private _display = uiNamespace getVariable "MoneyDisplay";
            if (!isNull _display) then {
                private _ctrl = _display displayCtrl 1100;
                if (!isNull _ctrl) then {
                    _ctrl ctrlSetText format ["Fondos: %1$", player getVariable ["dinero", 0]];
                };
            };
            sleep 1;
        };
    };
};

// Scripts generales al final

[] execVM "hc_system.sqf";
waitUntil {!isNil "HC_SYSTEM_INITIALIZED"};
diag_log "HC_SYSTEM cargado, continuando con otros sistemas...";


{
    [] execVM _x;
} forEach [
    "heliTransport.sqf",
    "wreckCleanup.sqf",
    "glt_ai_commander.sqf",
    "commsHub.sqf"
];