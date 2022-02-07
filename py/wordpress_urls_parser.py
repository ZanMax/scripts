import requests
from BeautifulSoup import BeautifulSoup
from urlparse import urlparse

with open('domains.txt') as f:
    lines = f.readlines()

for line in lines:
    login_info = line.split(';')
    domain = urlparse(login_info[0]).hostname
    domain_url = urlparse(login_info[0]).scheme + '://' + domain
    domain_user = login_info[1]
    domain_pass = login_info[2]

    full_admin_path = domain_url + '/wp-login.php'

    s = requests.session()
    s.headers.update({
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6)'
                      'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.5', 'DNT': '1', 'Connection': 'keep-alive', 'Accept-Encoding': 'identity'})

    try:
        r = s.get(full_admin_path, verify=False)
    except Exception as e:
        print e
        continue

    if r.status_code == 200:
        try:
            r = s.post(full_admin_path,
                       data={'log': domain_user, 'pwd': domain_pass, 'redirect_to': domain_url + '/wp-admin/',
                             'testcookie': '1'}, allow_redirects=True, verify=False)
        except Exception as e:
            print e
            continue

        if r.status_code == 200:
            try:
                params = s.get(domain_url + '/wp-admin/edit.php', verify=False)

                screen_optionnonce = BeautifulSoup(params.text).find('input', {'id': 'screenoptionnonce'}).get('value')

                r = s.post(domain_url + '/wp-admin/edit.php',
                           data={'author-hide': 'author', 'categories-hide': 'categories', 'tags-hide': 'tags',
                                 'comments-hide': 'comments',
                                 'date-hide': 'date', 'wp_screen_options[value]': '999',
                                 'screen-options-apply': 'Apply',
                                 'wp_screen_options[option]': 'edit_post_per_page',
                                 'screenoptionnonce': screen_optionnonce},
                           verify=False)
            except Exception as e:
                print e
                continue

            try:
                wp_edit_page = s.get(domain_url + '/wp-admin/edit.php', verify=False)
                urls = set()
                a_hrefs = BeautifulSoup(wp_edit_page.content).findAll('a')
                for link in a_hrefs:
                    if 'post.php' in link['href'] and 'action=edit' in link['href']:
                        urls.add(link['href'])

                wp_edit_post = s.get(domain_url + '/wp-admin/edit.php?post_type=page', verify=False)
                pages = set()
                pages_hrefs = BeautifulSoup(wp_edit_post.content).findAll('a')
                for link in pages_hrefs:
                    if 'post.php' in link['href'] and 'action=edit' in link['href']:
                        pages.add(link['href'])
            except Exception as e:
                print e
                continue

            result = urls | pages
            if len(result) > 0:
                with open('result/' + domain + '.txt', mode='wt') as result_file:
                    result_file.write('\n'.join(result))
            else:
                print domain + ' - Parse Error'
        else:
            print domain + ' - Login error'
    else:
        print 'Some Error'
