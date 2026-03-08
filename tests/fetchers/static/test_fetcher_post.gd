extends SceneTree

const T := preload("res://tests/_test_util.gd")

func _init() -> void:
	var base_url := OS.get_environment("SCRAPLING_FIXTURE_BASE_URL")
	if not T.require_true(self, base_url != "", "SCRAPLING_FIXTURE_BASE_URL must be set for fetcher tests"):
		return

	var fetcher_script := load("res://addons/scrapling/fetchers/Fetcher.gd")
	if not T.require_true(self, fetcher_script != null, "Failed to load res://addons/scrapling/fetchers/Fetcher.gd"):
		return

	var fetcher: Variant = fetcher_script.new()
	if not T.require_true(self, fetcher != null, "Failed to instantiate Fetcher.gd"):
		return
	if not T.require_true(self, fetcher.has_method("fetch_post"), "Fetcher must expose fetch_post()"):
		return

	var response: Variant = fetcher.call("fetch_post", base_url + "/echo", '{"key":"value"}')
	if not T.require_true(self, response != null, "Fetcher.fetch_post() must return a response object"):
		return
	if not T.require_eq(self, response.call("get_status"), 200, "Unexpected POST /echo status"):
		return
	var body := String(response.call("get_text"))
	if not T.require_true(self, body.contains('"key": "value"') or body.contains('"key":"value"'), "Response body must echo posted json"):
		return

	T.pass_and_quit(self)
