#Python Regular Expression Exapmle Note
import re


a = re.match('ab..','abcd').group()
print(a) # abcd

a = re.match('ab..','abcd').group()
print(a) # abcd

m = re.search('bc', 'dfdljbabcklebc').group()
print(m) # bc

m = re.findall('ef', 'dahdjadjkacefjxncjefcklsdnshef')
print(m) # ['ef', 'ef', 'ef']

# . -> 任意字元
a = re.match('ab..','abcd').group()
print(a) # abcd

m = re.search('.bc.', 'dfdljbabcklebc').group()
print(m) # abck

#從字首檢查
m = re.search('^df', 'dfdljbabcklebc').group()
print('^', m) # ^ df

#從字尾檢查
m = re.search('.*c$', 'dfdljbabcklebc').group()
print("$" , m) # $ dfdljbabcklebc

# .* -> 任意 n 個字元    
m = re.search('.*le', 'dfdljbabcklebc').group()
print(m) # dfdljbabckle

m = re.search('le.*', 'dfdljbabcklebc').group()
print(m) # lebc

m = re.search('aabb{1}.*', 'aabbccaaabbbccc').group()
print(m) # aabbccaaabbbccc

m = re.search('a{2,3}', 'aabbccaaabbbccc').group()
print(m) # aa

