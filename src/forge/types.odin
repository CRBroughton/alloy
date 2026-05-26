package forge

import components "../alloy-components"

Key    :: components.Key
KeyMsg :: components.KeyMsg

StepStatus :: enum {
	Active,
	Done,
	Cancelled,
	Error,
}

StepResult :: struct {
	value:  string,
	status: StepStatus,
}

Msg :: union {
	KeyMsg,
	QuitMsg,
}

QuitMsg :: struct {}

Cmd :: union {
	proc() -> Msg,
}
