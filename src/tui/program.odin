package tui

import "core:os"
import "core:sync"
import "core:thread"
import "core:time"

// MsgQueue is a thread-safe FIFO of Msgs.
MsgQueue :: struct {
	mu:   sync.Mutex,
	msgs: [dynamic]Msg,
}

queue_push :: proc(q: ^MsgQueue, msg: Msg) {
	sync.mutex_lock(&q.mu)
	defer sync.mutex_unlock(&q.mu)
	append(&q.msgs, msg)
}

queue_pop :: proc(q: ^MsgQueue) -> (Msg, bool) {
	sync.mutex_lock(&q.mu)
	defer sync.mutex_unlock(&q.mu)
	if len(q.msgs) == 0 do return nil, false
	msg := q.msgs[0]
	ordered_remove(&q.msgs, 0)
	return msg, true
}

queue_destroy :: proc(q: ^MsgQueue) {
	delete(q.msgs)
}

// Program is the top-level runner.
Program :: struct {
	init:   proc() -> (rawptr, Cmd),
	update: proc(model: rawptr, msg: Msg) -> (rawptr, Cmd),
	view:   proc(model: rawptr) -> string,
}

// input_thread_data is passed to the input-reading background thread.
InputThreadData :: struct {
	queue:   ^MsgQueue,
	running: ^bool,
}

input_thread_proc :: proc(t: ^thread.Thread) {
	data := cast(^InputThreadData)t.user_args[0]
	for data.running^ {
		msg := read_key()
		queue_push(data.queue, msg)
	}
}

// render writes a full frame: clear screen, cursor home, then the view.
render :: proc(p: ^Program, model: rawptr) {
	os.write_string(os.stdout, CLEAR_SCREEN)
	os.write_string(os.stdout, CURSOR_HOME)
	os.write_string(os.stdout, p.view(model))
}

// run starts the event loop. Blocks until update returns a quit Cmd.
run :: proc(p: ^Program) {
	// 1. Terminal setup
	term: Term
	if !term_init(&term) do os.exit(1)
	term_raw(&term)
	defer term_restore(&term)
	// Enter alternate screen: clean slate, no scrollback pollution.
	// On exit (defer runs in reverse) we leave alt screen and restore the cursor.
	os.write_string(os.stdout, ALT_SCREEN_ENTER)
	defer os.write_string(os.stdout, ALT_SCREEN_EXIT)
	defer os.write_string(os.stdout, CURSOR_SHOW)

	// 2. Message queue
	queue: MsgQueue
	queue.msgs = make([dynamic]Msg)
	defer queue_destroy(&queue)

	// 3. Input thread
	running := true
	thread_data := InputThreadData {
		queue   = &queue,
		running = &running,
	}
	input_t := thread.create(input_thread_proc)
	input_t.user_args[0] = &thread_data
	thread.start(input_t)
	defer {
		running = false
		thread.join(input_t)
		thread.destroy(input_t)
	}

	// 4. Init the model
	model, first_cmd := p.init()
	if first_cmd != nil {
		cmd_msg := first_cmd()
		queue_push(&queue, cmd_msg)
	}

	// 5. Hide cursor and do the first render immediately
	os.write_string(os.stdout, CURSOR_HIDE)
	render(p, model)

	// 6. Send initial window size
	w, h := term_size()
	queue_push(&queue, WindowSizeMsg{width = w, height = h})

	// 7. Event loop
	for {
		msg, ok := queue_pop(&queue)
		if !ok {
			time.sleep(time.Millisecond * 8)
			continue
		}

		if _, is_quit := msg.(QuitMsg); is_quit {
			break
		}

		new_model, cmd := p.update(model, msg)
		model = new_model

		if cmd != nil {
			cmd_msg := cmd()
			if _, is_quit := cmd_msg.(QuitMsg); is_quit {
				break
			}
			queue_push(&queue, cmd_msg)
		}

		render(p, model)
	}
}
