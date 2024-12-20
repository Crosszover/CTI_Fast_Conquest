if (isServer) then {
    // Función para añadir el Event Handler al HQ
    fnc_addHQEventHandlers = {
        params ["_hq"];
        
        // Eliminar Event Handlers existentes si los hay
        private _ehKilled = _hq getVariable ["ehKilled", -1];
        if (_ehKilled != -1) then {
            _hq removeEventHandler ["Killed", _ehKilled];
        };
        
        // Añadir nuevo Event Handler para Killed
        private _newEhKilled = _hq addEventHandler ["Killed", {
            params ["_unit", "_killer"];
            
            // Eliminar el marcador de respawn principal
            deleteMarker "respawn_east";
            
            // Anunciar la destrucción
            ["El HQ ha sido destruido - Respawn principal eliminado"] remoteExec ["hint", 0];
            
            // Esperar un momento para asegurarse de que el objeto está realmente destruido
            [_unit] spawn {
                params ["_deadHQ"];
                sleep 1;
                
                // Verificar edificios existentes y funcionales
                private _edificiosDisponibles = (
                    allMissionObjects "Land_Cargo_House_V1_F" + 
                    allMissionObjects "Land_Cargo_HQ_V1_F" + 
                    allMissionObjects "Land_Addon_05_F"
                ) select {
                    alive _x && 
                    !isNil {_x getVariable "spawnPos"}
                };
                
                if (count _edificiosDisponibles == 0) then {
                    // No hay edificios de respaldo - Fin de la misión
                    ["OpforDerrota", false] remoteExec ["BIS_fnc_endMission", 0];
                } else {
                    // Informar de edificios restantes
                    [format ["Quedan %1 edificios operativos", count _edificiosDisponibles]] remoteExec ["hint", 0];
                };
            };
        }];
        
        // Guardar el ID del Event Handler
        _hq setVariable ["ehKilled", _newEhKilled];
        
        // Añadir un Event Handler para daño para monitoreo
        _hq addEventHandler ["Hit", {
            params ["_unit", "_source", "_damage", "_instigator"];
            systemChat format ["HQ recibió daño: %1 de %2", _damage, name _instigator];
        }];
    };
    
    // El resto del código del HQ...
    private _hqMarkers = allMapMarkers select {_x select [0, 7] == "hq_pos_"};
    if (count _hqMarkers > 0) then {
        private _selectedMarker = selectRandom _hqMarkers;
        private _newPos = getMarkerPos _selectedMarker;
        
        if (!isNil "OPFOR_HQ") then {
            OPFOR_HQ setPos _newPos;
            OPFOR_HQ setDir (random 360);
            
            // Configurar el Arsenal
            [
                OPFOR_HQ,
                [
                    "<t color='#800080'>Arsenal Virtual ($500)</t>",
                    {
                        params ["_target", "_caller"];
                        private _cost = 500;
                        private _playerMoney = player getVariable ["dinero", 0];
                        
                        if (_playerMoney >= _cost) then {
                            player setVariable ["dinero", _playerMoney - _cost, true];
                            ["Arsenal abierto - Coste: $500"] remoteExec ["systemChat", player];
                            ["Open", [true]] spawn BIS_fnc_arsenal;
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
                ]
            ] remoteExec ["addAction", 0, true];
            
            // Crear marcador de respawn principal
            deleteMarker "respawn_east";
            createMarker ["respawn_east", _newPos];
            "respawn_east" setMarkerType "respawn_inf";
            "respawn_east" setMarkerColor "ColorRed";
            
            {
                _x setMarkerAlpha 0;
            } forEach _hqMarkers;
            
            // Añadir Event Handlers al HQ
            [OPFOR_HQ] call fnc_addHQEventHandlers;
            
            systemChat "HQ desplegado en nueva posición";
        } else {
            systemChat "Error: OPFOR_HQ no encontrado";
        };
    } else {
        systemChat "Error: No se encontraron marcadores de HQ";
    };
};