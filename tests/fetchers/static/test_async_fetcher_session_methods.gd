extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var base_url := OS.get_environment("SCRAPLING_FIXTURE_BASE_URL")
	if not T.require_true(self, base_url != "", "SCRAPLING_FIXTURE_BASE_URL must be set for async session method tests"):
		return

	var session_script := load("res://addons/scrapling/fetchers/AsyncFetcherSession.gd")
	if not T.require_true(self, session_script != null, "Failed to load res://addons/scrapling/fetchers/AsyncFetcherSession.gd"):
		return

	var session: Variant = session_script.new()
	if not T.require_true(self, session != null, "Failed to instantiate AsyncFetcherSession.gd"):
		return

	var post_response: Variant = await session.fetch_post(base_url + "/echo", '{"async_session":"post"}')
	if not T.require_eq(self, post_response.call("get_status"), 200, "Unexpected async session POST /echo status"):
		return
	var post_body := String(post_response.call("get_text"))
	if not T.require_true(self, post_body.contains('"async_session": "post"') or post_body.contains('"async_session":"post"'), "Async session POST must echo JSON body"):
		return

	var put_response: Variant = await session.fetch_put(base_url + "/echo", '{"async_session":"put"}')
	if not T.require_eq(self, put_response.call("get_status"), 200, "Unexpected async session PUT /echo status"):
		return
	var put_body := String(put_response.call("get_text"))
	if not T.require_true(self, put_body.contains('"async_session": "put"') or put_body.contains('"async_session":"put"'), "Async session PUT must echo JSON body"):
		return

	var delete_response: Variant = await session.fetch_delete(base_url + "/delete")
	if not T.require_eq(self, delete_response.call("get_status"), 200, "Unexpected async session DELETE /delete status"):
		return
	var delete_body := String(delete_response.call("get_text"))
	if not T.require_true(self, delete_body.contains('"deleted": true') or delete_body.contains('"deleted":true'), "Async session DELETE must confirm deletion"):
		return

	if session.has_method("close"):
		session.call("close")

	T.pass_and_quit(self)
