-- Static map definitions: IDs and exit conditions only, no runtime state.
local Maps={
	CLOSED_STACKS={
		Id="CLOSED_STACKS",
		DisplayName="CLOSED STACKS",
		ExitCondition={Type="TERMINAL",PromptName="UnlockExit"},
	},
}

return Maps
