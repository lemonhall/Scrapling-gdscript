extends RefCounted
class_name ProxyRotator

var _proxies: Array = []
var _current_index := 0
var _strategy: Callable = Callable()


func _init(proxies: Array, strategy: Callable = Callable()) -> void:
	_strategy = strategy
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
	var rotation: Array = _run_rotation_strategy()
	if rotation.size() < 2:
		return null
	_current_index = int(rotation[1])
	return rotation[0]


func resolve_proxy(override_proxy: Variant = null) -> Variant:
	if override_proxy != null:
		if override_proxy is String and override_proxy == "":
			return get_proxy()
		return override_proxy
	return get_proxy()


func get_proxies() -> Array:
	return _duplicate_proxies()


func size() -> int:
	return _proxies.size()


func _to_string() -> String:
	return "ProxyRotator(proxies=%d)" % _proxies.size()


func _run_rotation_strategy() -> Array:
	if _strategy.is_valid():
		var result: Variant = _strategy.call(_proxies, _current_index)
		if result is Array and result.size() >= 2:
			return [result[0], int(result[1])]
		push_error("Proxy rotation strategy must return [proxy, next_index]")
	return _cyclic_rotation(_proxies, _current_index)


func _cyclic_rotation(proxies: Array, current_index: int) -> Array:
	if proxies.is_empty():
		return [null, current_index]
	var index := current_index % proxies.size()
	return [proxies[index], (index + 1) % proxies.size()]


func _duplicate_proxies() -> Array:
	var copy: Array = []
	for proxy in _proxies:
		if proxy is Dictionary:
			copy.append(proxy.duplicate(true))
		elif proxy is Array:
			copy.append(proxy.duplicate(true))
		else:
			copy.append(proxy)
	return copy
