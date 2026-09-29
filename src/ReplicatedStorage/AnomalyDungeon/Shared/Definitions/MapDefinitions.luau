-- Static map definitions: IDs and exit conditions only, no runtime state.
local Maps={
	CLOSED_STACKS={
		Id="CLOSED_STACKS",
		DisplayName="CLOSED STACKS",
		ExitCondition={Type="TERMINAL",PromptName="UnlockExit"},
		QuestObjective="出口制御端末を起動する",
	},
	TSUTAYA={
		Id="TSUTAYA",
		DisplayName="ABANDONED TSUTAYA",
		ExitCondition={Type="TERMINAL",PromptName="UnlockExit"},
		QuestObjective="出口制御端末を起動する",
	},
	AUGUST_31={
		Id="AUGUST_31",
		DisplayName="8月31日",
		ExitCondition={Type="TERMINAL",PromptName="UnlockExit"},
		QuestObjective="最終日を確認する",
	},
}

return Maps
