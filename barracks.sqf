// barracks.sqf - Sistema de barracas

// Función para comprar una unidad
fnc_buyBarracksUnit = {
    params ["_building", "_unitClass", "_price"];
    
    private _playerMoney = player getVariable ["dinero", 0];
    systemChat format ["Intentando reclutar: %1 por %2$", _unitClass, _price];
    
    if (_playerMoney >= _price) then {
        private _success = [_unitClass, _building] call shop_fnc_spawnUnit;
        
        if (_success) then {
            player setVariable ["dinero", _playerMoney - _price, true];
            systemChat format ["Unidad reclutada. Fondos restantes: %1$", player getVariable "dinero"];
        };
    } else {
        systemChat format ["Fondos insuficientes. Necesitas: %1$", _price];
    };
};

// Función principal para inicializar el cuartel
fnc_initializeBarracks = {
    params ["_building"];
    
    // Título principal
    _building addAction [
        "<t color='#0000FF'>-- Cuartel TPR --</t>",
        "",
        [],
        1.6,
        true,
        false,
        "",
        "true",
        15
    ];
    
    // Infantería básica
    _building addAction [
        "Reclutar Fusilero ($500)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_soldier", 500] call fnc_buyBarracksUnit;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Reclutar Anti-tanque Ligero ($600)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_soldier_LAT", 600] call fnc_buyBarracksUnit;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Reclutar Granadero ($700)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_soldier_GL", 700] call fnc_buyBarracksUnit;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    // Infantería especializada
    _building addAction [
        "Reclutar Líder de Equipo ($1200)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_soldier_TL", 1200] call fnc_buyBarracksUnit;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Reclutar Tirador ($1000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_soldier_M", 1000] call fnc_buyBarracksUnit;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Reclutar Ametrallador ($1100)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_soldier_AR", 1100] call fnc_buyBarracksUnit;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Reclutar Anti-tanque Pesado ($1300)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_soldier_AT", 1300] call fnc_buyBarracksUnit;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Reclutar Médico ($1000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_medic", 1000] call fnc_buyBarracksUnit;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Reclutar Piloto ($1400)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_pilot", 1400] call fnc_buyBarracksUnit;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Reclutar Anti-aéreo ($1300)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_soldier_AA", 1300] call fnc_buyBarracksUnit;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Reclutar Fusilero Automático ($1100)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_soldier_AR", 1100] call fnc_buyBarracksUnit;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Reclutar Tripulación ($300)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, "min_rf_crew", 300] call fnc_buyBarracksUnit;
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

// Función para limpiar las acciones del edificio
fnc_cleanupBarracks = {
    params ["_building"];
    {
        _building removeAction _x;
    } forEach (actionIDs _building);
};

// Función para verificar si un edificio es válido para ser cuartel
fnc_isValidBarracks = {
    params ["_building"];
    if (isNull _building) exitWith {false};
    if (damage _building >= 0.9) exitWith {false};
    true
};

// Función para inicializar el sistema del cuartel
fnc_initBarracksSystem = {
    params ["_building"];
    
    if !([_building] call fnc_isValidBarracks) exitWith {
        systemChat "Error: Edificio no válido para Cuartel";
        false
    };
    
    [_building] call fnc_cleanupBarracks;
    [_building] call fnc_initializeBarracks;
    
    true
};

// Exportar las funciones
barracks_fnc_initialize = fnc_initializeBarracks;
barracks_fnc_cleanup = fnc_cleanupBarracks;
barracks_fnc_isValid = fnc_isValidBarracks;
barracks_fnc_initSystem = fnc_initBarracksSystem;