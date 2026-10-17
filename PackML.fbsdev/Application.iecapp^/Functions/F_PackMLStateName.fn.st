FUNCTION F_PackMLStateName : STRING(20)
VAR_INPUT
    eState : E_PackMLState;
END_VAR

CASE eState OF
    E_PackMLState.Clearing:     F_PackMLStateName := 'Clearing';
    E_PackMLState.Stopped:      F_PackMLStateName := 'Stopped';
    E_PackMLState.Starting:     F_PackMLStateName := 'Starting';
    E_PackMLState.Idle:         F_PackMLStateName := 'Idle';
    E_PackMLState.Suspended:    F_PackMLStateName := 'Suspended';
    E_PackMLState.Execute:      F_PackMLStateName := 'Execute';
    E_PackMLState.Stopping:     F_PackMLStateName := 'Stopping';
    E_PackMLState.Aborting:     F_PackMLStateName := 'Aborting';
    E_PackMLState.Aborted:      F_PackMLStateName := 'Aborted';
    E_PackMLState.Holding:      F_PackMLStateName := 'Holding';
    E_PackMLState.Held:         F_PackMLStateName := 'Held';
    E_PackMLState.UnHolding:    F_PackMLStateName := 'UnHolding';
    E_PackMLState.Suspending:   F_PackMLStateName := 'Suspending';
    E_PackMLState.UnSuspending: F_PackMLStateName := 'UnSuspending';
    E_PackMLState.Resetting:    F_PackMLStateName := 'Resetting';
    E_PackMLState.Completing:   F_PackMLStateName := 'Completing';
    E_PackMLState.Complete:     F_PackMLStateName := 'Complete';
ELSE
    F_PackMLStateName := 'Undefined';
END_CASE