// vehicleCenter.sqf

// Función principal para inicializar el centro de vehículos
fnc_initializeVehicleCenter = {
    params ["_building"];
    
    // Título principal
    _building addAction [
        "<t color='#FF8C00'>-- Centro de Vehículos TPR --</t>",
        "",
        [],
        10.0,
        true,
        false,
        "",
        "true",
        15
    ];
    
    // Reconstrucción de HQ (solo visible si está destruido)
    _building addAction [
        "<t color='#ff0000'>-- Reconstrucción de Emergencia --</t>",
        "",
        [],
        9.5,
        true,
        false,
        "",
        "!alive OPFOR_HQ",
        15
    ];
    

	// Modificar la acción de "HQ BTR-90" en vehicleCenter.sqf
	_building addAction [
		"HQ BTR-90 ($10.000)",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			
			if (!isNull OPFOR_HQ && {alive OPFOR_HQ}) exitWith {
				hint "El HQ actual aún está operativo. No se necesita reconstruir.";
			};
			
			private _fnc_onVehicleCreated = {
				params ["_newHQ"];
				
				// Eliminar el HQ destruido si existe
				if (!isNull OPFOR_HQ) then {
					deleteVehicle OPFOR_HQ;
				};
				
				// Configurar el nuevo HQ
				missionNamespace setVariable ["OPFOR_HQ", _newHQ, true];
				_newHQ allowDamage true;
				
				// Crear nuevo marcador de respawn
				deleteMarker "respawn_east";
				private _marker = createMarker ["respawn_east", getPos _newHQ];
				_marker setMarkerType "respawn_inf";
				_marker setMarkerColor "ColorRed";
				
				// Añadir el menú de construcción
				[_newHQ] remoteExec ["fnc_agregarMenuConstruccion", 0, true];
				
				// Añadir el arsenal virtual
				[
					_newHQ,
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
				
				// Añadir Event Handlers al nuevo HQ
				[_newHQ] remoteExec ["fnc_addHQEventHandlers", 2];
				
				// Notificar a todos los jugadores
				["Nuevo HQ BTR-90 desplegado y operativo"] remoteExec ["hint", 0];
				
				// Actualizar el respawn
				"respawn_east" setMarkerPos (getPos _newHQ);
				
				// Verificar edificios operativos
				[] call fnc_verificarEdificiosOperativos;
			};
			
			["CUP_O_BTR90_HQ_RU", 10000, _fnc_onVehicleCreated] call shop_fnc_startPreview;
		},
		nil,
		9.4,
		true,
		true,
		"",
		"!alive OPFOR_HQ",
		15
	];
    
    // Estructuras
    _building addAction [
        "<t color='#00FF00'>-- Estructuras --</t>",
        "",
        [],
        9.0,
        true,
        false,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Helipad ($500)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["Land_HelipadSquare_F", 500] call shop_fnc_startPreview;
        },
        nil,
        8.9,
        true,
        true,
        "",
        "true",
        15
    ];
    
    // Transportes ligeros
    _building addAction [
        "<t color='#87CEEB'>-- Transportes Ligeros --</t>",
        "",
        [],
        8.0,
        true,
        false,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "GAZ ($1.500)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["min_rf_gaz_2330", 1500] call shop_fnc_startPreview;
        },
        nil,
        7.9,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "GAZ HMG ($3.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["min_rf_gaz_2330_HMG", 3000] call shop_fnc_startPreview;
        },
        nil,
        7.8,
        true,
        true,
        "",
        "true",
        15
    ];
    
    // Camiones Logísticos
    _building addAction [
        "<t color='#DEB887'>-- Camiones Logísticos --</t>",
        "",
        [],
        7.0,
        true,
        false,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Camión Transporte ($800)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["min_rf_truck_transport", 800] call shop_fnc_startPreview;
        },
        nil,
        6.9,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Camión Reparación ($4.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["min_rf_truck_box", 4000] call shop_fnc_startPreview;
        },
        nil,
        6.8,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Camión Combustible ($4.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["min_rf_truck_fuel", 4000] call shop_fnc_startPreview;
        },
        nil,
        6.7,
        true,
        true,
        "",
        "true",
        15
    ];
    
    // Helicópteros
    _building addAction [
        "<t color='#FFA500'>-- Helicópteros --</t>",
        "",
        [],
        6.0,
        true,
        false,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Mi-8 ($8.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_Mi8AMT_RU", 8000] call shop_fnc_startPreview;
        },
        nil,
        5.9,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Mi-24 ($15.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_Mi24_P_Dynamic_RU", 15000] call shop_fnc_startPreview;
        },
        nil,
        5.8,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "Ka-52 ($25.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_Ka52_RU", 25000] call shop_fnc_startPreview;
        },
        nil,
        5.7,
        true,
        true,
        "",
        "true",
        15
    ];
    
    // Artillería y AA
    _building addAction [
        "<t color='#FF4500'>-- Artillería y AA --</t>",
        "",
        [],
        5.0,
        true,
        false,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "GRAD ($30.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["min_rf_2b26", 30000] call shop_fnc_startPreview;
        },
        nil,
        4.9,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "AA ($30.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["min_rf_sa_22", 30000] call shop_fnc_startPreview;
        },
        nil,
        4.8,
        true,
        true,
        "",
        "true",
        15
    ];
    
    // APCs
    _building addAction [
        "<t color='#4169E1'>-- Vehículos Blindados --</t>",
        "",
        [],
        4.0,
        true,
        false,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "MTLB ($4.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_MTLB_pk_WDL_RU", 4000] call shop_fnc_startPreview;
        },
        nil,
        3.9,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "BTR-80A ($8.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_BTR80A_CAMO_RU", 8000] call shop_fnc_startPreview;
        },
        nil,
        3.8,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "BMP-2 ($12.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_BMP2_RU", 12000] call shop_fnc_startPreview;
        },
        nil,
        3.7,
        true,
        true,
        "",
        "true",
        15
    ];
    
    // Tanques
    _building addAction [
        "<t color='#8B0000'>-- Tanques --</t>",
        "",
        [],
        3.0,
        true,
        false,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "T-72 ($15.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_T72_RU", 15000] call shop_fnc_startPreview;
        },
        nil,
        2.9,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "T-90 ($20.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_T90_RU", 20000] call shop_fnc_startPreview;
        },
        nil,
        2.8,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "T-90M ($25.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["CUP_O_T90M_RU", 25000] call shop_fnc_startPreview;
        },
        nil,
        2.7,
        true,
        true,
        "",
        "true",
        15
    ];
    
    // Prototipos
    _building addAction [
        "<t color='#800080'>-- Prototipos --</t>",
        "",
        [],
        2.0,
        true,
        false,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "T-14 ($35.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["min_rf_t_14", 35000] call shop_fnc_startPreview;
        },
        nil,
        1.9,
        true,
        true,
        "",
        "true",
        15
    ];
    
    _building addAction [
        "T-15 ($35.000)",
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            ["min_rf_t_15", 35000] call shop_fnc_startPreview;
        },
        nil,
        1.8,
        true,
        true,
        "",
        "true",
        15
    ];
};

// Función para limpiar las acciones del edificio
fnc_cleanupVehicleCenter = {
    params ["_building"];
    {
        _building removeAction _x;
    } forEach (actionIDs _building);
};

// Función para verificar si un edificio es válido
fnc_isValidVehicleCenter = {
    params ["_building"];
    if (isNull _building) exitWith {false};
    if (damage _building >= 0.9) exitWith {false};
    true
};

// Función para inicializar el sistema
fnc_initVehicleCenterSystem = {
    params ["_building"];
    
    if !([_building] call fnc_isValidVehicleCenter) exitWith {
        systemChat "Error: Edificio no válido para Centro de Vehículos";
        false
    };
    
    [_building] call fnc_cleanupVehicleCenter;
    [_building] call fnc_initializeVehicleCenter;
    
    true
};

// Exportar las funciones necesarias
vehicleCenter_fnc_initialize = fnc_initializeVehicleCenter;
vehicleCenter_fnc_cleanup = fnc_cleanupVehicleCenter;
vehicleCenter_fnc_isValid = fnc_isValidVehicleCenter;
vehicleCenter_fnc_initSystem = fnc_initVehicleCenterSystem;