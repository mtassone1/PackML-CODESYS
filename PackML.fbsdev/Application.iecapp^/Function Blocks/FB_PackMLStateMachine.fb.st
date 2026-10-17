FUNCTION_BLOCK FB_PackMLStateMachine
VAR_INPUT
    Cmd           : ST_PackMLCommands;
    ModeRequest   : E_PackMLMode;
    StateComplete : BOOL;      // pulse/rising edge from machine logic
END_VAR
VAR_OUTPUT
    Status        : ST_PackMLStatus;
END_VAR
VAR
    eState     : E_PackMLState := E_PackMLState.Stopped;
    eNext      : E_PackMLState;
    eMode      : E_PackMLMode  := E_PackMLMode.Producing;
    tEntry     : TIME;         // timestamp of last state entry
    bFirstScan : BOOL := TRUE;

    rtReset, rtStart, rtStop, rtHold, rtUnHold : R_TRIG;
    rtSuspend, rtUnSuspend, rtAbort, rtClear   : R_TRIG;
    rtComplete : R_TRIG;
END_VAR

// Edge detection (rising)
rtReset(CLK := Cmd.Reset);
rtStart(CLK := Cmd.Start);
rtStop(CLK := Cmd.Stop);
rtHold(CLK := Cmd.Hold);
rtUnHold(CLK := Cmd.UnHold);
rtSuspend(CLK := Cmd.Suspend);
rtUnSuspend(CLK := Cmd.UnSuspend);
rtAbort(CLK := Cmd.Abort);
rtClear(CLK := Cmd.Clear);
rtComplete(CLK := StateComplete);

IF bFirstScan THEN
    tEntry     := TIME();
    bFirstScan := FALSE;
END_IF

// Mode change (Stopped or Aborted)
IF (eState = E_PackMLState.Stopped OR eState = E_PackMLState.Aborted)
   AND ModeRequest <> E_PackMLMode.Undefined THEN
    eMode := ModeRequest;
END_IF

// logic
eNext := eState;

IF rtAbort.Q
   AND eState <> E_PackMLState.Aborted
   AND eState <> E_PackMLState.Aborting
   AND eState <> E_PackMLState.Clearing THEN
    eNext := E_PackMLState.Aborting;

ELSIF rtStop.Q
   AND eState <> E_PackMLState.Stopped
   AND eState <> E_PackMLState.Stopping
   AND eState <> E_PackMLState.Aborted
   AND eState <> E_PackMLState.Aborting
   AND eState <> E_PackMLState.Clearing THEN
    eNext := E_PackMLState.Stopping;

ELSE
    CASE eState OF
        E_PackMLState.Stopped:
            IF rtReset.Q THEN eNext := E_PackMLState.Resetting; END_IF

        E_PackMLState.Resetting:
            IF rtComplete.Q THEN eNext := E_PackMLState.Idle; END_IF

        E_PackMLState.Idle:
            IF rtStart.Q THEN eNext := E_PackMLState.Starting; END_IF

        E_PackMLState.Starting:
            IF rtComplete.Q THEN eNext := E_PackMLState.Execute; END_IF

        E_PackMLState.Execute:
            IF rtHold.Q THEN
                eNext := E_PackMLState.Holding;
            ELSIF rtSuspend.Q THEN
                eNext := E_PackMLState.Suspending;
            ELSIF rtComplete.Q THEN
                eNext := E_PackMLState.Completing;
            END_IF

        E_PackMLState.Holding:
            IF rtComplete.Q THEN eNext := E_PackMLState.Held; END_IF

        E_PackMLState.Held:
            IF rtUnHold.Q THEN eNext := E_PackMLState.UnHolding; END_IF

        E_PackMLState.UnHolding:
            IF rtComplete.Q THEN eNext := E_PackMLState.Execute; END_IF

        E_PackMLState.Suspending:
            IF rtComplete.Q THEN eNext := E_PackMLState.Suspended; END_IF

        E_PackMLState.Suspended:
            IF rtUnSuspend.Q THEN eNext := E_PackMLState.UnSuspending; END_IF

        E_PackMLState.UnSuspending:
            IF rtComplete.Q THEN eNext := E_PackMLState.Execute; END_IF

        E_PackMLState.Completing:
            IF rtComplete.Q THEN eNext := E_PackMLState.Complete; END_IF

        E_PackMLState.Complete:
            IF rtReset.Q THEN eNext := E_PackMLState.Resetting; END_IF

        E_PackMLState.Stopping:
            IF rtComplete.Q THEN eNext := E_PackMLState.Stopped; END_IF

        E_PackMLState.Aborting:
            IF rtComplete.Q THEN eNext := E_PackMLState.Aborted; END_IF

        E_PackMLState.Aborted:
            IF rtClear.Q THEN eNext := E_PackMLState.Clearing; END_IF

        E_PackMLState.Clearing:
            IF rtComplete.Q THEN eNext := E_PackMLState.Stopped; END_IF
    END_CASE
END_IF

// Apply
Status.StateChanged := FALSE;
IF eNext <> eState THEN
    eState              := eNext;
    tEntry              := TIME();
    Status.StateChanged := TRUE;
END_IF

// Publish
Status.State     := eState;
Status.Mode      := eMode;
Status.StateName := F_PackMLStateName(eState);
Status.StateTime := TIME() - tEntry;
Status.IsActing  := F_PackMLIsActing(eState);
Status.IsWaiting := NOT Status.IsActing;