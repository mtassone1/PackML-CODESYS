FUNCTION F_PackMLIsActing : BOOL
VAR_INPUT
    eState : E_PackMLState;
END_VAR

F_PackMLIsActing :=
       eState = E_PackMLState.Clearing
    OR eState = E_PackMLState.Starting
    OR eState = E_PackMLState.Stopping
    OR eState = E_PackMLState.Aborting
    OR eState = E_PackMLState.Holding
    OR eState = E_PackMLState.UnHolding
    OR eState = E_PackMLState.Suspending
    OR eState = E_PackMLState.UnSuspending
    OR eState = E_PackMLState.Resetting
    OR eState = E_PackMLState.Completing;