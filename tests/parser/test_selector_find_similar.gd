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
	var first_product: Variant = products[0]
	if not T.require_true(self, first_product.has_method("find_similar"), "Selector must expose find_similar()"):
		return
	var similar_products: Variant = first_product.call("find_similar")
	if not T.require_true(self, similar_products is Array, "find_similar() must return Array"):
		return
	if not T.require_eq(self, similar_products.size(), 2, "First product must find two similar product siblings"):
		return
	if not T.require_eq(self, similar_products[0].call("attrib", "data-id"), "2", "First similar product should be data-id=2"):
		return
	if not T.require_eq(self, similar_products[1].call("attrib", "data-id"), "3", "Second similar product should be data-id=3"):
		return

	var reviews: Variant = page.call("css", "div.review")
	var first_review: Variant = reviews[0]
	var similar_reviews: Variant = first_review.call("find_similar")
	if not T.require_eq(self, similar_reviews.size(), 1, "First review must find one similar review sibling"):
		return
	if not T.require_eq(self, similar_reviews[0].call("attrib", "data-rating"), "4", "Similar review must be the second review"):
		return

	T.pass_and_quit(self)
