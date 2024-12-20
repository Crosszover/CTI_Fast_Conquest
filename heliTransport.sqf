// Variables globales
if (isNil "taxiCanTakeOff") then {
    taxiCanTakeOff = false;
};

if (isNil "transporteActivo") then {
    transporteActivo = false;
};

// Función para manejar el comando de radio de forma segura
fnc_addTransportRadio = {
    // Primero removemos cualquier comando existente
    private _index = player getVariable ["transport_radio_id", -1];
    if (_index != -1) then {
        [player, _index] call BIS_fnc_removeCommMenuItem;
    };
    
    // Añadimos el nuevo comando y guardamos su ID
    private _newIndex = [player, "Support_Transport_Heli", nil, nil, ""] call BIS_fnc_addCommMenuItem;
    player setVariable ["transport_radio_id", _newIndex];
};

// Función mejorada para encontrar punto de aterrizaje seguro
fnc_findLandingZone = {
    params ["_pos"];
    
    // Intentar encontrar posición en radios cada vez mayores
    private _foundPos = [];
    private _radioBusqueda = 20;  // Radio inicial
    private _maxIntentos = 5;     // Número máximo de intentos
    private _intento = 0;
    
    while {_intento < _maxIntentos} do {
        _foundPos = [_pos, 0, _radioBusqueda, 10, 0, 0.2, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
        
        // Verificar si la posición es válida (no es la posición por defecto [0,0])
        if (!(_foundPos isEqualTo [0,0,0]) && !(_foundPos isEqualTo [0,0])) then {
            // Verificar si hay obstáculos en el área
            private _objetos = nearestObjects [_foundPos, ["House", "Building", "Tree", "Rock", "Wall"], 15];
            if (count _objetos == 0) exitWith {
                // Posición válida encontrada
                _foundPos set [2, getTerrainHeightASL _foundPos];
            };
        };
        
        // Aumentar el radio de búsqueda para el siguiente intento
        _radioBusqueda = _radioBusqueda + 30;
        _intento = _intento + 1;
    };
    
    // Si no se encontró posición válida, retornar la posición original
    if (_foundPos isEqualTo [0,0,0] || _foundPos isEqualTo [0,0]) then {
        _foundPos = _pos;
    };
    
    _foundPos
};

// Función para seleccionar waypoints en el mapa
fnc_mapclickhelo = {
    params ["_helo", "", "_actionID"];
    
    clicked = false;
    _helo removeAction _actionID;
    
    openMap true;
    
    titleText ["Marca un punto de aterrizaje.", "PLAIN DOWN"];
    hint "Haz click en el mapa para seleccionar el punto de aterrizaje";
    
    onMapSingleClick "ClickedPos = _pos; clicked = true;";
    
    waitUntil {clicked or !(visibleMap)};
    
    if (clicked) then {
        private _foundPickupPos = [ClickedPos] call fnc_findLandingZone;
        
        // Si la posición encontrada es la misma que la clickeada, significa que no se encontró lugar seguro
        if (_foundPickupPos isEqualTo ClickedPos) then {
            hint "No hay zona segura para aterrizar en esa área. Inténtalo en otro lugar.";
            _helo addAction ["<t color='#00ff00'>Dar órdenes al piloto</t>", fnc_mapclickhelo, "", 0, true, true, "", "vehicle _this == _target"];
        } else {
            ClickedTaxiPos = _foundPickupPos;
            taxiCanTakeOff = true;
            
            // Crear un helipad invisible en la posición encontrada
            if (!isNil "tempLandingPad") then {deleteVehicle tempLandingPad};
            tempLandingPad = createVehicle ["Land_HelipadEmpty_F", _foundPickupPos, [], 0, "NONE"];
            
            private _marker = createMarker ["landingZone", _foundPickupPos];
            _marker setMarkerType "hd_end";
            _marker setMarkerColor "ColorRed";
            _marker setMarkerText "LZ";
            
            titleText ["Destino confirmado. El piloto iniciará el despegue.", "PLAIN DOWN"];
            hint "Destino seleccionado - El piloto se dirige al punto marcado";
            systemChat "Piloto: Entendido, nos dirigimos al punto marcado.";
        };
    };
    
    onMapSingleClick "";
};

// Función para encontrar el helipad más cercano
fnc_findNearestHelipad = {
    params ["_pos"];
    private _helipads = nearestObjects [_pos, ["Land_HelipadEmpty_F", "Land_HelipadCircle_F", "Land_HelipadSquare_F"], 1000];
    if (count _helipads > 0) then {
        _helipads select 0
    } else {
        objNull
    };
};

// Función principal de transporte
TRANSPORT_fnc_requestTransport = {
    // Evitar múltiples solicitudes simultáneas
    if (transporteActivo) exitWith {
        hint "Ya hay un transporte en curso";
        systemChat "Base: Espera a que termine la misión actual de transporte";
    };
    
    transporteActivo = true;
    
    private _spawnPos = [getPos player, 2000, 2500, 10, 0, 0.2, 0] call BIS_fnc_findSafePos;
    _spawnPos set [2, 200];
    
    // Encontrar el helipad más cercano al jugador
    private _nearestPad = [getPos player] call fnc_findNearestHelipad;
    
    if (isNull _nearestPad) then {
        hint "No hay helipads cercanos. Construye uno primero.";
        systemChat "Base: Necesitas un helipad para solicitar transporte aéreo.";
        transporteActivo = false;
        [] call fnc_addTransportRadio; // Restauramos el comando si falla
    } else {
        hint "Transporte solicitado - Helicóptero en camino";
        systemChat "Base: Helicóptero de transporte respondiendo a tu solicitud. ETA 2 minutos.";
        
        private _helo = createVehicle ["CUP_O_Mi8AMT_RU", _spawnPos, [], 0, "FLY"];
        _helo setPos _spawnPos;
        
        private _grupo = createGroup [east, true];
        
        // Crear toda la tripulación
        private _piloto = _grupo createUnit ["CUP_O_RU_Pilot", _spawnPos, [], 0, "NONE"];
        private _copiloto = _grupo createUnit ["CUP_O_RU_Pilot", _spawnPos, [], 0, "NONE"];
        private _gunner1 = _grupo createUnit ["CUP_O_RU_Pilot", _spawnPos, [], 0, "NONE"];
        private _gunner2 = _grupo createUnit ["CUP_O_RU_Pilot", _spawnPos, [], 0, "NONE"];
        
        // Asignar tripulación a sus posiciones
        _piloto moveInDriver _helo;
        _copiloto moveInTurret [_helo, [0]];
        _gunner1 moveInTurret [_helo, [1]];
        _gunner2 moveInTurret [_helo, [2]];
        
        // Configurar comportamiento de toda la tripulación
        {
            _x setBehaviour "CARELESS";
            _x setCombatMode "BLUE";
            _x disableAI "TARGET";
            _x disableAI "AUTOTARGET";
            _x allowFleeing 0;
        } forEach units _grupo;
        
        private _heliMarker = createMarker ["heliTaxi", getPos _helo];
        _heliMarker setMarkerType "o_air";
        _heliMarker setMarkerColor "ColorRed";
        _heliMarker setMarkerText "Transporte";
        
        [_helo, _heliMarker] spawn {
            params ["_helo", "_marker"];
            while {alive _helo} do {
                _marker setMarkerPos (getPos _helo);
                sleep 1;
            };
            deleteMarker _marker;
        };
        
        _helo flyInHeight 40;
        _wp = _grupo addWaypoint [getPos _nearestPad, 0];
        _wp setWaypointType "MOVE";
        _wp setWaypointStatements ["true", "_veh = vehicle this; _veh land 'GET IN'"];
        
        _helo addAction ["<t color='#00ff00'>Dar órdenes al piloto</t>", fnc_mapclickhelo, "", 0, true, true, "", "vehicle _this == _target"];
        
        // Agregar EventHandler para cuando el helicóptero sea destruido
        _helo addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];
            transporteActivo = false;
            
            // Limpiar marcadores
            {
                if (_x find "heliTaxi" == 0 || _x find "landingZone" == 0) then {
                    deleteMarker _x;
                };
            } forEach allMapMarkers;
            
            // Eliminar helipad temporal si existe
            if (!isNil "tempLandingPad") then {
                deleteVehicle tempLandingPad;
            };
            
            hint "El helicóptero ha sido destruido";
            systemChat "Base: Hemos perdido contacto con el transporte";
            
            // Usar spawn para el sleep y el comando de radio
            [] spawn {
                sleep 5;
                [] call fnc_addTransportRadio;
            };
        }];
        
        [_helo, _grupo, _nearestPad] spawn {
            params ["_helo", "_grupo", "_helipad"];
            
            waitUntil {sleep 1; (!alive _helo) || {(getPos _helo) distance _helipad < 50}};
            
            if (alive _helo) then {
                _helo land "GET IN";
                
                hint "Transporte llegando - El helicóptero está aterrizando";
                systemChat "Piloto: Comenzando maniobras de aterrizaje.";
                
                waitUntil {sleep 1; (!alive _helo) || {vehicle player == _helo}};
                
                if (alive _helo) then {
                    waitUntil {sleep 1; taxiCanTakeOff};
                    
                    _helo land "NONE";
                    _helo flyInHeight 40;
                    
                    systemChat "Piloto: Iniciando despegue hacia el punto marcado.";
                    
                    private _wpFinal = _grupo addWaypoint [ClickedTaxiPos, 0];
                    _wpFinal setWaypointType "TR UNLOAD";
                    _wpFinal setWaypointBehaviour "CARELESS";
                    _wpFinal setWaypointSpeed "LIMITED";
                    _wpFinal setWaypointStatements ["true", "vehicle this land 'GET OUT'; vehicle this setVariable ['isLanding', true]"];
                    
                    waitUntil {sleep 1; (!alive _helo) || {(getPos _helo) distance ClickedTaxiPos < 50}};
                    
                    if (alive _helo) then {
                        _helo land "GET OUT";
                        _helo flyInHeight 0;
                        
                        // Asegurarnos de que realmente aterriza
                        _helo setVariable ["isLanding", true];
                        
                        systemChat "Piloto: Iniciando aterrizaje en el punto designado.";
                        
                        // Esperar a que realmente aterrice
                        waitUntil {
                            sleep 1;
                            (!alive _helo) || 
                            {(getPos _helo select 2) < 1} || 
                            {isTouchingGround _helo}
                        };
                        
                        if (alive _helo) then {
                            systemChat "Piloto: Hemos aterrizado. Pueden descender.";
                            
                            waitUntil {sleep 1; (!alive _helo) || {vehicle player != _helo}};
                            
                            private _timeoutTime = time + 30;
                            waitUntil {
                                sleep 1;
                                private _crew = crew _helo;
                                private _passengers = _crew - units _grupo;
                                private _noPassengers = (count _passengers) == 0;
                                _noPassengers || (time > _timeoutTime)
                            };
                            
                            systemChat "Piloto: Todos los pasajeros han descendido. Iniciando retorno a base.";
                            hint "Misión completada - El helicóptero regresa a base";
                            
                            _helo flyInHeight 40;
                            private _escapePos = [ClickedTaxiPos, 2000, random 360] call BIS_fnc_relPos;
                            _escapePos set [2, 300];
                            
                            while {(count (waypoints _grupo)) > 0} do {
                                deleteWaypoint ((waypoints _grupo) select 0);
                            };
                            
                            private _wpInitialClimb = _grupo addWaypoint [getPos _helo, 0];
                            _wpInitialClimb setWaypointType "MOVE";
                            _wpInitialClimb setWaypointSpeed "NORMAL";
                            
                            private _wpEscape = _grupo addWaypoint [_escapePos, 1];
                            _wpEscape setWaypointType "MOVE";
                            _wpEscape setWaypointSpeed "FULL";
                            
                            _grupo setCurrentWaypoint _wpInitialClimb;
                            
                            _helo doMove (getPos _helo);
                            sleep 3;
                            
                            _helo flyInHeight 300;
                            _helo doMove _escapePos;
                            
                            // Esperar a que el helicóptero se aleje lo suficiente
                            waitUntil {sleep 1; (!alive _helo) || {(getPos _helo) distance ClickedTaxiPos > 2000}};
                            
                            if (alive _helo) then {
                                // Limpieza completa
                                {
                                    deleteVehicle _x;
                                } forEach units _grupo;
                                
                                // Eliminar todos los marcadores relacionados
                                {
                                    if (_x find "heliTaxi" == 0 || _x find "landingZone" == 0) then {
                                        deleteMarker _x;
                                    };
                                } forEach allMapMarkers;
                                
                                // Eliminar el helipad temporal si existe
                                if (!isNil "tempLandingPad") then {
                                    deleteVehicle tempLandingPad;
                                };
                                
                                // Eliminar el helicóptero
                                deleteVehicle _helo;
                                
                                // Eliminar el grupo
                                deleteGroup _grupo;
                                
                                // Restablecer variables
                                transporteActivo = false;
                                
                                // Añadir nuevo comando de radio usando la función segura
                                [] call fnc_addTransportRadio;
                            };
                        };
                    };
                };
            };
        };
    };
};

// Añadir comando de radio al inicio usando la nueva función
if (hasInterface) then {
    waitUntil {!isNull player};
    [] call fnc_addTransportRadio;
};