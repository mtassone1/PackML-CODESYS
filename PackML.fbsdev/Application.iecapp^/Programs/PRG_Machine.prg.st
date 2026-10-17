PROGRAM PRG_Machine
VAR
    fbPackML       : FB_PackMLStateMachine;
    stClear        : ST_PackMLCommands;   // all FALSE
    bStateComplete : BOOL;
    tonItem        : TON;
    nProduced      : UDINT;
    nBatchSize     : UDINT := 10;
    bAutoDemo      : BOOL := TRUE;
    bHoldDone      : BOOL;
END_VAR

// Auto-demo
IF bAutoDemo AND fbPackML.Status.StateTime >= T#3S THEN
    CASE fbPackML.Status.State OF
        E_PackMLState.Stopped:  GVL_PackML.Cmd.Reset  := TRUE;
        E_PackMLState.Idle:     GVL_PackML.Cmd.Start  := TRUE;
        E_PackMLState.Held:     GVL_PackML.Cmd.UnHold := TRUE;
        E_PackMLState.Complete: GVL_PackML.Cmd.Reset  := TRUE;
    END_CASE
END_IF

IF bAutoDemo AND fbPackML.Status.State = E_PackMLState.Execute
   AND nProduced = 5 AND NOT bHoldDone THEN
    GVL_PackML.Cmd.Hold := TRUE;
    bHoldDone := TRUE;
END_IF
IF fbPackML.Status.State = E_PackMLState.Resetting THEN
    bHoldDone := FALSE;
END_IF

// State Machine
fbPackML(Cmd           := GVL_PackML.Cmd,
         ModeRequest   := GVL_PackML.ModeRequest,
         StateComplete := bStateComplete);
GVL_PackML.Status := fbPackML.Status;

// Auto-clear commands
GVL_PackML.Cmd := stClear;

// Machine behaviour
bStateComplete := FALSE;

// Simulate 2 s of work and completion
IF fbPackML.Status.IsActing AND fbPackML.Status.StateTime >= T#2S THEN
    bStateComplete := TRUE;
END_IF

// One item per second
tonItem(IN := (fbPackML.Status.State = E_PackMLState.Execute) AND NOT tonItem.Q,
        PT := T#1S);
IF tonItem.Q THEN
    nProduced := nProduced + 1;
END_IF

// Fequest Completing
IF fbPackML.Status.State = E_PackMLState.Execute AND nProduced >= nBatchSize THEN
    bStateComplete := TRUE;
END_IF

// New cycle
IF fbPackML.Status.State = E_PackMLState.Resetting THEN
    nProduced := 0;
END_IF