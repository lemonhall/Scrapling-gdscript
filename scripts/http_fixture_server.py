from http.server import BaseHTTPRequestHandler, HTTPServer
from http.cookies import SimpleCookie
import argparse
import json
import time
from urllib.parse import parse_qs, urlparse

MODE = "origin"
PROXY_LABEL = "proxy"


class Handler(BaseHTTPRequestHandler):
    def _send(self, status: int, body: bytes, content_type: str = "application/json; charset=utf-8", extra_headers: dict | None = None) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        if extra_headers:
            for key, value in extra_headers.items():
                self.send_header(key, value)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        parsed = urlparse(self.path)
        if MODE == "proxy":
            if parsed.path == "/proxy-check":
                payload = json.dumps({
                    "via_proxy": True,
                    "proxy_label": PROXY_LABEL,
                    "target": self.path,
                    "method": "GET",
                }).encode("utf-8")
                self._send(200, payload)
                return
            payload = json.dumps({"error": "proxy route not found", "path": self.path}).encode("utf-8")
            self._send(404, payload)
            return
        if parsed.path == "/hello":
            payload = json.dumps({"message": "hello from fixture"}).encode("utf-8")
            self._send(200, payload)
            return
        if parsed.path == "/inspect":
            query = {
                key: values[-1] if len(values) == 1 else values
                for key, values in parse_qs(parsed.query).items()
            }
            headers = {}
            for key, value in self.headers.items():
                if key.lower().startswith("x-"):
                    headers[key] = value
            payload = json.dumps({"query": query, "headers": headers}).encode("utf-8")
            self._send(200, payload)
            return
        if parsed.path == "/set-cookie":
            payload = json.dumps({"set": True, "name": "session_id"}).encode("utf-8")
            self._send(200, payload, extra_headers={"Set-Cookie": "session_id=abc123; Path=/"})
            return
        if parsed.path == "/slow":
            delay = 1.0
            query = parse_qs(parsed.query)
            if "delay" in query and len(query["delay"]) > 0:
                try:
                    delay = float(query["delay"][-1])
                except ValueError:
                    delay = 1.0
            time.sleep(delay)
            payload = json.dumps({"slow": True, "delay": delay}).encode("utf-8")
            self._send(200, payload)
            return
        if parsed.path == "/check-cookie":
            cookie = SimpleCookie()
            cookie.load(self.headers.get("Cookie", ""))
            session_id = ""
            if "session_id" in cookie:
                session_id = cookie["session_id"].value
            payload = json.dumps({"session_id": session_id}).encode("utf-8")
            self._send(200, payload)
            return
        payload = json.dumps({"error": "not found", "path": self.path}).encode("utf-8")
        self._send(404, payload)

    def do_POST(self):
        if self.path == "/echo":
            self._send(200, json.dumps(self._read_json_payload()).encode("utf-8"))
            return
        payload = json.dumps({"error": "not found", "path": self.path}).encode("utf-8")
        self._send(404, payload)

    def do_PUT(self):
        if self.path == "/echo":
            self._send(200, json.dumps(self._read_json_payload()).encode("utf-8"))
            return
        payload = json.dumps({"error": "not found", "path": self.path}).encode("utf-8")
        self._send(404, payload)

    def do_DELETE(self):
        if self.path == "/delete":
            payload = json.dumps({"deleted": True, "path": self.path}).encode("utf-8")
            self._send(200, payload)
            return
        payload = json.dumps({"error": "not found", "path": self.path}).encode("utf-8")
        self._send(404, payload)

    def _read_json_payload(self):
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length) if length > 0 else b""
        try:
            return json.loads(raw.decode("utf-8") or "{}")
        except json.JSONDecodeError:
            return {"raw": raw.decode("utf-8", errors="replace")}

    def log_message(self, format, *args):
        return


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--mode", choices=["origin", "proxy"], default="origin")
    parser.add_argument("--label", default="proxy")
    args = parser.parse_args()
    MODE = args.mode
    PROXY_LABEL = args.label
    server = HTTPServer((args.host, args.port), Handler)
    server.serve_forever()
