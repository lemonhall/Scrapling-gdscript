from http.server import BaseHTTPRequestHandler, HTTPServer
import argparse
import json
from urllib.parse import parse_qs, urlparse


class Handler(BaseHTTPRequestHandler):
    def _send(self, status: int, body: bytes, content_type: str = "application/json; charset=utf-8") -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        parsed = urlparse(self.path)
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
            token = self.headers.get("X-Test-Token")
            if token is not None:
                headers["X-Test-Token"] = token
            payload = json.dumps({"query": query, "headers": headers}).encode("utf-8")
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
    args = parser.parse_args()
    server = HTTPServer((args.host, args.port), Handler)
    server.serve_forever()
