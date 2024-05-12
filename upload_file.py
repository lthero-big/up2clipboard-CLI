import requests
import os
import argparse
from tqdm import tqdm

def upload_file(url, file_paths, room):
    for file_path in file_paths:
        file_name = os.path.basename(file_path)
        file_size = os.path.getsize(file_path)

        # Initialize the upload
        init_response = requests.post(f'{url}/upload', data=file_name, headers={'Content-Type': 'text/plain'})
        if init_response.status_code != 200:
            print(f"Initialization failed: {file_name}, {init_response.text}")
            continue

        uuid = init_response.json()['result']['uuid']

        # Upload the file in chunks
        chunk_size = 12582912  # 12MB
        with open(file_path, 'rb') as f, tqdm(total=file_size, unit='B', unit_scale=True, desc=file_name) as progress:
            uploaded_size = 0
            while uploaded_size < file_size:
                chunk = f.read(chunk_size)
                chunk_response = requests.post(f'{url}/upload/chunk/{uuid}', data=chunk, headers={'Content-Type': 'application/octet-stream'})
                if chunk_response.status_code != 200:
                    print(f"Chunk upload failed: {file_name}, {chunk_response.text}")
                    break
                chunk_size = len(chunk)
                uploaded_size += chunk_size
                progress.update(chunk_size)

        # Complete the upload
        finish_response = requests.post(f'{url}/upload/finish/{uuid}', params={'room': room})
        if finish_response.status_code != 200:
            print(f"Finalization failed: {file_name}, {finish_response.text}")
        else:
            print(f"File uploaded successfully: {file_name}")

def main():
    parser = argparse.ArgumentParser(description='File Upload Script')
    parser.add_argument('file_paths', type=str, nargs='+', help='Path(s) to the files to be uploaded')
    parser.add_argument('--room', type=str, default='', help='Room name for the upload context (optional)')

    args = parser.parse_args()

    upload_url = 'https://clip.domain.com'
    upload_file(upload_url, args.file_paths, args.room)

if __name__ == '__main__':
    main()
