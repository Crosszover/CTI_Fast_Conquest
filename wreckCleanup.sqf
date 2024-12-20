// wreckCleanup.sqf
// Script para eliminar restos de vehículos destruidos después de un tiempo específico.

private _wreckList = []; // Lista de restos a monitorear
private _cleanupTime = 60; // Tiempo en segundos antes de eliminar los restos

while {true} do {
    // Encuentra todos los restos de vehículos en el mapa
    _wreckList = (allDead + allMissionObjects "CarWreck") select {alive _x && _x isKindOf "Car" || _x isKindOf "Tank"};

    // Elimina los restos después del tiempo especificado
    {
        private _wreck = _x;
        if (!alive _wreck) then {
            sleep _cleanupTime; // Espera antes de eliminar el resto

            // Comprueba si sigue sin estar vivo y si sigue siendo un resto humeante
            if (!alive _wreck && _wreck getVariable ["wrecked", true]) then {
                deleteVehicle _wreck; // Elimina el resto
                diag_log format ["Restos eliminados: %1", _wreck];
            };
        };
    } forEach _wreckList;

    sleep 5; // Pausa antes de la siguiente verificación
};
