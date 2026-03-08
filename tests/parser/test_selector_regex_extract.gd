extends SceneTree

const T := preload("res://tests/_test_util.gd")

func _init() -> void:
	var selector_script := load("res://addons/scrapling/parser/Selector.gd")
	if not T.require_true(self, selector_script != null, "Failed to load res://addons/scrapling/parser/Selector.gd"):
		return

	var html := FileAccess.get_file_as_string("res://tests/fixtures/parser/complex_page.html")
	var page: Variant = selector_script.new(html)
	if not T.require_true(self, page != null, "Failed to instantiate Selector with HTML fixture"):
		return

	var prices: Variant = page.call("css", ".price")
	if not T.require_eq(self, prices.size(), 3, "Expected three price nodes"):
		return

	var first_price: Variant = prices[0]
	if not T.require_true(self, first_price.has_method("re"), "Selector must expose re()"):
		return
	if not T.require_true(self, first_price.has_method("re_first"), "Selector must expose re_first()"):
		return

	var price_matches: Variant = first_price.call("re", "[\\.\\d]+")
	if not T.require_true(self, price_matches is Array, "re() must return Array"):
		return
	if not T.require_eq(self, price_matches.size(), 1, "Expected one numeric match in first price"):
		return
	if not T.require_eq(self, String(price_matches[0]), "10.99", "Unexpected regex extraction result"):
		return

	var first_match: Variant = first_price.call("re_first", "[\\.\\d]+")
	if not T.require_eq(self, String(first_match), "10.99", "Unexpected regex first match result"):
		return

	T.pass_and_quit(self)
