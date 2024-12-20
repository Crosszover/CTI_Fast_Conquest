// Sistema de High Command
HC_SYSTEM_INITIALIZED = false;

// Variable para almacenar módulos disponibles por jugador
if (isNil "HC_SUB_MODULES") then {
    HC_SUB_MODULES = createHashMap;
};

// Función para crear pool de módulos subordinados
HC_fnc_createModulePool = {
    params ["_player", "_mainModule"];
    
    private _playerUID = getPlayerUID _player;
    private _modulePool = [];
    
    // Crear 10 módulos subordinados
    for "_i" from 1 to 10 do {
        private _subGroup = createGroup sideLogic;
        private _subModule = _subGroup createUnit ["HighCommandSubordinate", [0,0,0], [], 0, "NONE"];
        _mainModule synchronizeObjectsAdd [_subModule];
        _modulePool pushBack _subModule;
        
        diag_log format ["HC: Módulo subordinado %1 creado para jugador %2", _i, name _player];
    };
    
    // Almacenar el pool para este jugador
    HC_SUB_MODULES set [_playerUID, _modulePool];
    
    diag_log format ["HC: Pool de módulos creado para jugador %1", name _player];
};

// Función para obtener un módulo subordinado disponible
HC_fnc_getSubModule = {
    params ["_player"];
    
    private _playerUID = getPlayerUID _player;
    private _modulePool = HC_SUB_MODULES getOrDefault [_playerUID, []];
    
    if (count _modulePool > 0) then {
        private _module = _modulePool deleteAt 0;
        HC_SUB_MODULES set [_playerUID, _modulePool];
        diag_log format ["HC: Módulo subordinado asignado. Quedan %1 disponibles", count _modulePool];
        _module
    } else {
        diag_log format ["HC: ERROR - No hay módulos subordinados disponibles para %1", name _player];
        objNull
    }
};

// Función para obtener o crear el módulo HC principal
HC_fnc_getMainModule = {
    params ["_player"];
    
    private _existingModules = synchronizedObjects _player select {typeOf _x == "HighCommand"};
    if (count _existingModules > 0) exitWith {
        diag_log format ["HC: Usando módulo existente para %1", name _player];
        private _module = _existingModules select 0;
        
        // Si ya existe el módulo pero no hay pool, crearlo
        private _playerUID = getPlayerUID _player;
        if (count (HC_SUB_MODULES getOrDefault [_playerUID, []]) == 0) then {
            [_player, _module] call HC_fnc_createModulePool;
        };
        
        _module
    };
    
    diag_log format ["HC: Creando nuevo módulo para %1", name _player];
    private _group = createGroup sideLogic;
    private _module = _group createUnit ["HighCommand", [0,0,0], [], 0, "NONE"];
    _player synchronizeObjectsAdd [_module];
    
    // Crear pool inicial de módulos subordinados
    [_player, _module] call HC_fnc_createModulePool;
    
    _module
};

// Función corregida para configurar un grupo bajo HC
HC_fnc_setupGroup = {
    params ["_player", "_group", "_spawnPos"];
    
    // Asegurarnos de que existe el módulo principal
    private _mainModule = [_player] call HC_fnc_getMainModule;
    
    // Obtener módulo subordinado del pool
    private _subModule = [_player] call HC_fnc_getSubModule;
    
    if (!isNull _subModule) then {
        // Sincronización explícita con el módulo HC
        // Sincronizamos con el líder del grupo en lugar del grupo
        private _leader = leader _group;
        _subModule synchronizeObjectsAdd [_leader];
        _group setGroupOwner (owner _player);
        
        // Forzar la actualización del HC
        private _groups = hcAllGroups _player;
        _groups pushBackUnique _group;
        _player hcSetGroup [_group];
        
        // Verificación
        [_player, _group] spawn {
            params ["_player", "_group"];
            sleep 2;
            if (!isNull (hcLeader _group)) then {
                diag_log "HC: Grupo registrado correctamente";
                systemChat "Grupo añadido al High Command";
            } else {
                diag_log "HC: ERROR - Grupo no registrado";
                systemChat "Error al añadir grupo al High Command";
            };
        };
    } else {
        hint "Error: No hay módulos HC disponibles";
    };
};

// Función para crear un FireTeam
HC_fnc_createFireTeam = {
    params ["_player", "_spawnPos"];
    
    // Asegurarse de que existe el módulo principal y el pool
    [_player] call HC_fnc_getMainModule;
    
    private _group = createGroup [side _player, true];
    
    // Crear unidades básicas
    private _units = [
        ["CUP_O_RU_Soldier_TL_MSV_VSR93", "TL"],
        ["CUP_O_RU_Soldier_AR_MSV_VSR93", "AR"],
        ["CUP_O_RU_Soldier_AT_MSV_VSR93", "AT"],
        ["CUP_O_RU_Soldier_MSV_VSR93", "Rifleman"]
    ];
    
    {
        _x params ["_class", "_role"];
        private _unit = _group createUnit [_class, _spawnPos, [], 5, "NONE"];
        _unit setVariable ["hcRole", _role, true];
    } forEach _units;
    
    _group selectLeader (units _group select 0);
    _group setGroupId [format ["TPR-FT-%1", floor(random 1000)]];
    
    // Configurar HC
    [_player, _group, _spawnPos] call HC_fnc_setupGroup;
    
    _group
};

// Event handler para limpiar módulos cuando un jugador se desconecta
if (isServer) then {
    addMissionEventHandler ["PlayerDisconnected", {
        params ["_id", "_uid", "_name", "_jip", "_owner"];
        HC_SUB_MODULES deleteAt _uid;
        diag_log format ["HC: Módulos limpiados para jugador desconectado %1", _name];
    }];
};

// Inicialización
HC_SYSTEM_INITIALIZED = true;
diag_log "HC: Sistema inicializado";