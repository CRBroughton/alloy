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
Program :: struct($Model: typeid) {
	init:   proc() -> (^Model, Cmd),
	update: proc(_: ^Model, _: Msg) -> (^Model, Cmd),
	view:   proc(_: ^Model) -> string,
}

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

// --- Cmd dispatch -----------------------------------------------------------

CmdThreadData :: struct {
	queue: ^MsgQueue,
	fn:    proc() -> Msg,
}

SleepCmdData :: struct {
	queue:    ^MsgQueue,
	duration: time.Duration,
	then:     Msg,
}

// dispatch_cmd launches a Cmd on a background thread and appends it to threads
// so the caller can clean it up later with cleanup_threads.
// Odin has no thread.detach — we track threads and destroy them once done.
dispatch_cmd :: proc(queue: ^MsgQueue, cmd: Cmd, threads: ^[dynamic]^thread.Thread) {
	switch c in cmd {
	case proc() -> Msg:
		data := new(CmdThreadData)
		data.queue = queue
		data.fn = c
		t := thread.create(proc(th: ^thread.Thread) {
			d := cast(^CmdThreadData)th.user_args[0]
			msg := d.fn()
			queue_push(d.queue, msg)
			free(d)
		})
		t.user_args[0] = data
		thread.start(t)
		append(threads, t)
	case SleepCmd:
		data := new(SleepCmdData)
		data.queue = queue
		data.duration = c.duration
		data.then = c.then
		t := thread.create(proc(th: ^thread.Thread) {
			d := cast(^SleepCmdData)th.user_args[0]
			time.sleep(d.duration)
			queue_push(d.queue, d.then)
			free(d)
		})
		t.user_args[0] = data
		thread.start(t)
		append(threads, t)
	}
}

// cleanup_threads destroys any cmd threads that have finished.
// Call this each loop iteration to avoid unbounded thread handle growth.
cleanup_threads :: proc(threads: ^[dynamic]^thread.Thread) {
	i := 0
	for i < len(threads) {
		t := threads[i]
		if thread.is_done(t) {
			thread.destroy(t)
			unordered_remove(threads, i)
		} else {
			i += 1
		}
	}
}

// --- Render -----------------------------------------------------------------

render :: proc(p: ^Program($Model), model: ^Model) {
	os.write_string(os.stdout, CLEAR_SCREEN)
	os.write_string(os.stdout, CURSOR_HOME)
	os.write_string(os.stdout, p.view(model))
}

// --- Event loop -------------------------------------------------------------

run :: proc(p: ^Program($Model)) {
	// 1. Terminal setup
	term: Term
	if !term_init(&term) do os.exit(1)
	term_raw(&term)
	defer term_restore(&term)
	os.write_string(os.stdout, ALT_SCREEN_ENTER)
	defer os.write_string(os.stdout, ALT_SCREEN_EXIT)
	defer os.write_string(os.stdout, CURSOR_SHOW)

	// 2. Message queue
	queue: MsgQueue
	queue.msgs = make([dynamic]Msg)
	defer queue_destroy(&queue)

	// 3. Cmd thread tracker
	cmd_threads := make([dynamic]^thread.Thread)
	defer {
		for t in cmd_threads {
			thread.join(t)
			thread.destroy(t)
		}
		delete(cmd_threads)
	}

	// 4. Input thread
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

	// 5. Init model — dispatch any startup command (e.g. spinner first tick)
	model, first_cmd := p.init()
	if first_cmd != nil {
		dispatch_cmd(&queue, first_cmd, &cmd_threads)
	}

	// 6. First render
	os.write_string(os.stdout, CURSOR_HIDE)
	render(p, model)

	// 7. Window size
	w, h := term_size()
	queue_push(&queue, WindowSizeMsg{width = w, height = h})

	// 8. Event loop
	for {
		cleanup_threads(&cmd_threads)

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
			dispatch_cmd(&queue, cmd, &cmd_threads)
		}

		render(p, model)
	}
}
