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

	var products: Variant = page.call("css", "article.product")
	if not T.require_eq(self, products.size(), 3, "Expected three product nodes"):
		return

	var first_product: Variant = products[0]
	if not T.require_eq(self, first_product.call("attrib", "data-id"), "1", "Unexpected data-id on first product"):
		return
	if not T.require_true(self, String(first_product.call("text")).contains("Product 1"), "First product text must include heading"):
		return
	if not T.require_true(self, String(first_product.call("text")).contains("This is product 1"), "First product text must include description"):
		return
	if not T.require_true(self, String(first_product.call("text")).contains("$10.99"), "First product text must include price"):
		return

	if not T.require_true(self, first_product.has_method("parent"), "Selector must expose parent()"):
		return
	var product_parent: Variant = first_product.call("parent")
	if not T.require_true(self, product_parent != null, "First product must have parent node"):
		return
	if not T.require_eq(self, product_parent.call("attrib", "class"), "product-list", "Unexpected parent class for first product"):
		return

	if not T.require_true(self, product_parent.has_method("children"), "Selector must expose children()"):
		return
	var parent_children: Variant = product_parent.call("children")
	if not T.require_eq(self, parent_children.size(), 3, "product-list must have three direct children"):
		return

	if not T.require_true(self, first_product.has_method("siblings"), "Selector must expose siblings()"):
		return
	var siblings: Variant = first_product.call("siblings")
	if not T.require_eq(self, siblings.size(), 2, "First product must have two siblings"):
		return

	var second_product: Variant = products[1]
	if not T.require_true(self, second_product.has_method("previous"), "Selector must expose previous()"):
		return
	if not T.require_true(self, second_product.has_method("next"), "Selector must expose next()"):
		return
	var previous_product: Variant = second_product.call("previous")
	var next_product: Variant = second_product.call("next")
	if not T.require_eq(self, previous_product.call("attrib", "data-id"), "1", "Second product previous() must resolve first product"):
		return
	if not T.require_eq(self, next_product.call("attrib", "data-id"), "3", "Second product next() must resolve third product"):
		return

	T.pass_and_quit(self)
