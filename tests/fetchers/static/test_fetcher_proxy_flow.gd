extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	var proxy_a := OS.get_environment("SCRAPLING_PROXY_FIXTURE_A_URL")
	var proxy_b := OS.get_environment("SCRAPLING_PROXY_FIXTURE_B_URL")
	var target_url := OS.get_environment("SCRAPLING_PROXY_TARGET_URL")
	if not T.require_true(self, proxy_a != "", "SCRAPLING_PROXY_FIXTURE_A_URL must be set for proxy tests"):
		return
	if not T.require_true(self, proxy_b != "", "SCRAPLING_PROXY_FIXTURE_B_URL must be set for proxy tests"):
		return
	if not T.require_true(self, target_url != "", "SCRAPLING_PROXY_TARGET_URL must be set for proxy tests"):
		return

	var fetcher_script := load("res://addons/scrapling/fetchers/Fetcher.gd")
	var rotator_script := load("res://addons/scrapling/fetchers/ProxyRotator.gd")
	if not T.require_true(self, fetcher_script != null, "Failed to load Fetcher.gd"):
		return
	if not T.require_true(self, rotator_script != null, "Failed to load ProxyRotator.gd"):
		return

	var fetcher: Variant = fetcher_script.new()
	var rotator: Variant = rotator_script.new([proxy_a, proxy_b])

	var override_response: Variant = fetcher.call("fetch_get", target_url, {}, {}, {}, proxy_b, rotator)
	if not T.require_eq(self, override_response.call("get_status"), 200, "Per-request proxy override must succeed"):
		return
	var override_body := String(override_response.call("get_text"))
	if not T.require_true(self, override_body.contains('"proxy_label": "proxy-b"') or override_body.contains('"proxy_label":"proxy-b"'), "Override request must go through proxy-b"):
		return

	var first_rotated: Variant = fetcher.call("fetch_get", target_url, {}, {}, {}, "", rotator)
	if not T.require_eq(self, first_rotated.call("get_status"), 200, "First rotated proxy request must succeed"):
		return
	var first_body := String(first_rotated.call("get_text"))
	if not T.require_true(self, first_body.contains('"proxy_label": "proxy-a"') or first_body.contains('"proxy_label":"proxy-a"'), "Override must not consume rotator state"):
		return

	var second_rotated: Variant = fetcher.call("fetch_get", target_url, {}, {}, {}, "", rotator)
	if not T.require_eq(self, second_rotated.call("get_status"), 200, "Second rotated proxy request must succeed"):
		return
	var second_body := String(second_rotated.call("get_text"))
	if not T.require_true(self, second_body.contains('"proxy_label": "proxy-b"') or second_body.contains('"proxy_label":"proxy-b"'), "Rotator must advance to proxy-b on second real request"):
		return

	T.pass_and_quit(self)
