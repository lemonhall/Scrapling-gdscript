extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var base_url := OS.get_environment("SCRAPLING_FIXTURE_BASE_URL")
	if not T.require_true(self, base_url != "", "SCRAPLING_FIXTURE_BASE_URL must be set for async method tests"):
		return

	var fetcher_script := load("res://addons/scrapling/fetchers/AsyncFetcher.gd")
	if not T.require_true(self, fetcher_script != null, "Failed to load res://addons/scrapling/fetchers/AsyncFetcher.gd"):
		return

	var fetcher: Variant = fetcher_script.new()
	if not T.require_true(self, fetcher != null, "Failed to instantiate AsyncFetcher.gd"):
		return

	var post_response: Variant = await fetcher.fetch_post(base_url + "/echo", '{"async":"post"}')
	if not T.require_eq(self, post_response.call("get_status"), 200, "Unexpected async POST /echo status"):
		return
	var post_body := String(post_response.call("get_text"))
	if not T.require_true(self, post_body.contains('"async": "post"') or post_body.contains('"async":"post"'), "Async POST must echo JSON body"):
		return

	var put_response: Variant = await fetcher.fetch_put(base_url + "/echo", '{"async":"put"}')
	if not T.require_eq(self, put_response.call("get_status"), 200, "Unexpected async PUT /echo status"):
		return
	var put_body := String(put_response.call("get_text"))
	if not T.require_true(self, put_body.contains('"async": "put"') or put_body.contains('"async":"put"'), "Async PUT must echo JSON body"):
		return

	var delete_response: Variant = await fetcher.fetch_delete(base_url + "/delete")
	if not T.require_eq(self, delete_response.call("get_status"), 200, "Unexpected async DELETE /delete status"):
		return
	var delete_body := String(delete_response.call("get_text"))
	if not T.require_true(self, delete_body.contains('"deleted": true') or delete_body.contains('"deleted":true"') or delete_body.contains('"deleted":true'), "Async DELETE must confirm deletion"):
		return

	T.pass_and_quit(self)
