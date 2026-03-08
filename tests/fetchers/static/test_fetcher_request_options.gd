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

	var response: Variant = fetcher.call(
		"fetch_get",
		base_url + "/inspect",
		{"q": "godot", "page": 4},
		{"X-Test-Token": "lemons"}
	)
	if not T.require_true(self, response != null, "Fetcher.fetch_get() must support params + headers"):
		return
	if not T.require_eq(self, response.call("get_status"), 200, "Unexpected GET /inspect status"):
		return
	var body := String(response.call("get_text"))
	if not T.require_true(self, body.contains('"q": "godot"') or body.contains('"q":"godot"'), "Response body must echo query param q"):
		return
	if not T.require_true(self, body.contains('"page": "4"') or body.contains('"page":"4"'), "Response body must echo query param page"):
		return
	if not T.require_true(self, body.contains('"X-Test-Token": "lemons"') or body.contains('"X-Test-Token":"lemons"'), "Response body must echo request header"):
		return

	T.pass_and_quit(self)
