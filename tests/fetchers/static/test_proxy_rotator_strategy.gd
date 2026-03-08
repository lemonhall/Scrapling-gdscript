extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	var rotator_script := load("res://addons/scrapling/fetchers/ProxyRotator.gd")
	if not T.require_true(self, rotator_script != null, "Failed to load ProxyRotator.gd"):
		return

	var rotator: Variant = rotator_script.new([
		"http://primary.local:8080",
		"http://backup.local:8080"
	], Callable(self, "_sticky_strategy"))
	if not T.require_true(self, rotator != null, "Failed to instantiate ProxyRotator.gd with strategy"):
		return
	if not T.require_true(self, rotator.has_method("get_proxies"), "ProxyRotator must expose get_proxies()"):
		return
	if not T.require_true(self, rotator.has_method("size"), "ProxyRotator must expose size()"):
		return

	if not T.require_eq(self, rotator.call("get_proxy"), "http://primary.local:8080", "Sticky strategy must always return primary"):
		return
	if not T.require_eq(self, rotator.call("get_proxy"), "http://primary.local:8080", "Sticky strategy must not advance"):
		return
	if not T.require_eq(self, rotator.call("size"), 2, "ProxyRotator.size() must equal configured proxy count"):
		return

	var proxies_copy: Variant = rotator.call("get_proxies")
	if not T.require_true(self, proxies_copy is Array, "get_proxies() must return an Array"):
		return
	proxies_copy.append("http://third.local:8080")
	if not T.require_eq(self, rotator.call("size"), 2, "get_proxies() must return a copy, not live backing storage"):
		return
	if not T.require_true(self, str(rotator).contains("ProxyRotator(proxies=2)"), "ProxyRotator string form must expose proxy count"):
		return

	T.pass_and_quit(self)


func _sticky_strategy(proxies: Array, current_index: int) -> Array:
	return [proxies[0], current_index]
