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

	if not T.require_true(self, page.has_method("find_by_text"), "Selector must expose find_by_text()"):
		return
	if not T.require_true(self, page.has_method("find_by_regex"), "Selector must expose find_by_regex()"):
		return

	var stock_matches: Variant = page.call("find_by_text", "In stock:", true, false)
	if not T.require_true(self, stock_matches is Array, "find_by_text() must return Array for non-first match mode"):
		return
	if not T.require_eq(self, stock_matches.size(), 2, "Expected two partial text matches for stock labels"):
		return

	var out_of_stock: Variant = page.call("find_by_text", "Out of stock", false, true)
	if not T.require_true(self, out_of_stock != null, "Exact first text match must return a node"):
		return
	if not T.require_eq(self, String(out_of_stock.call("text")).strip_edges(), "Out of stock", "Unexpected exact text match content"):
		return

	var regex_matches: Variant = page.call("find_by_regex", "In stock: [0-9]+", false)
	if not T.require_true(self, regex_matches is Array, "find_by_regex() must return Array for non-first mode"):
		return
	if not T.require_eq(self, regex_matches.size(), 2, "Expected two regex matches for stock values"):
		return

	var first_regex: Variant = page.call("find_by_regex", "In stock: [0-9]+", true)
	if not T.require_true(self, first_regex != null, "First regex match must return a node"):
		return
	if not T.require_eq(self, String(first_regex.call("text")).strip_edges(), "In stock: 5", "Unexpected first regex match content"):
		return

	T.pass_and_quit(self)
