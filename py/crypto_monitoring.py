import requests
from bs4 import BeautifulSoup

url_list = {'BitCOIN': 'https://coinmarketcap.com/currencies/bitcoin/',
            'Ripple - XRP': 'https://coinmarketcap.com/currencies/ripple/'}


def get_crypto_info(name, url):
    headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko)'
                      ' Chrome/70.0.3538.102 Safari/537.36'}

    r = requests.get(url, headers=headers)
    soup = BeautifulSoup(r.text, 'html.parser')
    span_price = soup.find("span", {'class': 'h2 text-semi-bold details-panel-item--price__value'})
    span_dynamics = soup.find("span", {'class': 'h2 text-semi-bold negative_change'})

    result = name + ' ' + (
            '$' + span_price.text.strip() + '  ' + span_dynamics.text.strip().replace('(', '').replace(')', ''))
    return result


for name, url in url_list.items():
    print(get_crypto_info(name, url))
