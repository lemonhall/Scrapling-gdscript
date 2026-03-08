extends RefCounted
class_name Selector

var _document_root: Dictionary = {}
var _current_node: Dictionary = {}
var _source_url := ""
static var _adaptive_registry: Dictionary = {}


func _init(html: String = "", current_node: Dictionary = {}, document_root: Dictionary = {}, source_url: String = "") -> void:
	_source_url = source_url
	if not current_node.is_empty() and not document_root.is_empty():
		_current_node = current_node
		_document_root = document_root
		return
	_document_root = _parse_html(html)
	_current_node = _document_root


func css(selector: String, auto_save: bool = false, adaptive: bool = false) -> Array:
	var direct_nodes := _css_select(selector)
	if auto_save:
		_save_adaptive_snapshots(selector, direct_nodes)
	if direct_nodes.size() > 0:
		return _wrap_nodes(direct_nodes)
	if adaptive:
		return _wrap_nodes(_relocate_saved_selector(selector))
	return []


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


func find_by_text(query: String, partial: bool = false, first_match: bool = true) -> Variant:
	var matches := _find_leaf_text_matches(_current_node, query, partial, false)
	var wrapped := _wrap_nodes(matches)
	if first_match:
		return wrapped[0] if wrapped.size() > 0 else null
	return wrapped


func find_by_regex(pattern: String, first_match: bool = true) -> Variant:
	var matches := _find_leaf_text_matches(_current_node, pattern, false, true)
	var wrapped := _wrap_nodes(matches)
	if first_match:
		return wrapped[0] if wrapped.size() > 0 else null
	return wrapped


func re(pattern: String) -> Array:
	var regex := RegEx.new()
	var err := regex.compile(pattern)
	if err != OK:
		return []
	var matches: Array = []
	for match in regex.search_all(text()):
		matches.append(match.get_string())
	return matches


func re_first(pattern: String) -> Variant:
	var matches := re(pattern)
	return matches[0] if matches.size() > 0 else null


func get_text(default = null):
	var value := text().strip_edges()
	if value == "" and default != null:
		return default
	return value


func get_all_text() -> Array:
	return [get_text(null)]


func html_content() -> String:
	var parts: Array = []
	for child in _current_node.get("children", []):
		parts.append(_node_to_html(child))
	return "".join(parts)


func attrib(name: String = "") -> Variant:
	var attrs: Dictionary = _current_node.get("attrs", {})
	if name == "":
		return attrs
	return attrs.get(name)


func find(query = null, attrs: Dictionary = {}) -> Variant:
	var results := find_all(query, attrs)
	return results[0] if results.size() > 0 else null


func find_all(query = null, attrs: Dictionary = {}) -> Array:
	var wanted_tag := ""
	var wanted_attrs: Dictionary = attrs.duplicate()
	if query is String:
		wanted_tag = String(query).to_lower()
	elif query is Dictionary and wanted_attrs.is_empty():
		wanted_attrs = (query as Dictionary).duplicate()
	var matches: Array = []
	for node in _all_descendants(_current_node):
		if wanted_tag != "" and String((node as Dictionary).get("tag", "")) != wanted_tag:
			continue
		if not _matches_attrs(node, wanted_attrs):
			continue
		matches.append(node)
	return _wrap_nodes(matches)


func find_similar() -> Array:
	var parent_node: Variant = _current_node.get("parent")
	if parent_node == null:
		return []
	var wanted_tag := String(_current_node.get("tag", ""))
	var wanted_classes := _class_tokens(_current_node)
	var items: Array = []
	for sibling in (parent_node as Dictionary).get("children", []):
		if sibling == _current_node:
			continue
		if String((sibling as Dictionary).get("tag", "")) != wanted_tag:
			continue
		if _class_tokens(sibling) != wanted_classes:
			continue
		items.append(sibling)
	return _wrap_nodes(items)


func parent() -> Variant:
	var parent_node: Variant = _current_node.get("parent")
	if parent_node == null:
		return null
	if String((parent_node as Dictionary).get("tag", "")) == "document":
		return null
	return self.get_script().new("", parent_node, _document_root, _source_url)


func children() -> Array:
	return _wrap_nodes(_current_node.get("children", []))


func siblings() -> Array:
	var parent_node: Variant = _current_node.get("parent")
	if parent_node == null:
		return []
	var items: Array = []
	for sibling in (parent_node as Dictionary).get("children", []):
		if sibling != _current_node:
			items.append(sibling)
	return _wrap_nodes(items)


func previous() -> Variant:
	var parent_node: Variant = _current_node.get("parent")
	if parent_node == null:
		return null
	var children_nodes: Array = (parent_node as Dictionary).get("children", [])
	var index := children_nodes.find(_current_node)
	if index <= 0:
		return null
	return self.get_script().new("", children_nodes[index - 1], _document_root, _source_url)


func next() -> Variant:
	var parent_node: Variant = _current_node.get("parent")
	if parent_node == null:
		return null
	var children_nodes: Array = (parent_node as Dictionary).get("children", [])
	var index := children_nodes.find(_current_node)
	if index < 0 or index + 1 >= children_nodes.size():
		return null
	return self.get_script().new("", children_nodes[index + 1], _document_root, _source_url)


func _wrap_nodes(nodes: Array) -> Array:
	var wrapped: Array = []
	for node in nodes:
		wrapped.append(self.get_script().new("", node, _document_root, _source_url))
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
			var text_value := String(parser.get_node_data())
			if text_value.strip_edges() != "":
				var target: Dictionary = stack[stack.size() - 1]
				var segments: Array = target.get("text_segments", [])
				segments.append(text_value)
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
		"parent": null,
	}


func _append_child(parent: Dictionary, child: Dictionary) -> void:
	child["parent"] = parent
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


func _find_leaf_text_matches(node: Dictionary, pattern: String, partial: bool, regex_mode: bool) -> Array:
	var child_matches: Array = []
	for child in node.get("children", []):
		child_matches.append_array(_find_leaf_text_matches(child, pattern, partial, regex_mode))
	if String(node.get("tag", "")) == "document":
		return child_matches
	var text_value := _collect_text(node).strip_edges()
	var matched := _text_matches(text_value, pattern, partial, regex_mode)
	if matched and child_matches.is_empty():
		return [node]
	return child_matches


func _text_matches(text_value: String, pattern: String, partial: bool, regex_mode: bool) -> bool:
	if regex_mode:
		var regex := RegEx.new()
		var err := regex.compile(pattern)
		if err != OK:
			return false
		return regex.search(text_value) != null
	if partial:
		return text_value.contains(pattern)
	return text_value == pattern


func _node_to_html(node: Dictionary) -> String:
	var parts: Array = []
	var tag := String(node.get("tag", ""))
	if tag != "":
		parts.append("<" + tag)
		var attrs: Dictionary = node.get("attrs", {})
		for key in attrs.keys():
			parts.append(" %s=\"%s\"" % [String(key), String(attrs[key])])
		parts.append(">")
	for segment in node.get("text_segments", []):
		parts.append(String(segment))
	for child in node.get("children", []):
		parts.append(_node_to_html(child))
	if tag != "":
		parts.append("</" + tag + ">")
	return "".join(parts)


func _all_descendants(node: Dictionary) -> Array:
	var results: Array = []
	for child in node.get("children", []):
		results.append(child)
		results.append_array(_all_descendants(child))
	return results


func _matches_attrs(node: Dictionary, wanted_attrs: Dictionary) -> bool:
	if wanted_attrs.is_empty():
		return true
	var attrs: Dictionary = node.get("attrs", {})
	for key in wanted_attrs.keys():
		if String(attrs.get(String(key), "")) != String(wanted_attrs[key]):
			return false
	return true


func _class_tokens(node: Dictionary) -> Array:
	var attrs: Dictionary = node.get("attrs", {})
	var class_value := String(attrs.get("class", ""))
	if class_value == "":
		return []
	var tokens: Array = []
	for class_token in class_value.split(" ", false):
		if class_token != "":
			tokens.append(class_token)
	return tokens


func _css_select(selector: String) -> Array:
	var merged: Array = []
	for raw_part in selector.split(",", false):
		var part := String(raw_part).strip_edges()
		if part == "":
			continue
		var tokens := _parse_css_selector(part)
		var current_nodes: Array = [_current_node]
		for token in tokens:
			var next_nodes: Array = []
			for node in current_nodes:
				next_nodes.append_array(_find_descendants_for_css(node, token))
			current_nodes = next_nodes
		for node in current_nodes:
			if merged.find(node) < 0:
				merged.append(node)
	return merged


func _save_adaptive_snapshots(selector: String, nodes: Array) -> void:
	if _source_url == "":
		return
	if not _adaptive_registry.has(_source_url):
		_adaptive_registry[_source_url] = {}
	var bucket: Dictionary = _adaptive_registry[_source_url]
	for node in nodes:
		var snapshot := _build_snapshot(node)
		for key in _snapshot_keys(selector, node):
			bucket[key] = snapshot
	_adaptive_registry[_source_url] = bucket


func _snapshot_keys(selector: String, node: Dictionary) -> Array:
	var keys: Array = [selector]
	var attrs: Dictionary = node.get("attrs", {})
	var node_id := String(attrs.get("id", ""))
	var data_id := String(attrs.get("data-id", ""))
	if node_id != "":
		keys.append("#" + node_id)
	if data_id != "":
		keys.append("#" + data_id)
	return keys


func _build_snapshot(node: Dictionary) -> Dictionary:
	var attrs: Dictionary = node.get("attrs", {})
	return {
		"tag": String(node.get("tag", "")),
		"attrs": attrs.duplicate(),
		"classes": _class_tokens(node),
		"text": _collect_text(node).strip_edges(),
	}


func _relocate_saved_selector(selector: String) -> Array:
	if _source_url == "":
		return []
	if not _adaptive_registry.has(_source_url):
		return []
	var bucket: Dictionary = _adaptive_registry[_source_url]
	if not bucket.has(selector):
		return []
	var snapshot: Dictionary = bucket[selector]
	var best := _find_best_adaptive_match(snapshot)
	if best == null:
		return []
	return [best]


func _find_best_adaptive_match(snapshot: Dictionary) -> Variant:
	var best_node: Variant = null
	var best_score := -1
	for node in _all_descendants(_current_node):
		var score := _adaptive_score(node, snapshot)
		if score > best_score:
			best_score = score
			best_node = node
	if best_score <= 0:
		return null
	return best_node


func _adaptive_score(node: Dictionary, snapshot: Dictionary) -> int:
	var score := 0
	var node_tag := String(node.get("tag", ""))
	if node_tag == String(snapshot.get("tag", "")):
		score += 4
	var attrs: Dictionary = node.get("attrs", {})
	var snap_attrs: Dictionary = snapshot.get("attrs", {})
	var snap_id := String(snap_attrs.get("id", ""))
	var snap_data_id := String(snap_attrs.get("data-id", ""))
	if snap_id != "":
		if String(attrs.get("id", "")) == snap_id:
			score += 12
		if String(attrs.get("data-id", "")) == snap_id:
			score += 10
	if snap_data_id != "":
		if String(attrs.get("data-id", "")) == snap_data_id:
			score += 12
		if String(attrs.get("id", "")) == snap_data_id:
			score += 10
	var node_classes := _class_tokens(node)
	for class_token in snapshot.get("classes", []):
		if node_classes.has(class_token):
			score += 2
	var node_text := _collect_text(node).strip_edges()
	var snap_text := String(snapshot.get("text", ""))
	if node_text == snap_text and snap_text != "":
		score += 6
	elif snap_text != "" and node_text.contains(snap_text):
		score += 3
	elif snap_text != "" and snap_text.contains(node_text) and node_text != "":
		score += 2
	return score
