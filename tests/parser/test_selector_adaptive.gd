extends SceneTree

const T := preload("res://tests/_test_util.gd")

func _init() -> void:
	var selector_script := load("res://addons/scrapling/parser/Selector.gd")
	if not T.require_true(self, selector_script != null, "Failed to load res://addons/scrapling/parser/Selector.gd"):
		return

	var original_html := """
	<div class=\"container\">
		<section class=\"products\">
			<article class=\"product\" id=\"p1\">
				<h3>Product 1</h3>
				<p class=\"description\">Description 1</p>
			</article>
			<article class=\"product\" id=\"p2\">
				<h3>Product 2</h3>
				<p class=\"description\">Description 2</p>
			</article>
		</section>
	</div>
	"""
	var changed_html := """
	<div class=\"new-container\">
		<div class=\"product-wrapper\">
			<section class=\"products\">
				<article class=\"product new-class\" data-id=\"p1\">
					<div class=\"product-info\">
						<h3>Product 1</h3>
						<p class=\"new-description\">Description 1</p>
					</div>
				</article>
				<article class=\"product new-class\" data-id=\"p2\">
					<div class=\"product-info\">
						<h3>Product 2</h3>
						<p class=\"new-description\">Description 2</p>
					</div>
				</article>
			</section>
		</div>
	</div>
	"""

	var old_page: Variant = selector_script.new(original_html, {}, {}, "example.com")
	var new_page: Variant = selector_script.new(changed_html, {}, {}, "example.com")
	if not T.require_true(self, old_page != null and new_page != null, "Adaptive test pages must instantiate"):
		return

	var saved: Variant = old_page.call("css", "#p1, #p2", true, false)
	if not T.require_true(self, saved is Array, "css(auto_save=true) must still return Array"):
		return
	if not T.require_eq(self, saved.size(), 2, "Expected two saved product nodes"):
		return

	var relocated: Variant = new_page.call("css", "#p1", false, true)
	if not T.require_true(self, relocated is Array, "css(adaptive=true) must return Array"):
		return
	if not T.require_eq(self, relocated.size(), 1, "Adaptive css must relocate one node"):
		return
	if not T.require_eq(self, relocated[0].call("attrib", "data-id"), "p1", "Adaptive relocation must recover first product"):
		return
	if not T.require_true(self, String(relocated[0].call("text")).contains("Description 1"), "Relocated node must preserve semantic text match"):
		return

	T.pass_and_quit(self)
