extends SceneTree

const T := preload("res://tests/_test_util.gd")

func _init() -> void:
	var base_url := OS.get_environment("SCRAPLING_FIXTURE_BASE_URL")
	if not T.require_true(self, base_url != "", "SCRAPLING_FIXTURE_BASE_URL must be set for fetcher tests"):
		return

	if not T.require_true(self, FileAccess.file_exists("res://addons/scrapling/fetchers/Fetcher.gd"), "Missing res://addons/scrapling/fetchers/Fetcher.gd"):
		return

	var fetcher_script := load("res://addons/scrapling/fetchers/Fetcher.gd")
	if not T.require_true(self, fetcher_script != null, "Failed to load res://addons/scrapling/fetchers/Fetcher.gd"):
		return

	var fetcher: Variant = fetcher_script.new()
	if not T.require_true(self, fetcher != null, "Failed to instantiate Fetcher.gd"):
		return
	if not T.require_true(self, fetcher.has_method("fetch_get"), "Fetcher must expose fetch_get()"):
		return

	var response: Variant = fetcher.call("fetch_get", base_url + "/hello")
	if not T.require_true(self, response != null, "Fetcher.fetch_get() must return a response object"):
		return
	if not T.require_true(self, response.has_method("get_status"), "Response object must expose get_status()"):
		return
	if not T.require_true(self, response.has_method("get_text"), "Response object must expose get_text()"):
		return
	if not T.require_eq(self, response.call("get_status"), 200, "Unexpected GET /hello status"):
		return
	if not T.require_true(self, String(response.call("get_text")).contains("hello"), "Response body must contain hello"):
		return

	T.pass_and_quit(self)

