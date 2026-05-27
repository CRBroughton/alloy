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
	values: []string, // multi-select only; caller owns — use step_result_destroy
	status: StepStatus,
}

// step_result_destroy frees values if non-nil. Safe to call on any StepResult.
step_result_destroy :: proc(result: ^StepResult) {
	if result.values != nil {
		delete(result.values)
		result.values = nil
	}
}

Msg :: union {
	KeyMsg,
	QuitMsg,
}

QuitMsg :: struct {}

Cmd :: union {
	proc() -> Msg,
}
