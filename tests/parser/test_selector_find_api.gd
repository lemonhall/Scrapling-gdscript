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

	if not T.require_true(self, page.has_method("find"), "Selector must expose find()"):
		return
	if not T.require_true(self, page.has_method("find_all"), "Selector must expose find_all()"):
		return

	var first_review: Variant = page.call("find", "div", {"class": "review"})
	if not T.require_true(self, first_review != null, "find() must return first matching review"):
		return
	if not T.require_eq(self, first_review.call("attrib", "data-rating"), "5", "find() should return the first review"):
		return

	var all_reviews: Variant = page.call("find_all", "div", {"class": "review"})
	if not T.require_true(self, all_reviews is Array, "find_all() must return Array"):
		return
	if not T.require_eq(self, all_reviews.size(), 2, "find_all() must return two reviews"):
		return

	var product_list: Variant = page.call("css", ".product-list")[0]
	var child: Variant = product_list.call("find", {"data-id": "1"})
	if not T.require_true(self, child != null, "find() must support attribute dictionary lookup"):
		return
	if not T.require_eq(self, child.call("attrib", "data-id"), "1", "Unexpected attribute dictionary lookup result"):
		return

	T.pass_and_quit(self)
