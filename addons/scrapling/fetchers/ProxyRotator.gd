extends RefCounted
class_name ProxyRotator

var _proxies: Array = []
var _current_index := 0


func _init(proxies: Array) -> void:
	for proxy in proxies:
		if proxy is String:
			_proxies.append(proxy)
		elif proxy is Dictionary:
			if not proxy.has("server"):
				push_error("Proxy dict must have a server key")
				return
			_proxies.append(proxy.duplicate(true))
		else:
			push_error("Proxy must be a String or Dictionary")
			return


func get_proxy() -> Variant:
	if _proxies.is_empty():
		return null
	var index := _current_index % _proxies.size()
	var proxy: Variant = _proxies[index]
	_current_index = (index + 1) % _proxies.size()
	return proxy


func resolve_proxy(override_proxy: Variant = null) -> Variant:
	if override_proxy != null:
		if override_proxy is String and override_proxy == "":
			return get_proxy()
		return override_proxy
	return get_proxy()
