// Definición de prefijos para los marcadores
#define GARRISON_CENTER_PREFIX "garrison_center_"
#define GARRISON_POINT_PREFIX "garrison_point_"
#define GARRISON_SPAWN_PREFIX "garrison_spawn_"
#define DEFAULT_VEHICLE "I_MBT_03_cannon_F"

fnc_isInTriangle = {
    params ["_point", "_triangle"];
    private ["_a", "_b", "_c"];
    _a = _triangle select 0;
    _b = _triangle select 1;
    _c = _triangle select 2;
    
    private _denominator = ((_b select 1) - (_c select 1)) * (_a select 0) + 
                          ((_c select 0) - (_b select 0)) * (_a select 1) + 
                          (_b select 0) * (_c select 1) - 
                          (_c select 0) * (_b select 1);
                          
    private _a1 = ((_b select 1) - (_c select 1)) * (_point select 0) + 
                  ((_c select 0) - (_b select 0)) * (_point select 1) + 
                  (_b select 0) * (_c select 1) - 
                  (_c select 0) * (_b select 1);
                  
    private _a2 = ((_c select 1) - (_a select 1)) * (_point select 0) + 
                  ((_a select 0) - (_c select 0)) * (_point select 1) + 
                  (_c select 0) * (_a select 1) - 
                  (_a select 0) * (_c select 1);
                  
    private _a3 = ((_a select 1) - (_b select 1)) * (_point select 0) + 
                  ((_b select 0) - (_a select 0)) * (_point select 1) + 
                  (_a select 0) * (_b select 1) - 
                  (_b select 0) * (_a select 1);
                  
    private _u1 = _a1 / _denominator;
    private _u2 = _a2 / _denominator;
    private _u3 = _a3 / _denominator;
    
    (_u1 >= 0) && (_u2 >= 0) && (_u3 >= 0)
};

fnc_findSafePos = {
    params ["_centerPos", "_radius", "_triangle"];
    private ["_pos", "_isValid", "_isEmpty"];
    
    for "_i" from 1 to 100 do {
        _pos = _centerPos getPos [random _radius, random 360];
        _isEmpty = _pos isFlatEmpty [
            10,    // Radio mínimo de espacio libre
            -1,    // Modo (-1 para comprobar todo)
            0.25,  // Gradiente máximo
            10,    // Radio máximo para gradiente
            0,     // Sobre agua (0: no)
            false,  // Orilla
            objNull // Objeto a ignorar
        ];
        
        _isValid = !(_isEmpty isEqualTo []) && 
                   [_pos, _triangle] call fnc_isInTriangle;
        
        if (_isValid) exitWith {_pos = _isEmpty select 0};
    };
    
    // Si no encontramos posición válida, intentamos más lejos
    if (!_isValid) then {
        for "_i" from 1 to 100 do {
            _pos = _centerPos getPos [_radius + random 50, random 360];
            _isEmpty = _pos isFlatEmpty [10, -1, 0.25, 10, 0, false, objNull];
            _isValid = !(_isEmpty isEqualTo []);
            
            if (_isValid) exitWith {_pos = _isEmpty select 0};
        };
    };
    
    if (!_isValid) then {_pos = _centerPos};
    _pos
};

fnc_initGarrison = {
    params [["_name", ""], ["_centerPos", [0,0,0]], ["_trianglePoints", []], ["_respawnMarker", ""]];
    
    private _garrisonData = createHashMap;
    _garrisonData set ["name", _name];
    _garrisonData set ["center", _centerPos];
    _garrisonData set ["perimeter", _trianglePoints];
    _garrisonData set ["respawn_point", _respawnMarker];
    _garrisonData set ["funds", 10000];
    _garrisonData set ["rifle_squads", []];
    _garrisonData set ["weapons_squad", grpNull];
    _garrisonData set ["support_squads", []];
    _garrisonData set ["active_contacts", []];
    _garrisonData set ["vehicle", objNull];
    _garrisonData set ["unitsSpawned", false];
    _garrisonData set ["controlStartTime", -1];
    _garrisonData set ["controllingFaction", independent];
    _garrisonData set ["pendingControl", independent];
    _garrisonData set ["lastOPFORCheck", 0];
    
    // Crear marcador de área
    private _areaMarker = createMarker [format ["area_%1", _name], _centerPos];
    _areaMarker setMarkerShape "ELLIPSE";
    _areaMarker setMarkerSize [400, 400];
    _areaMarker setMarkerColor "ColorGreen";
    _areaMarker setMarkerAlpha 0.5;
    _garrisonData set ["areaMarker", _areaMarker];
    
    // Sistema de ingresos
    [_garrisonData] spawn {
        params ["_data"];
        while {true} do {
            if (_data get "unitsSpawned") then {
                private _currentFunds = _data get "funds";
                _data set ["funds", _currentFunds + 1];
            };
            sleep 1;
        };
    };
    
    _garrisonData
};

fnc_createRifleSquad = {
    params ["_pos"];
    private _group = createGroup [independent, true];
    
    {
        _group createUnit [_x, _pos, [], 0, "NONE"];
    } forEach [
        "I_Soldier_TL_F",
        "I_Soldier_AR_F",
        "I_Soldier_LAT_F",
        "I_Soldier_GL_F",
        "I_Soldier_F",
        "I_medic_F"
    ];
    
    _group
};

fnc_createWeaponsSquad = {
    params ["_pos"];
    private _group = createGroup [independent, true];
    
    {
        _group createUnit [_x, _pos, [], 0, "NONE"];
    } forEach [
        "I_Soldier_SL_F",
        "I_Soldier_AR_F",
        "I_Soldier_MG_F",
        "I_Soldier_AT_F",
        "I_Soldier_AAT_F",
        "I_Soldier_M_F",
        "I_medic_F"
    ];
    
    _group
};

fnc_spawnGarrisonUnits = {
    params ["_garrisonData"];
    
    if (_garrisonData get "unitsSpawned") exitWith {};
    
    private _centerPos = _garrisonData get "center";
    private _trianglePoints = _garrisonData get "perimeter";
    
    // Crear escuadras de rifles
    {
        private _pos = [_x, 10, _trianglePoints] call fnc_findSafePos;
        private _squad = [_pos] call fnc_createRifleSquad;
        [_squad, _trianglePoints] call fnc_setupPatrols;
        [_squad, _garrisonData] call fnc_setupCombatDetection;
        (_garrisonData get "rifle_squads") pushBack _squad;
    } forEach _trianglePoints;
    
    // Crear escuadra de armas pesadas
    private _weaponsSquadPos = [_centerPos, 20, _trianglePoints] call fnc_findSafePos;
    private _weaponsSquad = [_weaponsSquadPos] call fnc_createWeaponsSquad;
    _garrisonData set ["weapons_squad", _weaponsSquad];
    [_weaponsSquad, _garrisonData] call fnc_setupCombatDetection;
    
    // Crear vehículo
    [_garrisonData] call fnc_createGarrisonVehicle;
    
    _garrisonData set ["unitsSpawned", true];
};

fnc_despawnGarrisonUnits = {
    params ["_garrisonData"];
    
    if !(_garrisonData get "unitsSpawned") exitWith {};
    
    // Eliminar escuadras de rifles
    {
        {deleteVehicle _x} forEach units _x;
        deleteGroup _x;
    } forEach (_garrisonData get "rifle_squads");
    _garrisonData set ["rifle_squads", []];
    
    // Eliminar escuadra de armas pesadas
    private _weaponsSquad = _garrisonData get "weapons_squad";
    if (!isNull _weaponsSquad) then {
        {deleteVehicle _x} forEach units _weaponsSquad;
        deleteGroup _weaponsSquad;
        _garrisonData set ["weapons_squad", grpNull];
    };
    
    // Eliminar vehículo
    private _vehicle = _garrisonData get "vehicle";
    if (!isNull _vehicle) then {
        {deleteVehicle _x} forEach crew _vehicle;
        deleteVehicle _vehicle;
        _garrisonData set ["vehicle", objNull];
    };
    
    _garrisonData set ["unitsSpawned", false];
};

fnc_respondToCombat = {
    params ["_garrisonData", "_attackPos"];
    
    // Obtener el weapons squad
    private _weaponsSquad = _garrisonData get "weapons_squad";
    
    if (!isNull _weaponsSquad && !(_weaponsSquad getVariable ["isResponding", false])) then {
        // Marcar que ya está respondiendo para evitar mensajes duplicados
        _weaponsSquad setVariable ["isResponding", true];
        
        // Cancelar waypoints actuales
        while {(count (waypoints _weaponsSquad)) > 0} do {
            deleteWaypoint ((waypoints _weaponsSquad) select 0);
        };
        
        // Crear nuevo waypoint en la posición del atacante
        private _wp = _weaponsSquad addWaypoint [_attackPos, 0];
        _wp setWaypointType "SAD";
        _wp setWaypointBehaviour "COMBAT";
        _wp setWaypointSpeed "FULL";
        _wp setWaypointFormation "WEDGE";
        
        // Crear waypoint de retorno al centro después de un tiempo
        private _centerPos = _garrisonData get "center";
        private _wpReturn = _weaponsSquad addWaypoint [_centerPos, 1];
        _wpReturn setWaypointType "MOVE";
        _wpReturn setWaypointBehaviour "SAFE";
        _wpReturn setWaypointSpeed "NORMAL";
        _wpReturn setWaypointStatements ["true", "
            (group this) setVariable ['isResponding', false];
            [group this, thisList] call fnc_setupPatrols;
        "];
        
        // Notificar a los jugadores (solo una vez)
        private _message = format ["Weapons Squad de %1 respondiendo a contacto enemigo!", _garrisonData get "name"];
        [_message] remoteExec ["systemChat", 0];
    };
};

fnc_checkGarrisonOPFORPresence = {
    params ["_garrisonData"];
    
    private _centerPos = _garrisonData get "center";
    private _nearUnits = _centerPos nearEntities [["Man", "LandVehicle"], 400];
    private _hasOPFOR = false;
    
    {
        if (side _x == east) exitWith {
            _hasOPFOR = true;
        };
    } forEach _nearUnits;
    
    if (_hasOPFOR && !(_garrisonData get "unitsSpawned")) then {
        [_garrisonData] call fnc_spawnGarrisonUnits;
        _garrisonData set ["lastOPFORCheck", time];
    } else {
        if (_garrisonData get "unitsSpawned") then {
            private _lastCheck = _garrisonData get "lastOPFORCheck";
            if (time - _lastCheck >= 900) then { // 15 minutos = 900 segundos
                if (!_hasOPFOR) then {
                    [_garrisonData] call fnc_despawnGarrisonUnits;
                } else {
                    _garrisonData set ["lastOPFORCheck", time];
                };
            };
        };
    };
};

fnc_checkGarrisonControl = {
    params ["_garrisonData"];
    
    private _centerPos = _garrisonData get "center";
    private _nearUnits = _centerPos nearEntities ["Man", 200];
    private _currentControl = _garrisonData get "controllingFaction";
    
    private _counts = createHashMap;
    _counts set [independent, 0];
    _counts set [east, 0];
    
    {
        private _side = side _x;
        if (_side in [independent, east]) then {
            _counts set [_side, (_counts get _side) + 1];
        };
    } forEach _nearUnits;
    
    private _independentCount = _counts get independent;
    private _eastCount = _counts get east;
    
    private _dominantSide = if (_eastCount > _independentCount) then {east} else {independent};
    
    if (_dominantSide != _currentControl) then {
        if (_garrisonData get "controlStartTime" == -1) then {
            _garrisonData set ["controlStartTime", time];
            _garrisonData set ["pendingControl", _dominantSide];
        } else {
            if ((_garrisonData get "pendingControl") != _dominantSide) then {
                _garrisonData set ["controlStartTime", time];
                _garrisonData set ["pendingControl", _dominantSide];
            } else {
                if (time - (_garrisonData get "controlStartTime") >= 300) then { // 5 minutos = 300 segundos
                    [_garrisonData, _dominantSide] call fnc_changeGarrisonControl;
                };
            };
        };
    } else {
        _garrisonData set ["controlStartTime", -1];
        _garrisonData set ["pendingControl", independent];
    };
};

fnc_changeGarrisonControl = {
    params ["_garrisonData", "_newSide"];
    
    private _name = _garrisonData get "name";
    private _marker = format ["marker_%1", _name];
    private _areaMarker = _garrisonData get "areaMarker";
    
    _garrisonData set ["controllingFaction", _newSide];
    
    if (_newSide == east) then {
        // Cambiar color del marcador
        _marker setMarkerColor "ColorRed";
        _areaMarker setMarkerColor "ColorRed";
        _marker setMarkerText format ["%1 (Capturada por OPFOR)", _name];
        
        // Sistema de ingresos pasivos
        [_garrisonData] spawn {
            params ["_data"];
            private _baseIncome = 60; // Ingreso base por minuto
            
            while {(_data get "controllingFaction") == east} do {
                private _players = allPlayers select {alive _x};
                if (count _players > 0) then {
                    private _sharePerPlayer = floor (_baseIncome / (count _players));
                    
                    {
                        private _currentMoney = _x getVariable ["dinero", 0];
                        _x setVariable ["dinero", _currentMoney + _sharePerPlayer, true];
                        
                        if ((floor time) mod 60 == 0) then { // Notificar cada minuto
                            private _message = format ["Ingresos de %1: +%2$ (compartido entre %3 jugadores)", 
                                _data get "name", 
                                _sharePerPlayer,
                                count _players
                            ];
                            [_message] remoteExec ["systemChat", _x];
                        };
                    } forEach _players;
                };
                sleep 60; // Actualizar cada minuto
            };
        };
    } else {
        _marker setMarkerColor "ColorGreen";
        _areaMarker setMarkerColor "ColorGreen";
        _marker setMarkerText format ["%1", _name];
    };
    
    // Notificar a todos los jugadores
    private _message = if (_newSide == east) then {
        format ["¡%1 ha sido capturada por OPFOR!", _name]
    } else {
        format ["¡%1 ha sido recuperada por la resistencia!", _name]
    };
    
    [_message] remoteExec ["systemChat", 0];
};

fnc_setupCombatDetection = {
    params ["_squad", "_garrisonData"];
    
    {
        _x addEventHandler ["FiredNear", {
            params ["_unit", "_shooter"];
            private _squad = group _unit;
            private _garrisonData = _unit getVariable "garrisonData";
            
            if (!(_squad getVariable ["inCombat", false])) then {
                _squad setVariable ["inCombat", true];
                _squad setVariable ["combatPos", getPos _shooter];
                
                [_garrisonData, getPos _shooter] call fnc_respondToCombat;
                
                [_squad] spawn {
                    params ["_squad"];
                    private _lastCombatTime = time;
                    
                    waitUntil {
                        sleep 30;
                        if (behaviour leader _squad == "COMBAT") then {
                            _lastCombatTime = time;
                        };
                        time > _lastCombatTime + 300
                    };
                    
                    _squad setVariable ["inCombat", false];
                };
            };
        }];
        _x setVariable ["garrisonData", _garrisonData];
    } forEach units _squad;
};

fnc_setupPatrols = {
    params ["_squad", "_points"];
    
    {
        private _wp = _squad addWaypoint [_x, _forEachIndex];
        _wp setWaypointType "MOVE";
        _wp setWaypointBehaviour "SAFE";
        _wp setWaypointSpeed "LIMITED";
    } forEach _points;
    
    private _wpCycle = _squad addWaypoint [_points select 0, count _points];
    _wpCycle setWaypointType "CYCLE";
};

fnc_createGarrisonVehicle = {
    params ["_garrisonData"];
    private _centerPos = _garrisonData get "center";
    private _spawnPos = [_centerPos, 50, _garrisonData get "perimeter"] call fnc_findSafePos;
    
    private _vehicle = createVehicle [DEFAULT_VEHICLE, _spawnPos, [], 0, "NONE"];
    private _group = createGroup [independent, true];
    
    {
        private _unit = _group createUnit ["I_crew_F", _spawnPos, [], 0, "NONE"];
        _unit moveInAny _vehicle;
    } forEach [1,2,3];
    
    [_group, _garrisonData get "perimeter"] call fnc_setupPatrols;
    _garrisonData set ["vehicle", _vehicle];
};

fnc_startGarrison = {
    params ["_name", "_centerPos", "_trianglePoints", "_respawnMarker"];
    
    private _garrisonData = [_name, _centerPos, _trianglePoints, _respawnMarker] call fnc_initGarrison;
    missionNamespace setVariable [format ["garrison_%1", _name], _garrisonData];
};

fnc_initGarrisonController = {
    private _controller = createHashMap;
    _controller set ["active_garrisons", []];
    
    [_controller] spawn fnc_monitorGarrisons;
    missionNamespace setVariable ["GARRISON_CONTROLLER", _controller];
};

fnc_monitorGarrisons = {
    params ["_controller"];
    
    while {true} do {
        {
            private _garrisonData = missionNamespace getVariable [format ["garrison_%1", _x], nil];
            if (!isNil "_garrisonData") then {
                // Primero comprobamos presencia OPFOR para spawn/despawn
                [_garrisonData] call fnc_checkGarrisonOPFORPresence;
                
                // Si las unidades están spawneadas, comprobamos control
                if (_garrisonData get "unitsSpawned") then {
                    [_garrisonData] call fnc_checkGarrisonControl;
                };
                
                // Actualizar marcadores
                [_garrisonData] call fnc_updateGarrisonMarkers;
            };
        } forEach (_controller get "active_garrisons");
        
        sleep 5;
    };
};

fnc_updateGarrisonMarkers = {
    params ["_garrisonData"];
    
    private _name = _garrisonData get "name";
    private _marker = format ["marker_%1", _name];
    private _controllingFaction = _garrisonData get "controllingFaction";
    
    if (_garrisonData get "unitsSpawned") then {
        private _rifleSquads = _garrisonData get "rifle_squads";
        private _weaponsSquad = _garrisonData get "weapons_squad";
        private _vehicle = _garrisonData get "vehicle";
        
        private _totalUnits = 0;
        {
            _totalUnits = _totalUnits + ({alive _x} count units _x);
        } forEach _rifleSquads;
        
        if (!isNull _weaponsSquad) then {
            _totalUnits = _totalUnits + ({alive _x} count units _weaponsSquad);
        };
        
        if (!isNull _vehicle && alive _vehicle) then {
            _totalUnits = _totalUnits + 1;
        };
        
        _marker setMarkerText format ["%1 (%2 unidades)", _name, _totalUnits];
    } else {
        _marker setMarkerText format ["%1 (Inactiva)", _name];
    };
};

fnc_initGarrisonsFromMarkers = {
    private _garrisonMarkers = allMapMarkers select {(_x select [0, count GARRISON_CENTER_PREFIX]) == GARRISON_CENTER_PREFIX};
    private _controller = missionNamespace getVariable ["GARRISON_CONTROLLER", nil];
    
    {
        private _centerMarker = _x;
        private _garrisonName = _centerMarker select [count GARRISON_CENTER_PREFIX];
        private _centerPos = getMarkerPos _centerMarker;
        
        private _perimeterPoints = [];
        for "_i" from 1 to 3 do {
            private _pointMarker = format ["%1%2_%3", GARRISON_POINT_PREFIX, _garrisonName, _i];
            if (_pointMarker in allMapMarkers) then {
                _perimeterPoints pushBack (getMarkerPos _pointMarker);
            };
        };
        
        private _spawnMarker = format ["%1%2", GARRISON_SPAWN_PREFIX, _garrisonName];
        private _spawnPoint = if (_spawnMarker in allMapMarkers) then {_spawnMarker} else {"respawn_guerrilla_01"};
        
        if (count _perimeterPoints == 3) then {
            [_garrisonName, _centerPos, _perimeterPoints, _spawnPoint] call fnc_startGarrison;
            (_controller get "active_garrisons") pushBack _garrisonName;
        } else {
            systemChat format ["Error: Faltan puntos del perímetro para la guarnición %1", _garrisonName];
        };
    } forEach _garrisonMarkers;
};

if (isServer) then {
    [] call fnc_initGarrisonController;
    [] call fnc_initGarrisonsFromMarkers;
};