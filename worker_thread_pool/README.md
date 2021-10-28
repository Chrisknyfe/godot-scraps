WorkerThreadPool
--

A GDScript worker threadpool.

Works best as an autoload singleton, or you can add this to a scene. In all of my use cases, I needed to send work to the threaded task and then receive results back from the task, so I added the option to add a work-done callback. The work-done callback will be called via `call_deferred()` and will receive the object you return from the task function. For example:

```
func start_work():
	WorkerThreadPool.add_work(self, "do_work", inputs, "work_done")
	
func do_work(inputs):
	results = "the work results"
	return results
	
func work_done(results):
	print(results)
```