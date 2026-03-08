extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var base_url := OS.get_environment("SCRAPLING_FIXTURE_BASE_URL")
	if not T.require_true(self, base_url != "", "SCRAPLING_FIXTURE_BASE_URL must be set for async fetcher tests"):
		return

	var fetcher_script := load("res://addons/scrapling/fetchers/AsyncFetcher.gd")
	if not T.require_true(self, fetcher_script != null, "Failed to load res://addons/scrapling/fetchers/AsyncFetcher.gd"):
		return

	var fetcher: Variant = fetcher_script.new()
	if not T.require_true(self, fetcher != null, "Failed to instantiate AsyncFetcher.gd"):
		return
	if not T.require_true(self, fetcher.has_method("fetch_get"), "AsyncFetcher must expose fetch_get()"):
		return

	var response: Variant = await fetcher.fetch_get(base_url + "/hello")
	if not T.require_true(self, response != null, "AsyncFetcher.fetch_get() must resolve to a response object"):
		return
	if not T.require_eq(self, response.call("get_status"), 200, "Unexpected async GET /hello status"):
		return
	if not T.require_true(self, String(response.call("get_text")).contains("hello"), "Async fetcher body must contain hello"):
		return

	T.pass_and_quit(self)
