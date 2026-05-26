package forge

import "core:testing"

@(test)
test_step_result_done :: proc(t: ^testing.T) {
	result := StepResult{value = "hello", status = .Done}
	testing.expect_value(t, result.status, StepStatus.Done)
	testing.expect_value(t, result.value, "hello")
}

@(test)
test_step_result_cancelled :: proc(t: ^testing.T) {
	result := StepResult{status = .Cancelled}
	testing.expect_value(t, result.status, StepStatus.Cancelled)
	testing.expect_value(t, result.value, "")
}

@(test)
test_step_result_error :: proc(t: ^testing.T) {
	result := StepResult{status = .Error}
	testing.expect_value(t, result.status, StepStatus.Error)
}

@(test)
test_key_msg_rune :: proc(t: ^testing.T) {
	msg := KeyMsg{key = .Rune, rune = 'a'}
	testing.expect_value(t, msg.key, Key.Rune)
	testing.expect_value(t, msg.rune, rune('a'))
}

@(test)
test_key_msg_enter :: proc(t: ^testing.T) {
	msg := KeyMsg{key = .Enter}
	testing.expect_value(t, msg.key, Key.Enter)
}

@(test)
test_msg_union_key :: proc(t: ^testing.T) {
	msg: Msg = KeyMsg{key = .CtrlC}
	km, ok := msg.(KeyMsg)
	testing.expect(t, ok, "should be KeyMsg")
	testing.expect_value(t, km.key, Key.CtrlC)
}

@(test)
test_msg_union_quit :: proc(t: ^testing.T) {
	msg: Msg = QuitMsg{}
	_, ok := msg.(QuitMsg)
	testing.expect(t, ok, "should be QuitMsg")
}
