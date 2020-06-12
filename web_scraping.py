from bs4 import BeautifulSoup
import pandas as pd
import datetime
from requests_html import HTMLSession

article = []
content = []
categories = []

URL = 'https://telegrafi.com/arkiva/2020-06-09/'

headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36',
}

session = HTMLSession()
for i in range(1):
    print('Dita {0}'.format(i+1))
    page = session.get(URL, headers=headers)
    # page = requests.get(URL)
    soup = BeautifulSoup(page.content, 'html.parser')

    results = soup.find_all('div', class_="arkiva-list-box")

    for result in results:
        news_title = result.find('a')  # merr të gjithë informacionin që ndodhet brenda <a></a>
        link = news_title['href']  # merr vetëm URL-në.
        title_unclean = news_title.text  # merr vetëm tekstin pa HTML (Së bashku me datë)
        span = news_title.find('span').text  # merr vetëm tekstin që ndodhet brenda <span></span>.
        title = title_unclean[len(span) + 1:]  # fshij datën nga teksti.

        # Vizito linkun dhe merr lajmin:
        body_soup = BeautifulSoup(session.get(link, headers=headers).content, 'html.parser')  # vizito linkun.
        body_results = body_soup.find('div', class_="article-body").text  # tërheq lajmin e plotë

        #Get the news type:
        category = body_soup.find('div', class_="article-heading")
        category = category.find('a').text


        #print(title, '\n', link, '\n', body_results, '\n', category, '\n\n\n')
        #Ruaj të dhënat në listë
        article.append(title)
        content.append(body_results)
        categories.append(category)

    # getting previous date:
    url_date = URL[29:39]  # mbaj vetëm datën nga linku.
    url_date = datetime.datetime.strptime(url_date, "%Y-%m-%d")
    end_date = url_date - datetime.timedelta(days=1)
    URL = URL[:29] + str(end_date.date())
    print(URL)
    print('\n\n\n')

df = pd.DataFrame(data={"Article": article, "Content": content,
                        "Category": categories})  # Ruaj të dhënat si csv
df.to_csv("telegrafi.csv", sep=',', index=False)