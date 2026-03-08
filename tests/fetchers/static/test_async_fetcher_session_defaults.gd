extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var base_url := OS.get_environment("SCRAPLING_FIXTURE_BASE_URL")
	var proxy_a := OS.get_environment("SCRAPLING_PROXY_FIXTURE_A_URL")
	var proxy_b := OS.get_environment("SCRAPLING_PROXY_FIXTURE_B_URL")
	var proxy_target := OS.get_environment("SCRAPLING_PROXY_TARGET_URL")
	if not T.require_true(self, base_url != "", "SCRAPLING_FIXTURE_BASE_URL must be set for async session default tests"):
		return

	var session_script := load("res://addons/scrapling/fetchers/AsyncFetcherSession.gd")
	var rotator_script := load("res://addons/scrapling/fetchers/ProxyRotator.gd")
	if not T.require_true(self, session_script != null, "Failed to load AsyncFetcherSession.gd"):
		return
	if not T.require_true(self, rotator_script != null, "Failed to load ProxyRotator.gd"):
		return

	var session_with_defaults: Variant = session_script.new({"X-Session-Token": "alpha"}, null, null, 0.2)
	var inspect_response: Variant = await session_with_defaults.fetch_get(base_url + "/inspect")
	if not T.require_eq(self, inspect_response.call("get_status"), 200, "Async session default headers must reach inspect endpoint"):
		return
	var inspect_body := String(inspect_response.call("get_text"))
	if not T.require_true(self, inspect_body.contains('"X-Session-Token": "alpha"') or inspect_body.contains('"X-Session-Token":"alpha"'), "Async session default header must be applied"):
		return

	var slow_response: Variant = await session_with_defaults.fetch_get(base_url + "/slow?delay=1.0")
	if not T.require_eq(self, slow_response.call("get_status"), 0, "Async session default timeout must be applied"):
		return

	var rotator: Variant = rotator_script.new([proxy_a, proxy_b])
	var session_with_rotator: Variant = session_script.new({}, null, rotator)
	var first_proxy_response: Variant = await session_with_rotator.fetch_get(proxy_target)
	if not T.require_eq(self, first_proxy_response.call("get_status"), 200, "Async session default rotator request 1 must succeed"):
		return
	var first_proxy_body := String(first_proxy_response.call("get_text"))
	if not T.require_true(self, first_proxy_body.contains('"proxy_label": "proxy-a"') or first_proxy_body.contains('"proxy_label":"proxy-a"'), "Async session default rotator must start at proxy-a"):
		return

	var second_proxy_response: Variant = await session_with_rotator.fetch_get(proxy_target)
	if not T.require_eq(self, second_proxy_response.call("get_status"), 200, "Async session default rotator request 2 must succeed"):
		return
	var second_proxy_body := String(second_proxy_response.call("get_text"))
	if not T.require_true(self, second_proxy_body.contains('"proxy_label": "proxy-b"') or second_proxy_body.contains('"proxy_label":"proxy-b"'), "Async session default rotator must advance to proxy-b"):
		return

	if session_with_defaults.has_method("close"):
		session_with_defaults.call("close")
	if session_with_rotator.has_method("close"):
		session_with_rotator.call("close")

	T.pass_and_quit(self)
