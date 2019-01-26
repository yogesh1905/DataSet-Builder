
import numpy as np
import cv2
import os
#from preprocessing import *
import pandas as pd
a,b = input().split()
a = int(a)
b = int(b)

def preprocess(img):
	img=255-np.array(img).astype(np.uint8)
	#print(img.shape)
	#print(img)
	img = np.array(img).reshape(a,b,3)
	img= img.reshape(1,a*b*3)
	img = img/255
	return img
# Save image in set directory 
# Read RGB image 
str=""
i=0
print(os.listdir("results"))
final = pd.DataFrame()
for filename in os.listdir("results"):
	if os.path.isdir("results/"+filename):
		for fil in os.listdir("results/"+filename):
			if fil.endswith(".png") : 
				str = os.path.join(fil)
				st2 = "results/"+filename +"/" +str
				img = cv2.imread(st2)  
				img2 = preprocess(img)
				df = pd.DataFrame(img2)
				df[a*b*3]=filename
				final = final.append(df)
				print(i)
				i+=1
final.to_csv('fin.csv')

