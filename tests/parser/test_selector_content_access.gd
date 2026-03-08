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
	if not T.require_true(self, first_price.has_method("get"), "Selector must expose get()"):
		return
	if not T.require_true(self, first_price.has_method("getall"), "Selector must expose getall()"):
		return
	if not T.require_true(self, first_price.has_method("html_content"), "Selector must expose html_content()"):
		return

	if not T.require_eq(self, String(first_price.call("get")).strip_edges(), "$10.99", "Unexpected get() result for first price"):
		return
	var all_values: Variant = first_price.call("getall")
	if not T.require_true(self, all_values is Array, "getall() must return Array"):
		return
	if not T.require_eq(self, all_values.size(), 1, "getall() must return one value for single node"):
		return
	if not T.require_eq(self, String(all_values[0]).strip_edges(), "$10.99", "Unexpected getall()[0] result"):
		return

	var products: Variant = page.call("css", "article.product")
	var first_product: Variant = products[0]
	var inner_html := String(first_product.call("html_content"))
	if not T.require_true(self, inner_html.contains("<h3>Product 1</h3>"), "html_content() must include child heading HTML"):
		return
	if not T.require_true(self, inner_html.contains("<span class=\"price\">$10.99</span>"), "html_content() must include child price HTML"):
		return

	T.pass_and_quit(self)
