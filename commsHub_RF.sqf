// Función para inicializar unidades RF
RF_fnc_initializeCommsHub = {
    params ["_building"];
    
    // Acción para comprar RF Sniper Team
    _building addAction [
        "<t color='#FFD700'>RF - Sniper Team (2.000$)</t>",
        {
            params ["_target", "_caller"];
            
            // Verificar edificio de reclutamiento
            private _recruitmentExists = false;
            {
                if (typeOf _x == "Land_Cargo_House_V1_F" && {alive _x && !isNil {_x getVariable "spawnPos"}}) exitWith {
                    _recruitmentExists = true;
                };
            } forEach nearestObjects [OPFOR_HQ, ["Building"], 200];
            
            if (!_recruitmentExists) exitWith {
                hint "Necesitas construir un Centro de Reclutamiento primero.";
            };
            
            private _cost = 2000;
            private _playerMoney = _caller getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                [_target, _caller, _cost] spawn {
                    params ["_target", "_caller", "_cost"];
                    
                    private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
                    private _group = createGroup [side _caller, true];
                    
                    // Crear unidades del Sniper Team
                    private _units = [
                        ["min_rf_sniper", "Lead Sniper"],
                        ["min_rf_sniper", "Sniper"]
                    ];
                    
                    {
                        _x params ["_class", "_role"];
                        private _unit = _group createUnit [_class, _spawnPos, [], 5, "NONE"];
                        _unit setVariable ["hcRole", _role, true];
                    } forEach _units;
                    
                    // Configurar grupo
                    _group selectLeader (units _group select 0);
                    _group setGroupId [format ["RF-SNP-%1", floor(random 1000)]];
                    
                    // Configurar HC
                    [_caller, _group, _spawnPos] call HC_fnc_setupGroup;
                    
                    // Cobrar y notificar
                    [_caller, -_cost] call TPR_fnc_addMoney;
                    hint format ["RF Sniper Team desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
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

    // Acción para comprar RF Rifle Squad
    _building addAction [
        "<t color='#FFD700'>RF - Rifle Squad (5.500$)</t>",
        {
            params ["_target", "_caller"];
            
            // Verificar edificio de reclutamiento
            private _recruitmentExists = false;
            {
                if (typeOf _x == "Land_Cargo_House_V1_F" && {alive _x && !isNil {_x getVariable "spawnPos"}}) exitWith {
                    _recruitmentExists = true;
                };
            } forEach nearestObjects [OPFOR_HQ, ["Building"], 200];
            
            if (!_recruitmentExists) exitWith {
                hint "Necesitas construir un Centro de Reclutamiento primero.";
            };
            
            private _cost = 5500;
            private _playerMoney = _caller getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                [_target, _caller, _cost] spawn {
                    params ["_target", "_caller", "_cost"];
                    
                    private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
                    private _group = createGroup [side _caller, true];
                    
                    // Squad completo
                    private _units = [
                        ["min_rf_soldier_SL", "Squad Leader"],
                        ["min_rf_soldier_TL", "Team Leader 1"],
                        ["min_rf_soldier_AR", "Automatic Rifleman 1"],
                        ["min_rf_soldier_LAT", "Light AT"],
                        ["CUP_O_RU_Soldier_MSV_EMR", "Assistant"],
                        ["min_rf_soldier_TL", "Team Leader 2"],
                        ["min_rf_soldier_AR", "Automatic Rifleman 2"],
                        ["min_rf_soldier_LAT", "Light AT"],
                        ["min_rf_medic", "Combat Medic"]
                    ];
                    
                    {
                        _x params ["_class", "_role"];
                        private _unit = _group createUnit [_class, _spawnPos, [], 5, "NONE"];
                        _unit setVariable ["hcRole", _role, true];
                    } forEach _units;
                    
                    _group selectLeader (units _group select 0);
                    _group setGroupId [format ["RF-SQD-%1", floor(random 1000)]];
                    
                    [_caller, _group, _spawnPos] call HC_fnc_setupGroup;
                    
                    [_caller, -_cost] call TPR_fnc_addMoney;
                    hint format ["RF Rifle Squad desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
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

    // Acción para comprar RF Heavy AT Team
    _building addAction [
        "<t color='#FFD700'>RF - Heavy AT Team (3.500$)</t>",
        {
            params ["_target", "_caller"];
            
            // Verificar edificio de reclutamiento
            private _recruitmentExists = false;
            {
                if (typeOf _x == "Land_Cargo_House_V1_F" && {alive _x && !isNil {_x getVariable "spawnPos"}}) exitWith {
                    _recruitmentExists = true;
                };
            } forEach nearestObjects [OPFOR_HQ, ["Building"], 200];
            
            if (!_recruitmentExists) exitWith {
                hint "Necesitas construir un Centro de Reclutamiento primero.";
            };
            
            private _cost = 3500;
            private _playerMoney = _caller getVariable ["dinero", 0];
            
            if (_playerMoney >= _cost) then {
                [_target, _caller, _cost] spawn {
                    params ["_target", "_caller", "_cost"];
                    
                    private _spawnPos = _target getVariable ["spawnPos", getPosATL _target];
                    private _group = createGroup [side _caller, true];
                    
                    // Equipo AT pesado
                    private _units = [
                        ["min_rf_soldier_TL", "Team Leader"],
                        ["min_rf_soldier_AT", "AT Specialist 1"],
                        ["min_rf_soldier_AT", "AT Specialist 2"],
                        ["min_rf_soldier_A", "Assistant"]
                    ];
                    
                    {
                        _x params ["_class", "_role"];
                        private _unit = _group createUnit [_class, _spawnPos, [], 5, "NONE"];
                        _unit setVariable ["hcRole", _role, true];
                    } forEach _units;
                    
                    _group selectLeader (units _group select 0);
                    _group setGroupId [format ["RF-HAT-%1", floor(random 1000)]];
                    
                    [_caller, _group, _spawnPos] call HC_fnc_setupGroup;
                    
                    [_caller, -_cost] call TPR_fnc_addMoney;
                    hint format ["RF Heavy AT Team desplegado. Fondos restantes: %1$", _caller getVariable ["dinero", 0]];
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