extends SceneTree

const T := preload("res://tests/_test_util.gd")

func _init() -> void:
	if not T.require_true(self, FileAccess.file_exists("res://addons/scrapling/parser/Selector.gd"), "Missing res://addons/scrapling/parser/Selector.gd"):
		return
	if not T.require_true(self, FileAccess.file_exists("res://addons/scrapling/parser/Selectors.gd"), "Missing res://addons/scrapling/parser/Selectors.gd"):
		return

	var selector_script := load("res://addons/scrapling/parser/Selector.gd")
	if not T.require_true(self, selector_script != null, "Failed to load res://addons/scrapling/parser/Selector.gd"):
		return

	var html := FileAccess.get_file_as_string("res://tests/fixtures/parser/complex_page.html")
	if not T.require_true(self, html.length() > 0, "Parser fixture must not be empty"):
		return

	var page: Variant = selector_script.new(html)
	if not T.require_true(self, page != null, "Failed to instantiate Selector with HTML fixture"):
		return
	if not T.require_true(self, page.has_method("css"), "Selector must expose css()"):
		return
	if not T.require_true(self, page.has_method("xpath"), "Selector must expose xpath()"):
		return

	var products: Variant = page.call("css", "main #products .product-list article.product")
	if not T.require_true(self, products is Array, "css() must return Array-like collection"):
		return
	if not T.require_eq(self, products.size(), 3, "Expected three product nodes from css()"):
		return

	var reviews: Variant = page.call("xpath", '//section[@id="reviews"]//div[contains(@class, "review")]')
	if not T.require_true(self, reviews is Array, "xpath() must return Array-like collection"):
		return
	if not T.require_eq(self, reviews.size(), 2, "Expected two review nodes from xpath()"):
		return

	T.pass_and_quit(self)
