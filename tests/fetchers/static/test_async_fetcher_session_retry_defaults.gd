extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var proxy_a := OS.get_environment("SCRAPLING_PROXY_FIXTURE_A_URL")
	var target_url := OS.get_environment("SCRAPLING_PROXY_TARGET_URL")
	if not T.require_true(self, proxy_a != "", "SCRAPLING_PROXY_FIXTURE_A_URL must be set for async session retry tests"):
		return
	if not T.require_true(self, target_url != "", "SCRAPLING_PROXY_TARGET_URL must be set for async session retry tests"):
		return

	var session_script := load("res://addons/scrapling/fetchers/AsyncFetcherSession.gd")
	var rotator_script := load("res://addons/scrapling/fetchers/ProxyRotator.gd")
	if not T.require_true(self, session_script != null, "Failed to load AsyncFetcherSession.gd"):
		return
	if not T.require_true(self, rotator_script != null, "Failed to load ProxyRotator.gd"):
		return

	var rotator: Variant = rotator_script.new(["http://127.0.0.1:1", proxy_a])
	var session: Variant = session_script.new({}, null, rotator, -1.0, 2, 0.0)
	var response: Variant = await session.fetch_get(target_url)
	if not T.require_eq(self, response.call("get_status"), 200, "AsyncFetcherSession default retries must recover through the next rotated proxy"):
		return
	var body := String(response.call("get_text"))
	if not T.require_true(self, body.contains('"proxy_label": "proxy-a"') or body.contains('"proxy_label":"proxy-a"'), "AsyncFetcherSession default retry path must succeed through proxy-a"):
		return

	if session.has_method("close"):
		session.call("close")

	T.pass_and_quit(self)
