from http.server import BaseHTTPRequestHandler, HTTPServer
import argparse
import json


class Handler(BaseHTTPRequestHandler):
    def _send(self, status: int, body: bytes, content_type: str = "application/json; charset=utf-8") -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/hello":
            payload = json.dumps({"message": "hello from fixture"}).encode("utf-8")
            self._send(200, payload)
            return
        payload = json.dumps({"error": "not found", "path": self.path}).encode("utf-8")
        self._send(404, payload)

    def log_message(self, format, *args):
        return


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    server = HTTPServer((args.host, args.port), Handler)
    server.serve_forever()
