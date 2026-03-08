extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	var rotator_script := load("res://addons/scrapling/fetchers/ProxyRotator.gd")
	if not T.require_true(self, rotator_script != null, "Failed to load ProxyRotator.gd"):
		return

	var first: Variant = rotator_script.cyclic_rotation([
		"http://p1.local:8080",
		"http://p2.local:8080",
		"http://p3.local:8080"
	], 0)
	if not T.require_true(self, first is Array and first.size() >= 2, "cyclic_rotation() must return [proxy, next_index]"):
		return
	if not T.require_eq(self, first[0], "http://p1.local:8080", "cyclic_rotation() must start from current index"):
		return
	if not T.require_eq(self, int(first[1]), 1, "cyclic_rotation() must advance next index"):
		return

	var wrapped: Variant = rotator_script.cyclic_rotation([
		"http://p1.local:8080",
		"http://p2.local:8080"
	], 5)
	if not T.require_true(self, wrapped is Array and wrapped.size() >= 2, "cyclic_rotation() must handle index overflow"):
		return
	if not T.require_eq(self, wrapped[0], "http://p2.local:8080", "cyclic_rotation() must wrap incoming index"):
		return
	if not T.require_eq(self, int(wrapped[1]), 0, "cyclic_rotation() must wrap next index"):
		return

	if not T.require_true(self, rotator_script.is_proxy_error("net::err_proxy_connection_failed"), "is_proxy_error() must detect Chromium proxy errors"):
		return
	if not T.require_true(self, rotator_script.is_proxy_error("Connection refused by proxy"), "is_proxy_error() must detect generic proxy connectivity errors"):
		return
	if not T.require_true(self, rotator_script.is_proxy_error("NET::ERR_PROXY_AUTH_FAILED"), "is_proxy_error() must be case-insensitive"):
		return
	if not T.require_true(self, not rotator_script.is_proxy_error("404 Not Found"), "is_proxy_error() must not match non-proxy errors"):
		return

	T.pass_and_quit(self)
