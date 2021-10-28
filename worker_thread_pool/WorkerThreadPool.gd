extends Node

export var default_worker_thread_count = 10

class ThreadInfo:
	var worker_id: int
	var thread: Thread
	
class Task:
	var instance: Object
	var method: String
	var userdata = null
	var done_callback: String = ""

# module data lock
var module_lock = Mutex.new()

# work queue
var work_ready = Semaphore.new()
var work_queue = [] # contains Task objects

# worker thread management
var next_worker_id = 1
var threadpool = {} # contains ThreadInfo objects
var shutdown: bool = false

func lock():
	module_lock.lock()

func unlock():
	module_lock.unlock()

func _ready():
	start_workers()
	
func start_workers(num_workers: int = default_worker_thread_count):
	for i in range(num_workers):
		lock()
		var worker_id = next_worker_id
		next_worker_id += 1
		unlock()
		
		var thread = Thread.new()
		var info = ThreadInfo.new()
		info.worker_id = worker_id
		info.thread = thread
		var error = thread.start(self, "_worker_thread", info)
		assert(error == OK)
		
		lock()
		threadpool[worker_id] = info
		unlock()

func get_num_workers() -> int:
	lock()
	var num = threadpool.size()
	unlock()
	return num
	
func stop_workers():
	lock()
	shutdown = true
	unlock()
	# notify all workers
	var num_workers = get_num_workers()
	for i in range(num_workers):
		var error = work_ready.post()
		assert(error == OK)
	
	var thread_list = []
	var worker_id_list = []
	lock()
	for worker_id in threadpool:
		worker_id_list.append(worker_id)
		thread_list.append(threadpool[worker_id].thread)
	unlock()
	
	for thread in thread_list:
		thread.wait_to_finish()
	
	lock()
	for worker_id in worker_id_list:
		threadpool.erase(worker_id)
	unlock()
		
func add_work(instance: Object, method: String, userdata = null, done_callback: String = ""):
	var task = Task.new()
	task.instance = instance
	task.method = method
	task.userdata = userdata
	task.done_callback = done_callback
	lock()
	work_queue.push_front(task)
	unlock()
	var error = work_ready.post()
	assert(error == OK)
	
func _worker_thread(thread_info: ThreadInfo):
	var worker_id = thread_info.worker_id
	var running = true
	while (running):
		work_ready.wait()
		
		lock()
		var temp_shutdown = shutdown
		unlock()
		
		if temp_shutdown:
			break
			
		lock()
		var task = work_queue.pop_back()
		unlock()
		
		if task:
			var results = task.instance.call(task.method, task.userdata)
			if task.done_callback:
				task.instance.call_deferred(task.done_callback, results)
