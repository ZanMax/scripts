import requests
import re

import urllib3

urllib3.disable_warnings()

with open('urls1.txt') as f:
    urls = f.readlines()

for channel_url in urls:
    s = requests.session()
    s.headers.update({
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6)'
                      'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.5', 'DNT': '1', 'Connection': 'keep-alive', 'Accept-Encoding': 'identity'})

    r = s.get(channel_url, verify=False, allow_redirects=True)

    if 'yt-formatted-string' in r.text:
        emails = re.findall(r'[\w\.-]+@[\w\.-]+', r.text)

        if len(emails) > 0:
            print str(channel_url).replace('\n', '') + ' --> ' + ', '.join(str(e) for e in emails)
    else:
        print 'email not found'
