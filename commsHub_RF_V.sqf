// Función para inicializar vehículos RF
RF_fnc_initializeVehicleCommsHub = {
    params ["_building"];
    
    // Acción para comprar RF GAZ HMG
    _building addAction [
        "<t color='#FFD700'>RF - GAZ HMG (3.000$)</t>",
        {
            params ["_target", "_caller"];
            
            // Verificar centro de vehículos
            private _hasVehicleCenter = false;
            {
                if (typeOf _x == "Land_Addon_05_F" && {alive _x && !isNil {_x getVariable "spawnPos"}}) then {
                    _hasVehicleCenter = true;
                };
            } forEach nearestObjects [OPFOR_HQ, ["Building"], 200];
            
            if (!_hasVehicleCenter) exitWith {
                hint "Necesitas construir un Centro de Vehículos primero.";
            };
            
            private _cost = 3000;
            private _playerMoney = _caller getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                [_target, _caller, _cost] spawn {
                    params ["_target", "_caller", "_cost"];
                    
                    private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
                    private _group = createGroup [side _caller, true];
                    
                    // Crear el vehículo
                    private _veh = "min_rf_gaz_2330_HMG" createVehicle _spawnPos;
                    
                    // Crear tripulación
                    private _driver = _group createUnit ["CUP_O_RU_Crew", _spawnPos, [], 5, "NONE"];
                    _driver moveInDriver _veh;
                    _driver setVariable ["hcRole", "Driver", true];
                    
                    private _gunner = _group createUnit ["CUP_O_RU_Crew", _spawnPos, [], 5, "NONE"];
                    _gunner moveInGunner _veh;
                    _gunner setVariable ["hcRole", "Gunner", true];
                    
                    // Configurar grupo
                    _group selectLeader _driver;
                    _group setGroupId [format ["RF-GAZ-%1", floor(random 1000)]];
                    
                    [_caller, _group, _spawnPos] call HC_fnc_setupGroup;
                    
                    [_caller, -_cost] call TPR_fnc_addMoney;
                    hint format ["RF GAZ HMG desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
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

    // Acción para comprar Camión de Transporte
    _building addAction [
        "<t color='#FFD700'>RF - Camión Transporte (800$)</t>",
        {
            params ["_target", "_caller"];
            
            private _hasVehicleCenter = false;
            {
                if (typeOf _x == "Land_Addon_05_F" && {alive _x && !isNil {_x getVariable "spawnPos"}}) then {
                    _hasVehicleCenter = true;
                };
            } forEach nearestObjects [OPFOR_HQ, ["Building"], 200];
            
            if (!_hasVehicleCenter) exitWith {
                hint "Necesitas construir un Centro de Vehículos primero.";
            };
            
            private _cost = 800;
            private _playerMoney = _caller getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                [_target, _caller, _cost] spawn {
                    params ["_target", "_caller", "_cost"];
                    
                    private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
                    private _group = createGroup [side _caller, true];
                    
                    // Crear el vehículo
                    private _veh = "min_rf_truck_transport" createVehicle _spawnPos;
                    
                    // Crear conductor
                    private _driver = _group createUnit ["CUP_O_RU_Crew", _spawnPos, [], 5, "NONE"];
                    _driver moveInDriver _veh;
                    _driver setVariable ["hcRole", "Driver", true];
                    
                    // Configurar grupo
                    _group selectLeader _driver;
                    _group setGroupId [format ["RF-TRK-%1", floor(random 1000)]];
                    
                    [_caller, _group, _spawnPos] call HC_fnc_setupGroup;
                    
                    [_caller, -_cost] call TPR_fnc_addMoney;
                    hint format ["RF Camión desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
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

    // Acción para comprar AA
    _building addAction [
        "<t color='#FFD700'>RF - AA SA-22 (30.000$)</t>",
        {
            params ["_target", "_caller"];
            
            private _hasVehicleCenter = false;
            {
                if (typeOf _x == "Land_Addon_05_F" && {alive _x && !isNil {_x getVariable "spawnPos"}}) then {
                    _hasVehicleCenter = true;
                };
            } forEach nearestObjects [OPFOR_HQ, ["Building"], 200];
            
            if (!_hasVehicleCenter) exitWith {
                hint "Necesitas construir un Centro de Vehículos primero.";
            };
            
            private _cost = 30000;
            private _playerMoney = _caller getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                [_target, _caller, _cost] spawn {
                    params ["_target", "_caller", "_cost"];
                    
                    private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
                    private _group = createGroup [side _caller, true];
                    
                    // Crear el vehículo
                    private _veh = "min_rf_sa_22" createVehicle _spawnPos;
                    
                    // Crear tripulación
                    private _driver = _group createUnit ["CUP_O_RU_Crew", _spawnPos, [], 5, "NONE"];
                    _driver moveInDriver _veh;
                    _driver setVariable ["hcRole", "Driver", true];
                    
                    private _gunner = _group createUnit ["CUP_O_RU_Crew", _spawnPos, [], 5, "NONE"];
                    _gunner moveInGunner _veh;
                    _gunner setVariable ["hcRole", "Gunner", true];
                    
                    // Configurar grupo
                    _group selectLeader _driver;
                    _group setGroupId [format ["RF-AA-%1", floor(random 1000)]];
                    
                    [_caller, _group, _spawnPos] call HC_fnc_setupGroup;
                    
                    [_caller, -_cost] call TPR_fnc_addMoney;
                    hint format ["RF SA-22 desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
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

    // Acción para comprar BMP-2
    _building addAction [
        "<t color='#FFD700'>RF - BMP-2 (12.000$)</t>",
        {
            params ["_target", "_caller"];
            
            private _hasVehicleCenter = false;
            {
                if (typeOf _x == "Land_Addon_05_F" && {alive _x && !isNil {_x getVariable "spawnPos"}}) then {
                    _hasVehicleCenter = true;
                };
            } forEach nearestObjects [OPFOR_HQ, ["Building"], 200];
            
            if (!_hasVehicleCenter) exitWith {
                hint "Necesitas construir un Centro de Vehículos primero.";
            };
            
            private _cost = 12000;
            private _playerMoney = _caller getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                [_target, _caller, _cost] spawn {
                    params ["_target", "_caller", "_cost"];
                    
                    private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
                    private _group = createGroup [side _caller, true];
                    
                    // Crear el vehículo
                    private _veh = "CUP_O_BMP2_RU" createVehicle _spawnPos;
                    
                    // Crear tripulación
                    private _driver = _group createUnit ["min_rf_crew", _spawnPos, [], 5, "NONE"];
                    _driver moveInDriver _veh;
                    _driver setVariable ["hcRole", "Driver", true];
                    
                    private _commander = _group createUnit ["min_rf_crew", _spawnPos, [], 5, "NONE"];
                    _commander moveInCommander _veh;
                    _commander setVariable ["hcRole", "Commander", true];
                    
                    private _gunner = _group createUnit ["min_rf_crew", _spawnPos, [], 5, "NONE"];
                    _gunner moveInGunner _veh;
                    _gunner setVariable ["hcRole", "Gunner", true];
                    
                    // Configurar grupo
                    _group selectLeader _commander;
                    _group setGroupId [format ["RF-BMP-%1", floor(random 1000)]];
                    
                    [_caller, _group, _spawnPos] call HC_fnc_setupGroup;
                    
                    [_caller, -_cost] call TPR_fnc_addMoney;
                    hint format ["RF BMP-2 desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
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

    // Acción para comprar T-72
    _building addAction [
        "<t color='#FFD700'>RF - T-72 (15.000$)</t>",
        {
            params ["_target", "_caller"];
            
            private _hasVehicleCenter = false;
            {
                if (typeOf _x == "Land_Addon_05_F" && {alive _x && !isNil {_x getVariable "spawnPos"}}) then {
                    _hasVehicleCenter = true;
                };
            } forEach nearestObjects [OPFOR_HQ, ["Building"], 200];
            
            if (!_hasVehicleCenter) exitWith {
                hint "Necesitas construir un Centro de Vehículos primero.";
            };
            
            private _cost = 15000;
            private _playerMoney = _caller getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                [_target, _caller, _cost] spawn {
                    params ["_target", "_caller", "_cost"];
                    
                    private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
                    private _group = createGroup [side _caller, true];
                    
                    // Crear el vehículo
                    private _veh = "CUP_O_T72_RU" createVehicle _spawnPos;
                    
                    // Crear tripulación
                    private _driver = _group createUnit ["min_rf_crew", _spawnPos, [], 5, "NONE"];
                    _driver moveInDriver _veh;
                    _driver setVariable ["hcRole", "Driver", true];
                    
                    private _commander = _group createUnit ["min_rf_crew", _spawnPos, [], 5, "NONE"];
                    _commander moveInCommander _veh;
                    _commander setVariable ["hcRole", "Commander", true];
                    
                    private _gunner = _group createUnit ["min_rf_crew", _spawnPos, [], 5, "NONE"];
                    _gunner moveInGunner _veh;
                    _gunner setVariable ["hcRole", "Gunner", true];
                    
                    // Configurar grupo
                    _group selectLeader _commander;
                    _group setGroupId [format ["RF-TNK-%1", floor(random 1000)]];
                    
                    [_caller, _group, _spawnPos] call HC_fnc_setupGroup;
                    
                    [_caller, -_cost] call TPR_fnc_addMoney;
                    hint format ["RF T-72 desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
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



	// Acción para comprar T-90
	_building addAction [
		"<t color='#FFD700'>RF - T-90 (20.000$)</t>",
		{
			params ["_target", "_caller"];
			
			private _hasVehicleCenter = false;
			{
				if (typeOf _x == "Land_Addon_05_F" && {alive _x && !isNil {_x getVariable "spawnPos"}}) then {
					_hasVehicleCenter = true;
				};
			} forEach nearestObjects [OPFOR_HQ, ["Building"], 200];
			
			if (!_hasVehicleCenter) exitWith {
				hint "Necesitas construir un Centro de Vehículos primero.";
			};
			
			private _cost = 20000;
			private _playerMoney = _caller getVariable ["dinero", 0];
			
			if (_playerMoney >= _cost) then {
				[_target, _caller, _cost] spawn {
					params ["_target", "_caller", "_cost"];
					
					private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
					private _group = createGroup [side _caller, true];
					
					// Crear el vehículo
					private _veh = "CUP_O_T90_RU" createVehicle _spawnPos;
					
					// Crear tripulación
					private _driver = _group createUnit ["min_rf_crew", _spawnPos, [], 5, "NONE"];
					_driver moveInDriver _veh;
					_driver setVariable ["hcRole", "Driver", true];
					
					private _commander = _group createUnit ["min_rf_crew", _spawnPos, [], 5, "NONE"];
					_commander moveInCommander _veh;
					_commander setVariable ["hcRole", "Commander", true];
					
					private _gunner = _group createUnit ["min_rf_crew", _spawnPos, [], 5, "NONE"];
					_gunner moveInGunner _veh;
					_gunner setVariable ["hcRole", "Gunner", true];
					
					// Configurar grupo
					_group selectLeader _commander;
					_group setGroupId [format ["RF-T90-%1", floor(random 1000)]];
					
					[_caller, _group, _spawnPos] call HC_fnc_setupGroup;
					
					[_caller, -_cost] call TPR_fnc_addMoney;
					hint format ["RF T-90 desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
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
};
