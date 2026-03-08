extends RefCounted
class_name Fetcher

const FetcherResponseScript := preload("res://addons/scrapling/fetchers/FetcherResponse.gd")
const STATUS_MARKER := "__STATUS__"


func fetch_get(url: String) -> Variant:
	var output: Array = []
	var exit_code := OS.execute("curl.exe", ["-sS", "-w", STATUS_MARKER + "%{http_code}", url], output, true)
	if exit_code != 0:
		return FetcherResponseScript.new(0, "")
	var combined := "".join(output)
	var marker_index := combined.rfind(STATUS_MARKER)
	if marker_index < 0:
		return FetcherResponseScript.new(0, combined)
	var body := combined.substr(0, marker_index)
	var status_text := combined.substr(marker_index + STATUS_MARKER.length())
	return FetcherResponseScript.new(int(status_text), body)
