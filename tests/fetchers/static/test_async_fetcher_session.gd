extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var base_url := OS.get_environment("SCRAPLING_FIXTURE_BASE_URL")
	if not T.require_true(self, base_url != "", "SCRAPLING_FIXTURE_BASE_URL must be set for async session tests"):
		return

	var session_script := load("res://addons/scrapling/fetchers/AsyncFetcherSession.gd")
	if not T.require_true(self, session_script != null, "Failed to load res://addons/scrapling/fetchers/AsyncFetcherSession.gd"):
		return

	var session: Variant = session_script.new()
	if not T.require_true(self, session != null, "Failed to instantiate AsyncFetcherSession.gd"):
		return
	if not T.require_true(self, session.has_method("fetch_get"), "AsyncFetcherSession must expose fetch_get()"):
		return

	var set_response: Variant = await session.fetch_get(base_url + "/set-cookie")
	if not T.require_eq(self, set_response.call("get_status"), 200, "Async session /set-cookie must succeed"):
		return

	var check_response: Variant = await session.fetch_get(base_url + "/check-cookie")
	if not T.require_eq(self, check_response.call("get_status"), 200, "Async session /check-cookie must succeed"):
		return
	var body := String(check_response.call("get_text"))
	if not T.require_true(self, body.contains('"session_id": "abc123"') or body.contains('"session_id":"abc123"'), "Async session must persist cookies across requests"):
		return

	if session.has_method("close"):
		session.call("close")

	T.pass_and_quit(self)
