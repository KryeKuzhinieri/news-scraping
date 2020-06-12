# Python - Tërheq të dhëna nga webfaqe të ndryshme 
### <i>For English Scroll Down</i>

### Ideja
Shpeshherë dëgjojmë se në gjuhën shqipe nuk ka të dhëna të mjaftueshme për të ndërtuar modele të NLP-së. Më anë të këtij mësimi synoj që të aftësoj dhe të sqaroj një mënyrë të tërheqjes së të dhënave nga interneti duke përdorur gjuhën programuese python. 

### Qëllimi:
Siç u cek më lart, qëllimi im është të ndërtoj një model që klasifikon lajmet në bazë të llojit (politikë, sport, kronika rozë etj.) duke perdorur Natural Language Processing (NLP). Prandaj webfaqja nga e cila do të merren të dhënat është https://telegrafi.com/arkiva/

### Mënyra:
Për të arritur qëllimin tonë do të përdorim këto paketa:
    1. requests_html (pip install requests-html)
    2. BeautifulSoup (pip install beautifulsoup4)
    

#### Hapi i parë - Vizito dhe kupto webfaqen
Fillimisht vizitoni webfaqen https://telegrafi.com/arkiva/. Kjo faqe do t'ju drejtojë në datën e sotme https://telegrafi.com/arkiva/2020-06-12/. Qëllimi jonë është që të shkruajmë një algoritëm që për secilin lajm do të kopjojë titullin e lajmit dhe do të hyjë brenda në lajm dhe do të kopjojë dhe përbmajtjen e lajmit. Në mënyrë që të kuptojmë strukturën e telegrafit duhet që të dimë pak HTML. Prandaj, në shfletuesin tuaj <i>(p.sh: Google Chrome)</i> mbani të shtypur njëkohësisht <b>Ctrl+Shift+I</b>. Si rezultat do të na shfaqet kodi i HTML-së që përdor telegrafi dhe pas një analize të shkurtër mund të shohim se sektori i cili i përmban titujt e lajmeve është <b>"arkiva-list-box"</b>. 

``` HTML 
    <div class="arkiva-list-box lajme">
        <a href="https://telegrafi.com/anti-korrupsioni-ta-hetoje-bfi-ne-per-mashtrim-financiar/">
            <span class="published_at">12.06.2020<strong>04:56</strong></span>
            Anti-korrupsioni do ta hetojë BFI-në për mashtrim financiar
        </a>
    </div>  
```

Atëherë, për çdo lajm në <b>(arkiva-list-box)</b> do të tërheqim titullin dhe përmbajtjen. 


#### Hapi i dytë - Shndërro idenë në kod
    1. Importo paketat e duhura.
    2. Krijo dy lista për ti ruajtur të dhënat e shkarkuara.
    3. Tërheq të dhënat.


```python
from bs4 import BeautifulSoup #paketa që tërheq të dhënat nga interneti.
from requests_html import HTMLSession 
import datetime 
import pandas as pd
```


```python
article = []
content = []

headers = {
     'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36',
}
```


```python
URL = 'https://telegrafi.com/arkiva/2020-06-12/' #linku i plotë.
session = HTMLSession() 
page = session.get(URL, headers=headers) #vizito telegrafin.
soup = BeautifulSoup(page.content, 'html.parser') #tërheq të gjithë përmbajtjen e faqes telegrafi.com.
results = soup.find_all('div', class_="arkiva-list-box") #specifiko të dhënat që dëshiron ti marrësh.
#print(results) 
```

Kodi i mësipërm shfaq të gjithë titujt, datat, kodin e HTML-së dhe informacionet që ndodhen brenda rubrikës <b>"arkiva-list-box"</b>. Mirëpo, ne jemi të interesuar që të marrim vetëm titullin.


```python
for result in results:
    news_title = result.find('a') #merr të gjithë informacionin që ndodhet brenda <a></a>
    link = news_title['href'] #merr vetëm URL-në.
    title = news_title.text #merr vetëm tekstin pa HTML
print(title,'\n', link, '\n\n')
```

    
    12.06.202012:00
            Sabri Fejzullahu pas pranimit të “Çelësit të Prishtinës”: Nder dhe kënaqësi, faleminderit nga zemra ju dua të gjithëve     
     https://telegrafi.com/sabri-fejzullahu-pas-pranimit-te-celesit-te-prishtines-nder-dhe-kenaqesi-faleminderit-nga-zemra-ju-dua-te-gjitheve/ 
    
    


Pasi që nuk na duhet data, na duhet të gjejmë një metodë që ta fshijmë nga teksti. Data gjendet brenda rubrikës span.

```HTML
    <span class="published_at">12.06.2020<strong>05:23</strong></span>
```


```python
for result in results:
    news_title = result.find('a') #merr të gjithë informacionin që ndodhet brenda <a></a>
    link = news_title['href'] #merr vetëm URL-në.
    title_unclean = news_title.text #merr vetëm tekstin pa HTML (Së bashku me datë)
    span = news_title.find('span').text #merr vetëm tekstin që ndodhet brenda <span></span>.
    title = title_unclean[len(span)+1:] #fshij datën nga teksti.
print(title,'\n', link, '\n\n')
```

    
            Sabri Fejzullahu pas pranimit të “Çelësit të Prishtinës”: Nder dhe kënaqësi, faleminderit nga zemra ju dua të gjithëve     
     https://telegrafi.com/sabri-fejzullahu-pas-pranimit-te-celesit-te-prishtines-nder-dhe-kenaqesi-faleminderit-nga-zemra-ju-dua-te-gjitheve/ 
    
    


Që të tërheqim përmbajtjen e lajmit, na duhet që të vizitojmë secilin link. Që të gjejmë vendndodhjen e tekstit në lajm duhet që të hapim linkun dhe të mbajmë shtypur <b>Ctrl+Shift+I</b>. Le ta vizitojmë këtë link: https://telegrafi.com/qytetare-te-kosoves-e-pjesetare-te-kfor-kujtojne-diten-e-clirimit/. 


```HTML
<div class="article-body" data-io-article-url="https://telegrafi.com/qytetare-te-kosoves-e-pjesetare-te-kfor-kujtojne-diten-e-clirimit/">
    <p>
        <strong>
            Dita e çlirimit shënoi kthesën më të madhe historike të vendit, por pavarësisht kësaj qytetarët nuk janë të kënaqur me progresin e arritur pasi pritjet për zhvillimin e vendit ishin shumë më të mëdha. 
        </strong>
    </p>							
</div>

```


```python
for result in results:
    news_title = result.find('a') #merr të gjithë informacionin që ndodhet brenda <a></a>
    link = news_title['href'] #merr vetëm URL-në.
    title_unclean = news_title.text #merr vetëm tekstin pa HTML (Së bashku me datë)
    span = news_title.find('span').text #merr vetëm tekstin që ndodhet brenda <span></span>.
    title = title_unclean[len(span)+1:] #fshij datën nga teksti.

    #Vizito linkun dhe merr lajmin:
    body_soup = BeautifulSoup(session.get(link, headers=headers).content, 'html.parser') #vizito linkun.
    body_results = body_soup.find('div', class_="article-body").text #tërheq lajmin e plotë
    
    article.append(title)
    content.append(body_results)
    
print(title,'\n', link, '\n', body_results, '\n\n')
```

    
            Sabri Fejzullahu pas pranimit të “Çelësit të Prishtinës”: Nder dhe kënaqësi, faleminderit nga zemra ju dua të gjithëve     
     https://telegrafi.com/sabri-fejzullahu-pas-pranimit-te-celesit-te-prishtines-nder-dhe-kenaqesi-faleminderit-nga-zemra-ju-dua-te-gjitheve/ 
     
    Këngëtari i njohur shqiptar, Sabri Fejzullahu, është nderuar të enjten me mirënjohjen “Çelësi i Prishtinës”.
    Kjo dekoratë iu dhurua atij nga kryetari i komunës, Shpend Ahmeti, në shenjë mirënjohje për kontributin e tij artistik ndër vite.
    Pas pranimit të këtij çmimi, Fejzullahu ka reaguar me një postim në rrjetet sociale, ku ka bërë të ditur se e kishte për nder ta pranonte këtë çmim.
    
    Lexo po ashtu:
    
    
    
    Sabri Fejzullahu nderohet me çmimin “Çelësi i Qytetit” nga Komuna e Prishtinës
    
    
    
    
    “Në 21 vjetorin e çlirimit të Prishtinës sime, sot pata nderin dhe kënaqësinë që nga Komuna e Prishtinës, respektivisht kryetari Shpend Ahmeti dhe ekipi i tij i mrekullueshëm, të pranoj ÇELËSIN E PRISHTINËS. Ju faleminderit nga zemra të gjithëve. Ju dua. I juaji, Sabri Fejzullahu”, ka shkruar këngëtari i njohur në Instagram.
    
       
    
    


Kemi arritur që me sukses të tërheqim të dhënat nga telegrafi.com për një ditë. Si të veprojmë që nxjerrim lajmet e ditëve të mëhershme? Fatmirësisht, telegrafi i ruan lajmet sipas datës. Prandaj, nga https://telegrafi.com/arkiva/2020-06-12/ <b>(2020-06-12)</b> na duhet që të zbresim një ditë <b>(2020-06-11)</b>.


```python
url_date = URL[29:39] #mbaj vetëm datën nga linku.
url_date = datetime.datetime.strptime(url_date,"%Y-%m-%d")
end_date = url_date - datetime.timedelta(days=1)
print("Data fillestare:", url_date.date(), "\nData e re:", end_date.date())
```

    Data fillestare: 2020-06-12 
    Data e re: 2020-06-11


### Kodi i plotë:

```Python

from bs4 import BeautifulSoup
import pandas as pd
import datetime
from requests_html import HTMLSession

article = []
content = []

URL = 'https://telegrafi.com/arkiva/2020-06-09/'

headers = {
     'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36',
}

session = HTMLSession()
for i in range(50): #Tërheq të dhëna për 50 ditë
    print('Dita {0}'.format(i+1))
    page = session.get(URL, headers=headers)
    soup = BeautifulSoup(page.content, 'html.parser')

    results = soup.find_all('div', class_="arkiva-list-box")

    for result in results:
        news_title = result.find('a') #merr të gjithë informacionin që ndodhet brenda <a></a>
        link = news_title['href'] #merr vetëm URL-në.
        title_unclean = news_title.text #merr vetëm tekstin pa HTML (Së bashku me datë)
        span = news_title.find('span').text #merr vetëm tekstin që ndodhet brenda <span></span>.
        title = title_unclean[len(span)+1:] #fshij datën nga teksti.

        #Vizito linkun dhe merr lajmin:
        body_soup = BeautifulSoup(session.get(link, headers=headers).content, 'html.parser') #vizito linkun.
        body_results = body_soup.find('div', class_="article-body").text #tërheq lajmin e plotë
        
        #Ruaj të dhënat në listë
        article.append(title)
        content.append(body_results)

    #Data e mëhershme:
    url_date = URL[29:39] #mbaj vetëm datën nga linku.
    url_date = datetime.datetime.strptime(url_date,"%Y-%m-%d")
    end_date = url_date - datetime.timedelta(days=1)
    URL = URL[:29] + str(end_date.date())
    print(URL)
    print('\n\n\n')
    
df = pd.DataFrame(data={"Article": article, "Content": content}) #Ruaj të dhënat si csv
df.to_csv("telegrafi.csv", sep=',',index=False)

```

### Gatim të këndshëm!

# Web Scraping Using Python

### Idea
Since in the Albanian language there is not enough data to work with when training NLP models, I have decided to write a tutorial on how to retrieve data from the web. Although the website's content is Albanian, the logic will be the same for any website in any language.

### Goal:
The goal of the project is to build a model that classifies news articles (politics, sports, magazine etc.) using Natural Language Processing (NLP). Hence, the website that will be in this tutorial is https://telegrafi.com/arkiva/

### Method:
In this tutorial the following modules will be used:
    1. requests_html (pip install requests-html)
    2. BeautifulSoup (pip install beautifulsoup4)
    

#### The first step - Understand the website
Paste the following link into your browser: https://telegrafi.com/arkiva/. By default, the website will redirect you to today's date https://telegrafi.com/arkiva/2020-06-12/. Our goal is to write an algorithm that for each news article, it will copy the news title and go inside the post to retrieve the content. In order to understand the structure of the page, we need to know a bit of HTML. Due to this, on your browser <i>(i.e. Google Chrome)</i> press <b>Ctrl+Shift+I</b>. As a result of our action, we will see the HTML code that telegrafi.com uses for their website. After a short inspection we come to the conclusion that the division that keeps the news article titles is <b>"arkiva-list-box"</b>. 

``` HTML 
    <div class="arkiva-list-box lajme">
        <a href="https://telegrafi.com/anti-korrupsioni-ta-hetoje-bfi-ne-per-mashtrim-financiar/">
            <span class="published_at">12.06.2020<strong>04:56</strong></span>
            Anti-korrupsioni do ta hetojë BFI-në për mashtrim financiar
        </a>
    </div>  
```

Then, for each news article in <b>(arkiva-list-box)</b> we will get the title and the content. 


#### Second Step - Transform the idea into code
    1. Import the necessary modules.
    2. Create the lists two store the information.
    3. Scrap the information.


```python
from bs4 import BeautifulSoup #paketa që tërheq të dhënat nga interneti.
from requests_html import HTMLSession 
import datetime 
import pandas as pd
```


```python
article = []
content = []

headers = {
     'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36',
}
```


```python
URL = 'https://telegrafi.com/arkiva/2020-06-12/' #full link.
session = HTMLSession() 
page = session.get(URL, headers=headers) #visit the website.
soup = BeautifulSoup(page.content, 'html.parser') #get the entire page code.
results = soup.find_all('div', class_="arkiva-list-box") #specify the information you want to get.
#print(results) 
```

The code above contains all the articles, dates, HTML tags, and other information that exists within <b>"arkiva-list-box"</b>. However, we want to get only the title. 


```python
for result in results:
    news_title = result.find('a') #get all info that is within <a></a>
    link = news_title['href'] #get only the url.
    title = news_title.text #get the text without html
print(title,'\n', link, '\n\n')
```

    
    12.06.202012:00
            Sabri Fejzullahu pas pranimit të “Çelësit të Prishtinës”: Nder dhe kënaqësi, faleminderit nga zemra ju dua të gjithëve     
     https://telegrafi.com/sabri-fejzullahu-pas-pranimit-te-celesit-te-prishtines-nder-dhe-kenaqesi-faleminderit-nga-zemra-ju-dua-te-gjitheve/ 
    
    


Since we are not interested in the date, we need to find a way in which we can remove it from the string. Date can be found within the span tag.

```HTML
    <span class="published_at">12.06.2020<strong>05:23</strong></span>
```


```python
for result in results:
    news_title = result.find('a') #get all info that is within <a></a>
    link = news_title['href'] #get only the url.
    title_unclean = news_title.text #get only the url (date included)
    span = news_title.find('span').text #get the text that is within <span></span>.
    title = title_unclean[len(span)+1:] #remove the date from the text
print(title,'\n', link, '\n\n')
```

    
            Sabri Fejzullahu pas pranimit të “Çelësit të Prishtinës”: Nder dhe kënaqësi, faleminderit nga zemra ju dua të gjithëve     
     https://telegrafi.com/sabri-fejzullahu-pas-pranimit-te-celesit-te-prishtines-nder-dhe-kenaqesi-faleminderit-nga-zemra-ju-dua-te-gjitheve/ 
    
    


To scrap the content of the news article, we need to visit the links one by one. As in the previous step, we need to visit the link and press <b>Ctrl+Shift+I</b> to see the website front end. Let's visit this link: https://telegrafi.com/qytetare-te-kosoves-e-pjesetare-te-kfor-kujtojne-diten-e-clirimit/. 


```HTML
<div class="article-body" data-io-article-url="https://telegrafi.com/qytetare-te-kosoves-e-pjesetare-te-kfor-kujtojne-diten-e-clirimit/">
    <p>
        <strong>
            Dita e çlirimit shënoi kthesën më të madhe historike të vendit, por pavarësisht kësaj qytetarët nuk janë të kënaqur me progresin e arritur pasi pritjet për zhvillimin e vendit ishin shumë më të mëdha. 
        </strong>
    </p>							
</div>

```


```python
for result in results:
    news_title = result.find('a') #get all info that is within <a></a>
    link = news_title['href'] #get only the url.
    title_unclean = news_title.text #get only the url (date included)
    span = news_title.find('span').text #get the text that is within <span></span>.
    title = title_unclean[len(span)+1:] #remove the date from the text

    #Click on the link and get the content:
    body_soup = BeautifulSoup(session.get(link, headers=headers).content, 'html.parser') #click the link.
    body_results = body_soup.find('div', class_="article-body").text #get the whole content
    
    article.append(title)
    content.append(body_results)
    
print(title,'\n', link, '\n', body_results, '\n\n')
```

    
            Sabri Fejzullahu pas pranimit të “Çelësit të Prishtinës”: Nder dhe kënaqësi, faleminderit nga zemra ju dua të gjithëve     
     https://telegrafi.com/sabri-fejzullahu-pas-pranimit-te-celesit-te-prishtines-nder-dhe-kenaqesi-faleminderit-nga-zemra-ju-dua-te-gjitheve/ 
     
    Këngëtari i njohur shqiptar, Sabri Fejzullahu, është nderuar të enjten me mirënjohjen “Çelësi i Prishtinës”.
    Kjo dekoratë iu dhurua atij nga kryetari i komunës, Shpend Ahmeti, në shenjë mirënjohje për kontributin e tij artistik ndër vite.
    Pas pranimit të këtij çmimi, Fejzullahu ka reaguar me një postim në rrjetet sociale, ku ka bërë të ditur se e kishte për nder ta pranonte këtë çmim.
    
    Lexo po ashtu:
    
    
    
    Sabri Fejzullahu nderohet me çmimin “Çelësi i Qytetit” nga Komuna e Prishtinës
    
    
    
    
    “Në 21 vjetorin e çlirimit të Prishtinës sime, sot pata nderin dhe kënaqësinë që nga Komuna e Prishtinës, respektivisht kryetari Shpend Ahmeti dhe ekipi i tij i mrekullueshëm, të pranoj ÇELËSIN E PRISHTINËS. Ju faleminderit nga zemra të gjithëve. Ju dua. I juaji, Sabri Fejzullahu”, ka shkruar këngëtari i njohur në Instagram.
    
       
    
    


We have successfully retrieved the news articles of telegrafi.com for one day. Then, this begs the question: "How to get the articles for more than one day?" Luckily, telegrafi stores the date within the link https://telegrafi.com/arkiva/2020-06-12/. 
<br>Consequently, from <b>(2020-06-12)</b> we need to subtract one day <b>(2020-06-11)</b>


```python
url_date = URL[29:39] #keep the data from the link.
url_date = datetime.datetime.strptime(url_date,"%Y-%m-%d")
end_date = url_date - datetime.timedelta(days=1)
print("Data fillestare:", url_date.date(), "\nData e re:", end_date.date())
```

    Data fillestare: 2020-06-12 
    Data e re: 2020-06-11


### Full code:

```Python

from bs4 import BeautifulSoup
import pandas as pd
import datetime
from requests_html import HTMLSession

article = []
content = []

URL = 'https://telegrafi.com/arkiva/2020-06-09/'

headers = {
     'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36',
}

session = HTMLSession()
for i in range(50): #Get the articles for 50 days
    print('Dita {0}'.format(i+1))
    page = session.get(URL, headers=headers)
    soup = BeautifulSoup(page.content, 'html.parser')

    results = soup.find_all('div', class_="arkiva-list-box")

    for result in results:
        news_title = result.find('a') #get the information within <a></a>
        link = news_title['href'] #get only the url.
        title_unclean = news_title.text #get the text without HTML (date included)
        span = news_title.find('span').text #get the text that is within <span></span>.
        title = title_unclean[len(span)+1:] #remove the date from the text.

        #click the link and get the content:
        body_soup = BeautifulSoup(session.get(link, headers=headers).content, 'html.parser') #click the link.
        body_results = body_soup.find('div', class_="article-body").text #retrive the content
        
        #Save the articles into list
        article.append(title)
        content.append(body_results)

    #getting previous date:
    url_date = URL[29:39] #Keep only the date from the link.
    url_date = datetime.datetime.strptime(url_date,"%Y-%m-%d")
    end_date = url_date - datetime.timedelta(days=1)
    URL = URL[:29] + str(end_date.date())
    print(URL)
    print('\n\n\n')
    
df = pd.DataFrame(data={"Article": article, "Content": content}) #Save your dataset as .csv
df.to_csv("telegrafi.csv", sep=',',index=False)

```

### Happy Cooking!
