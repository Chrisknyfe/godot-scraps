extends Node

var module_lock = Mutex.new()
var completed_tasks = 0

func _ready():
	test()

func test():
	WorkerThreadPool.start_workers(2)
	yield(get_tree().create_timer(1.0), "timeout")

	# Add work
	WorkerThreadPool.add_work(self, "fake_work")
	WorkerThreadPool.add_work(self, "fake_work", "fake userdata")
	WorkerThreadPool.add_work(self, "fake_work", "more fake asdfas", "fake_work_done")
	
	print("Complete the 108 tasks to achieve enlightenment")
	for i in range(108):
		WorkerThreadPool.add_work(self, "silent_buddhist_task", "om", "test_increment_completed_tasks")

	yield(get_tree().create_timer(5.0), "timeout")
	print("Completed %d tasks" % completed_tasks)
	assert(completed_tasks == 108)

	# Add work that causes a timeout
	WorkerThreadPool.add_work(self, "long_fake_work", "more fake asdfas", "fake_work_done", 0.1)
	WorkerThreadPool.add_work(self, "long_fake_work", "yare yare daze.", "fake_work_done", 0.1, "test_custom_timeout")
	yield(get_tree().create_timer(2.0), "timeout")
	
	print("Shutting down all workers!")
	WorkerThreadPool.stop_workers()
	
	# Wait for prints to flush
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().quit()
	
func fake_work(userdata):
	print("fake work userdata: ", userdata)
	return "fake work results"
	
func silent_buddhist_task(userdata):
	return userdata
	
func test_increment_completed_tasks(userdata):
	module_lock.lock()
	completed_tasks += 1
	module_lock.unlock()

func long_fake_work(userdata):
	print("fake work userdata: ", userdata)
	OS.delay_msec(500)
	return "fake work results"
	
func test_custom_timeout(userdata):
	print("My task timed out! ", userdata)
	
func fake_work_done(userdata):
	print("fake work done callback: ", userdata)
