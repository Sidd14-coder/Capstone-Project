import urllib.request
import json
import ssl

ssl._create_default_https_context = ssl._create_unverified_context
api_key = 'AIzaSyA4bk6ldx1e1e0-NMfykDun6L8c4c6t58E'
models = ['gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-pro', 'gemini-1.0-pro']

with open('out.txt', 'w', encoding='utf-8') as f:
    for model in models:
        url = f'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}'
        req = urllib.request.Request(url, method='POST')
        req.add_header('Content-Type', 'application/json')
        data = json.dumps({"contents": [{"parts": [{"text": "hello"}]}]}).encode('utf-8')
        try:
            r = urllib.request.urlopen(req, data=data)
            f.write(f'{model} => {r.getcode()}\n')
        except urllib.error.HTTPError as e:
            body = e.read().decode('utf-8')
            try:
                err = json.loads(body)['error']['message']
            except:
                err = body
            f.write(f'{model} => {e.code} Error: {err}\n')
        except Exception as e:
            f.write(f'{model} => Exception: {e}\n')
