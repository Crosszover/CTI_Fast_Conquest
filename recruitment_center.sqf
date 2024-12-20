// recruitment_center.sqf
// Script para el Centro de Reclutamiento del TPR

// Función principal para inicializar el centro de reclutamiento
fnc_initializeRecruitmentCenter = {
    params ["_building"];
    
    // Título principal
    _building addAction [
        "<t color='#FF0000'>-- Centro de Reclutamiento TPR --</t>",
        "",
        [],
        1.6,
        true,
        false,
        "",
        "true",
        10
    ];
    
    // Personal de infantería
    _building addAction [
        "Contratar Fusilero TPR ($200)",
        "tdpShop.sqf",
        ["buy_rifleman_tdp"],
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
    
    _building addAction [
        "Contratar Fusilero Auto. TPR ($350)",
        "tdpShop.sqf",
        ["buy_ar_tdp"],
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
    
    _building addAction [
        "Contratar AT TPR ($300)",
        "tdpShop.sqf",
        ["buy_at_tdp"],
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
    
    _building addAction [
        "Contratar Ametrallador TPR ($450)",
        "tdpShop.sqf",
        ["buy_mg_tdp"],
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
    
    _building addAction [
        "Contratar Médico TPR ($400)",
        "tdpShop.sqf",
        ["buy_medic_tdp"],
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
    
    _building addAction [
        "Contratar Ingeniero TPR ($500)",
        "tdpShop.sqf",
        ["buy_engineer_tdp"],
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
    
    _building addAction [
        "Contratar Líder TPR ($600)",
        "tdpShop.sqf",
        ["buy_tl_tdp"],
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
    
    // Vehículos con sistema de preview
    _building addAction [
        "<t color='#FF0000'>Comprar UAZ TPR ($500)</t>",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_UAZ_Unarmed_RU", 500] call shop_fnc_startPreview;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
    
    _building addAction [
        "<t color='#FF0000'>Comprar Camión V3S TPR ($1.000)</t>",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_V3S_Open_NAPA", 1000] call shop_fnc_startPreview;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
    
    _building addAction [
        "<t color='#FF0000'>Comprar BTR-60 TPR ($4.000)</t>",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_BTR60_Green_RU", 4000] call shop_fnc_startPreview;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "true",
        10
    ];
    
    _building addAction [
        "<t color='#FF0000'>Comprar T-55 TPR ($8.000)</t>",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_T55_CHDKZ", 8000] call shop_fnc_startPreview;
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

// Función para limpiar las acciones del edificio si es necesario
fnc_cleanupRecruitmentCenter = {
    params ["_building"];
    {
        _building removeAction _x;
    } forEach (actionIDs _building);
};

// Función para verificar si un edificio es válido para ser centro de reclutamiento
fnc_isValidRecruitmentCenter = {
    params ["_building"];
    if (isNull _building) exitWith {false};
    if (damage _building >= 0.9) exitWith {false};
    true
};

// Función para inicializar el sistema del centro de reclutamiento
fnc_initRecruitmentSystem = {
    params ["_building"];
    if !([_building] call fnc_isValidRecruitmentCenter) exitWith {
        systemChat "Error: Edificio no válido para Centro de Reclutamiento";
        false
    };
    [_building] call fnc_cleanupRecruitmentCenter;
    [_building] call fnc_initializeRecruitmentCenter;
    true
};

// Exportar las funciones necesarias para uso en otros scripts
recruitment_fnc_initialize = fnc_initializeRecruitmentCenter;
recruitment_fnc_cleanup = fnc_cleanupRecruitmentCenter;
recruitment_fnc_isValid = fnc_isValidRecruitmentCenter;
recruitment_fnc_initSystem = fnc_initRecruitmentSystem;