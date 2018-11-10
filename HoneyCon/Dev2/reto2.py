import requests
import re
def striphtml(data):
    p = re.compile(r'<.*?>')
    r = re.compile(r'(AND|XOR|=r1|=r2)')
    q = re.compile(r'(\n|Honey|Dev .*|Result = base64(.*)|Result =)')

    css = re.compile(r'.*{|.*;|}')
    r1=p.sub('', data)
    r2=r.sub('\n',r1)
    r3 = q.sub('',r2)
    return css.sub('',r3)
headers = {'Host': '51.68.45.226:1001','User-Agent':'Fake', 'Cookie':'PHPSESSID=7d471521e9d6e36e4a879fe772de2c15'}
r = requests.get('http://51.68.45.226:1001/', headers=headers)
st = striphtml(r.text)
print st
