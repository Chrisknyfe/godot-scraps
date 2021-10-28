extends Node

var module_lock = Mutex.new()
var completed_tasks = 0

signal reached_enlightenment

func _ready():
	test()

func test():
	# You can add more workers at runtime! Just in case.
	WorkerThreadPool.start_workers(2)

	WorkerThreadPool.add_work(self, "fake_work")
	WorkerThreadPool.add_work(self, "fake_work", "fake userdata")
	WorkerThreadPool.add_work(self, "fake_work", "more fake asdfas", "fake_work_done")
	
	var number_of_tasks = 108
	print("Complete the %d tasks to achieve enlightenment" % number_of_tasks)
	for i in range(number_of_tasks):
		WorkerThreadPool.add_work(self, "silent_buddhist_task", number_of_tasks, "test_increment_completed_tasks")
	
	# Ironic that this would be the place I actually learn how to use signals.
	yield(self, "reached_enlightenment")
	
	print("Completed %d tasks" % completed_tasks)
	assert(completed_tasks == number_of_tasks)
	
	print("Shutting down all workers!")
	WorkerThreadPool.stop_workers()
	
	# Wait for prints to flush
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().quit()
	
func fake_work(userdata):
	print("fake work userdata: ", userdata)
	OS.delay_msec(500)
	return "fake work results"
	
func fake_work_done(userdata):
	print("fake work done callback: ", userdata)
	
func silent_buddhist_task(number_of_tasks):
	return number_of_tasks
	
func test_increment_completed_tasks(number_of_tasks):
	module_lock.lock()
	completed_tasks += 1
	if completed_tasks >= number_of_tasks:
		self.emit_signal("reached_enlightenment")
	module_lock.unlock()
	
