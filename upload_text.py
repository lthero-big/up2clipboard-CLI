import sys
import requests
import argparse

def send_text(text_url, data, room):
    text_url += f"?room={room}"
    headers = {'Content-Type': 'text/plain; charset=utf-8'}
    response = requests.post(text_url, data=data.encode('utf-8'), headers=headers)
    return response

def main():
    parser = argparse.ArgumentParser(description='Send text to a specified room via the web API.')
    parser.add_argument('data', nargs='*', type=str, help='The text data to send directly as arguments.')
    parser.add_argument('--room', type=str, default="", help='The name of the room (optional).')
    args = parser.parse_args()
    upload_url = 'https://clip.domain.com'
    text_url = upload_url + '/text'

    if args.data:
        for data in args.data:
            response = send_text(text_url, data, args.room)
            if response.status_code == 200:
                print(f"Successfully sent: {data}")
            else:
                print(f"Failed to send, status code {response.status_code}: {response.text}, content: {data}")
    elif not sys.stdin.isatty():
        data = sys.stdin.read().strip()
        if data:
            response = send_text(text_url, data, args.room)
            if response.status_code == 200:
                print(f"Successfully sent: {data}")
            else:
                print(f"Failed to send, status code {response.status_code}: {response.text}")
    else:
        print("No data to send was received. Please provide data through standard input or arguments.")

if __name__ == '__main__':
    main()
