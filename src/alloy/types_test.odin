package alloy

import "core:testing"

@(test)
test_keymsg_type_assertion :: proc(t: ^testing.T) {
	// A KeyMsg placed into a Msg union should unwrap cleanly
	msg: Msg = KeyMsg {
		key = .Enter,
	}

	km, ok := msg.(KeyMsg)
	testing.expect(t, ok, "type assertion to KeyMsg should succeed")
	testing.expect_value(t, km.key, Key.Enter)
}

@(test)
test_keymsg_rune_field :: proc(t: ^testing.T) {
	msg: Msg = KeyMsg {
		key  = .Rune,
		rune = 'a',
	}

	km, ok := msg.(KeyMsg)
	testing.expect(t, ok, "type assertion to KeyMsg should succeed")
	testing.expect_value(t, km.key, Key.Rune)
	testing.expect_value(t, km.rune, 'a')
}

@(test)
test_windowsizemsg_type_assertion :: proc(t: ^testing.T) {
	msg: Msg = WindowSizeMsg {
		width  = 80,
		height = 24,
	}

	ws, ok := msg.(WindowSizeMsg)
	testing.expect(t, ok, "type assertion to WindowSizeMsg should succeed")
	testing.expect_value(t, ws.width, 80)
	testing.expect_value(t, ws.height, 24)
}

@(test)
test_quitmsg_type_assertion :: proc(t: ^testing.T) {
	msg: Msg = QuitMsg{}

	_, ok := msg.(QuitMsg)
	testing.expect(t, ok, "type assertion to QuitMsg should succeed")
}

@(test)
test_nil_msg_does_not_match_concrete_type :: proc(t: ^testing.T) {
	msg: Msg = nil

	_, ok := msg.(KeyMsg)
	testing.expect(t, !ok, "nil Msg should not match KeyMsg")
}

@(test)
test_type_switch_dispatches_correctly :: proc(t: ^testing.T) {
	// Verify the idiomatic union dispatch pattern works as expected
	msgs := []Msg{KeyMsg{key = .CtrlC}, WindowSizeMsg{width = 120, height = 40}, QuitMsg{}}

	got_key := false
	got_resize := false
	got_quit := false

	for msg in msgs {
		#partial switch m in msg {
		case KeyMsg:
			got_key = true
			testing.expect_value(t, m.key, Key.CtrlC)
		case WindowSizeMsg:
			got_resize = true
			testing.expect_value(t, m.width, 120)
		case QuitMsg:
			got_quit = true
		}
	}

	testing.expect(t, got_key, "should have dispatched KeyMsg")
	testing.expect(t, got_resize, "should have dispatched WindowSizeMsg")
	testing.expect(t, got_quit, "should have dispatched QuitMsg")
}
