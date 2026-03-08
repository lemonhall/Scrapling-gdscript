extends RefCounted
class_name Selector

var _document_root: Dictionary = {}
var _current_node: Dictionary = {}


func _init(html: String = "", current_node: Dictionary = {}, document_root: Dictionary = {}) -> void:
	if not current_node.is_empty() and not document_root.is_empty():
		_current_node = current_node
		_document_root = document_root
		return
	_document_root = _parse_html(html)
	_current_node = _document_root


func css(selector: String) -> Array:
	var tokens := _parse_css_selector(selector)
	var current_nodes: Array = [_current_node]
	for token in tokens:
		var next_nodes: Array = []
		for node in current_nodes:
			next_nodes.append_array(_find_descendants_for_css(node, token))
		current_nodes = next_nodes
	return _wrap_nodes(current_nodes)


func xpath(path: String) -> Array:
	var steps := _parse_xpath(path)
	var current_nodes: Array = [_current_node]
	for step in steps:
		var next_nodes: Array = []
		for node in current_nodes:
			next_nodes.append_array(_find_descendants_for_xpath(node, step))
		current_nodes = next_nodes
	return _wrap_nodes(current_nodes)


func text() -> String:
	return _collect_text(_current_node).strip_edges()


func attrib(name: String = "") -> Variant:
	var attrs: Dictionary = _current_node.get("attrs", {})
	if name == "":
		return attrs
	return attrs.get(name)


func _wrap_nodes(nodes: Array) -> Array:
	var wrapped: Array = []
	for node in nodes:
		wrapped.append(self.get_script().new("", node, _document_root))
	return wrapped


func _parse_html(html: String) -> Dictionary:
	var parser := XMLParser.new()
	var root := _make_node("document", {})
	var stack: Array = [root]
	var err := parser.open_buffer(html.to_utf8_buffer())
	if err != OK:
		return root
	while true:
		err = parser.read()
		if err != OK:
			break
		var node_type := parser.get_node_type()
		if node_type == XMLParser.NODE_ELEMENT:
			var attrs := {}
			for index in range(parser.get_attribute_count()):
				attrs[parser.get_attribute_name(index)] = parser.get_attribute_value(index)
			var node := _make_node(String(parser.get_node_name()).to_lower(), attrs)
			_append_child(stack[stack.size() - 1], node)
			if not parser.is_empty():
				stack.append(node)
		elif node_type == XMLParser.NODE_TEXT:
			var text := String(parser.get_node_data())
			if text.strip_edges() != "":
				var target: Dictionary = stack[stack.size() - 1]
				var segments: Array = target.get("text_segments", [])
				segments.append(text)
				target["text_segments"] = segments
		elif node_type == XMLParser.NODE_ELEMENT_END:
			if stack.size() > 1:
				stack.pop_back()
	return root


func _make_node(tag: String, attrs: Dictionary) -> Dictionary:
	return {
		"tag": tag,
		"attrs": attrs.duplicate(),
		"children": [],
		"text_segments": [],
	}


func _append_child(parent: Dictionary, child: Dictionary) -> void:
	var children: Array = parent.get("children", [])
	children.append(child)
	parent["children"] = children


func _parse_css_selector(selector: String) -> Array:
	var tokens: Array = []
	for raw_token in selector.split(" ", false):
		var token := String(raw_token).strip_edges()
		if token == "":
			continue
		tokens.append(_parse_css_token(token))
	return tokens


func _parse_css_token(token: String) -> Dictionary:
	var tag := ""
	var id := ""
	var classes: Array = []
	var part := ""
	var mode := "tag"
	for index in range(token.length()):
		var ch := token.substr(index, 1)
		if ch == "#" or ch == ".":
			if part != "":
				if mode == "tag":
					tag = part
				elif mode == "id":
					id = part
				else:
					classes.append(part)
			part = ""
			mode = "id" if ch == "#" else "class"
		else:
			part += ch
	if part != "":
		if mode == "tag":
			tag = part
		elif mode == "id":
			id = part
		else:
			classes.append(part)
	return {
		"tag": tag.to_lower(),
		"id": id,
		"classes": classes,
	}


func _find_descendants_for_css(node: Dictionary, token: Dictionary) -> Array:
	var results: Array = []
	for child in node.get("children", []):
		if _matches_css_token(child, token):
			results.append(child)
		results.append_array(_find_descendants_for_css(child, token))
	return results


func _matches_css_token(node: Dictionary, token: Dictionary) -> bool:
	var tag := String(token.get("tag", ""))
	if tag != "" and String(node.get("tag", "")) != tag:
		return false
	var wanted_id := String(token.get("id", ""))
	var attrs: Dictionary = node.get("attrs", {})
	if wanted_id != "" and String(attrs.get("id", "")) != wanted_id:
		return false
	for wanted_class in token.get("classes", []):
		if not _has_class(node, String(wanted_class)):
			return false
	return true


func _has_class(node: Dictionary, wanted_class: String) -> bool:
	var attrs: Dictionary = node.get("attrs", {})
	var class_value := String(attrs.get("class", ""))
	if class_value == "":
		return false
	for class_token in class_value.split(" ", false):
		if class_token == wanted_class:
			return true
	return false


func _parse_xpath(path: String) -> Array:
	var steps: Array = []
	for raw_part in path.split("//", false):
		var part := String(raw_part).strip_edges()
		if part == "":
			continue
		steps.append(_parse_xpath_step(part))
	return steps


func _parse_xpath_step(part: String) -> Dictionary:
	var tag := part
	var predicates: Array = []
	var bracket_index := part.find("[")
	if bracket_index >= 0:
		tag = part.substr(0, bracket_index)
		var remainder := part.substr(bracket_index)
		while remainder.begins_with("["):
			var end_index := remainder.find("]")
			if end_index < 0:
				break
			predicates.append(remainder.substr(1, end_index - 1))
			remainder = remainder.substr(end_index + 1)
	return {
		"tag": tag.to_lower(),
		"predicates": predicates,
	}


func _find_descendants_for_xpath(node: Dictionary, step: Dictionary) -> Array:
	var results: Array = []
	for child in node.get("children", []):
		if _matches_xpath_step(child, step):
			results.append(child)
		results.append_array(_find_descendants_for_xpath(child, step))
	return results


func _matches_xpath_step(node: Dictionary, step: Dictionary) -> bool:
	if String(node.get("tag", "")) != String(step.get("tag", "")):
		return false
	for predicate in step.get("predicates", []):
		if not _matches_xpath_predicate(node, String(predicate)):
			return false
	return true


func _matches_xpath_predicate(node: Dictionary, predicate: String) -> bool:
	var attrs: Dictionary = node.get("attrs", {})
	if predicate.begins_with('@id="') and predicate.ends_with('"'):
		var expected_id := predicate.substr(5, predicate.length() - 6)
		return String(attrs.get("id", "")) == expected_id
	if predicate.begins_with('contains(@class, "') and predicate.ends_with('")'):
		var needle := predicate.substr(18, predicate.length() - 20)
		return String(attrs.get("class", "")).contains(needle)
	return false


func _collect_text(node: Dictionary) -> String:
	var parts: Array = []
	for segment in node.get("text_segments", []):
		parts.append(String(segment))
	for child in node.get("children", []):
		parts.append(_collect_text(child))
	return " ".join(parts).strip_edges()



