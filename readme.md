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

    #getting previous date:
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


