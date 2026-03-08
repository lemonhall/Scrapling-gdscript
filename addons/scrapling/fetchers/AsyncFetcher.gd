extends RefCounted
class_name AsyncFetcher

const FetcherScript := preload("res://addons/scrapling/fetchers/Fetcher.gd")
const FetcherResponseScript := preload("res://addons/scrapling/fetchers/FetcherResponse.gd")


class RequestJob:
	extends RefCounted

	var _fetcher: Variant = null
	var _method_name := ""
	var _args: Array = []
	var result: Variant = null

	func _init(fetcher: Variant, method_name: String, args: Array) -> void:
		_fetcher = fetcher
		_method_name = method_name
		_args = args.duplicate(true)

	func run() -> void:
		result = _fetcher.callv(_method_name, _args)


var _fetcher: Variant = null


func _init(default_headers: Dictionary = {}, cookie_jar_path: String = "", default_retries: int = 3, default_retry_delay_sec: float = 1.0) -> void:
	_fetcher = FetcherScript.new(default_headers, cookie_jar_path, default_retries, default_retry_delay_sec)


func fetch_get(url: String, params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null, timeout_sec: float = -1.0, retries: int = -1, retry_delay_sec: float = -1.0) -> Variant:
	return await _run_async("fetch_get", [url, params, headers, cookies, proxy, proxy_rotator, timeout_sec, retries, retry_delay_sec])


func fetch_post(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null, timeout_sec: float = -1.0, retries: int = -1, retry_delay_sec: float = -1.0) -> Variant:
	return await _run_async("fetch_post", [url, body, params, headers, cookies, proxy, proxy_rotator, timeout_sec, retries, retry_delay_sec])


func fetch_put(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null, timeout_sec: float = -1.0, retries: int = -1, retry_delay_sec: float = -1.0) -> Variant:
	return await _run_async("fetch_put", [url, body, params, headers, cookies, proxy, proxy_rotator, timeout_sec, retries, retry_delay_sec])


func fetch_delete(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null, timeout_sec: float = -1.0, retries: int = -1, retry_delay_sec: float = -1.0) -> Variant:
	return await _run_async("fetch_delete", [url, body, params, headers, cookies, proxy, proxy_rotator, timeout_sec, retries, retry_delay_sec])


func _run_async(method_name: String, args: Array) -> Variant:
	var job := RequestJob.new(_fetcher, method_name, args)
	var thread := Thread.new()
	var err := thread.start(Callable(job, "run"))
	if err != OK:
		return FetcherResponseScript.new(0, "")
	var main_loop := Engine.get_main_loop()
	while thread.is_alive():
		if main_loop is SceneTree:
			await (main_loop as SceneTree).process_frame
		else:
			OS.delay_msec(1)
	thread.wait_to_finish()
	return job.result
