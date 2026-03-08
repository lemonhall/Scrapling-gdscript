extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	var proxy_a := OS.get_environment("SCRAPLING_PROXY_FIXTURE_A_URL")
	var target_url := OS.get_environment("SCRAPLING_PROXY_TARGET_URL")
	if not T.require_true(self, proxy_a != "", "SCRAPLING_PROXY_FIXTURE_A_URL must be set for retry tests"):
		return
	if not T.require_true(self, target_url != "", "SCRAPLING_PROXY_TARGET_URL must be set for retry tests"):
		return

	var fetcher_script := load("res://addons/scrapling/fetchers/Fetcher.gd")
	var rotator_script := load("res://addons/scrapling/fetchers/ProxyRotator.gd")
	if not T.require_true(self, fetcher_script != null, "Failed to load Fetcher.gd"):
		return
	if not T.require_true(self, rotator_script != null, "Failed to load ProxyRotator.gd"):
		return

	var fetcher: Variant = fetcher_script.new()
	var rotator: Variant = rotator_script.new(["http://127.0.0.1:1", proxy_a])
	var response: Variant = fetcher.call("fetch_get", target_url, {}, {}, {}, "", rotator, 1.0, 2, 0.0)
	if not T.require_eq(self, response.call("get_status"), 200, "Fetcher must retry with the next rotated proxy when the first proxy fails"):
		return
	var body := String(response.call("get_text"))
	if not T.require_true(self, body.contains('"proxy_label": "proxy-a"') or body.contains('"proxy_label":"proxy-a"'), "Retry path must eventually succeed through proxy-a"):
		return

	T.pass_and_quit(self)
