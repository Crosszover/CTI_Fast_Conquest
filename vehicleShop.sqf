// vehicleShop.sqf

// Variables globales
missionNamespace setVariable ["previewActive", false];
missionNamespace setVariable ["previewObject", objNull];
missionNamespace setVariable ["currentVehicleData", []];

// Función principal de spawn
fnc_spawnVehicle = {
    params ["_vehicleClass", "_price", ["_callback", {}]];
    
    // Limpiar preview anterior
    [] call fnc_cleanupPreview;
    
    // Guardar datos actuales incluyendo el callback
    missionNamespace setVariable ["currentVehicleData", [_vehicleClass, _price, _callback]];
    
    // Inicializar preview
    missionNamespace setVariable ["previewActive", true];
    private _pos = screenToWorld [0.5, 0.5];
    
    // Crear flecha de preview
    private _preview = "Sign_Arrow_F" createVehicle [0,0,0];
    _preview enableSimulation false;
    _preview allowDamage false;
    _preview setPos [_pos select 0, _pos select 1, 0.5];
    
    // Configurar preview
    _preview setObjectTexture [0, "#(argb,8,8,3)color(0,1,0,1)"];
    missionNamespace setVariable ["previewObject", _preview];
    
    // Iniciar sistema de preview
    [] spawn {
        while {missionNamespace getVariable ["previewActive", false]} do {
            private _preview = missionNamespace getVariable ["previewObject", objNull];
            if (!isNull _preview) then {
                // Actualizar posición
                private _pos = screenToWorld [0.5, 0.5];
                _pos set [2, 0.5];
                _preview setPos _pos;
                
                // Comprobar espacio para vehículo
                private _nearObjects = nearestObjects [_pos, ["LandVehicle", "Air", "Ship", "Building", "House"], 15];
                _nearObjects = _nearObjects - [_preview];
                private _hasCollision = count _nearObjects > 0;
                
                // Actualizar color de la flecha
                _preview setObjectTexture [0, if (_hasCollision) then {
                    "#(argb,8,8,3)color(1,0,0,1)"
                } else {
                    "#(argb,8,8,3)color(0,1,0,1)"
                }];
                
                // Rotación
                if (inputAction "AimLeft" > 0) then {
                    _preview setDir ((getDir _preview) + 2);
                };
                if (inputAction "AimRight" > 0) then {
                    _preview setDir ((getDir _preview) - 2);
                };
                
                // Mostrar información
                private _currentData = missionNamespace getVariable ["currentVehicleData", []];
                if (count _currentData > 0) then {
                    private _price = _currentData select 1;
                    hintSilent parseText format [
                        "<t size='1.2'>Colocación de Vehículo</t><br/><br/>" +
                        "Precio: %1$<br/><br/>" +
                        "<t color='%3'>ESPACIO - Confirmar</t><br/>" +
                        "Click Derecho - Cancelar<br/>" +
                        "A/D - Rotar<br/><br/>" +
                        "Estado: %2",
                        _price,
                        if (_hasCollision) then {"<t color='#ff0000'>Posición Bloqueada</t>"} else {"<t color='#00ff00'>Posición Válida</t>"},
                        if (_hasCollision) then {"#ff0000"} else {"#00ff00"}
                    ];
                };
            };
            sleep 0.01;
        };
    };
    
    // Configurar controles
    private _ehKeyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
        if !(missionNamespace getVariable ["previewActive", false]) exitWith {false};
        params ["", "_key"];
        
        if (_key == 57) then { // Espacio
            private _preview = missionNamespace getVariable ["previewObject", objNull];
            private _currentData = missionNamespace getVariable ["currentVehicleData", []];
            
            if (!isNull _preview && count _currentData >= 3) then {
                _currentData params ["_class", "_price", ["_callback", {}]];
                private _pos = getPos _preview;
                
                // Comprobar espacio
                private _nearObjects = nearestObjects [_pos, ["LandVehicle", "Air", "Ship", "Building", "House"], 15];
                _nearObjects = _nearObjects - [_preview];
                
                if (count _nearObjects == 0) then {
                    // Verificar fondos
                    private _playerMoney = player getVariable ["dinero", 0];
                    if (_playerMoney >= _price) then {
                        private _dir = getDir _preview;
                        
                        // Limpiar preview
                        deleteVehicle _preview;
                        missionNamespace setVariable ["previewObject", objNull];
                        
                        // Crear vehículo
                        private _vehicle = createVehicle [_class, _pos, [], 0, "NONE"];
                        _vehicle setDir _dir;
                        _vehicle setPos [_pos select 0, _pos select 1, 0.5];
                        _vehicle setVectorUp surfaceNormal position _vehicle;
                        
                        // Ejecutar callback si existe
                        if (!isNil "_callback") then {
                            [_vehicle] spawn _callback;
                        };
                        
                        // Limpiar inventario para vehículos específicos
                        if (_class in ["min_rf_truck_box", "min_rf_truck_fuel"]) then {
                            clearMagazineCargoGlobal _vehicle;
                            clearWeaponCargoGlobal _vehicle;
                            clearItemCargoGlobal _vehicle;
                            clearBackpackCargoGlobal _vehicle;
                        };
                        
                        // Actualizar dinero
                        player setVariable ["dinero", _playerMoney - _price, true];
                        systemChat format ["Vehículo comprado. Fondos restantes: %1$", _playerMoney - _price];
                        
                        [] call fnc_cleanupPreview;
                    } else {
                        systemChat format ["Fondos insuficientes. Necesitas: %1$", _price];
                    };
                } else {
                    systemChat "No se puede colocar el vehículo aquí - Hay obstáculos";
                };
            };
            true
        };
        false
    }];
    
    // Click derecho para cancelar
    private _ehMouseDown = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {
        if !(missionNamespace getVariable ["previewActive", false]) exitWith {false};
        params ["", "_button"];
        
        if (_button == 1) then {
            [] call fnc_cleanupPreview;
            systemChat "Compra cancelada";
            true
        };
        false
    }];
};

// Limpieza
fnc_cleanupPreview = {
    private _preview = missionNamespace getVariable ["previewObject", objNull];
    if (!isNull _preview) then {
        deleteVehicle _preview;
    };
    
    missionNamespace setVariable ["previewActive", false];
    missionNamespace setVariable ["previewObject", objNull];
    missionNamespace setVariable ["currentVehicleData", []];
    hintSilent "";
};

// Hacer pública la función principal
shop_fnc_startPreview = fnc_spawnVehicle;
publicVariable "shop_fnc_startPreview";