extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	var rotator_script := load("res://addons/scrapling/fetchers/ProxyRotator.gd")
	if not T.require_true(self, rotator_script != null, "Failed to load res://addons/scrapling/fetchers/ProxyRotator.gd"):
		return

	var rotator: Variant = rotator_script.new([
		"http://proxy-1.local:8080",
		"http://proxy-2.local:8080"
	])
	if not T.require_true(self, rotator != null, "Failed to instantiate ProxyRotator.gd"):
		return
	if not T.require_true(self, rotator.has_method("get_proxy"), "ProxyRotator must expose get_proxy()"):
		return
	if not T.require_true(self, rotator.has_method("resolve_proxy"), "ProxyRotator must expose resolve_proxy()"):
		return

	if not T.require_eq(self, rotator.call("get_proxy"), "http://proxy-1.local:8080", "First rotation should return proxy-1"):
		return
	if not T.require_eq(self, rotator.call("get_proxy"), "http://proxy-2.local:8080", "Second rotation should return proxy-2"):
		return
	if not T.require_eq(self, rotator.call("get_proxy"), "http://proxy-1.local:8080", "Rotation must wrap around"):
		return

	var second_rotator: Variant = rotator_script.new([
		{"server": "http://proxy-dict.local:8080", "username": "user", "password": "pass"},
		"http://proxy-plain.local:8080"
	])
	var override_proxy := "http://override.local:8080"
	if not T.require_eq(self, second_rotator.call("resolve_proxy", override_proxy), override_proxy, "Per-request override must win over rotator state"):
		return
	var next_proxy: Variant = second_rotator.call("get_proxy")
	if not T.require_true(self, next_proxy is Dictionary, "ProxyRotator must keep dict proxies intact"):
		return
	if not T.require_eq(self, next_proxy.get("server"), "http://proxy-dict.local:8080", "Override must not advance internal rotation state"):
		return

	T.pass_and_quit(self)
