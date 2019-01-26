#!/usr/bin/env python
# coding: utf-8

# In[1]:


#Neural net with two hidden layer
import numpy as np
import pandas as pd
from sklearn import preprocessing
from sklearn.model_selection import train_test_split


# In[2]:


def sigmoid(x):
  return (1/(1+np.exp(-x)))


# In[3]:


def cost(output,y):
  x=np.sum((-1*y)*np.log(output)-(1-y)*(np.log(1-output)))
  return x


# In[4]:


def prop(x,y,theta3,theta2,theta1,alpha):
  
  #Forward prop
  al1=np.dot(theta1.T,x)
  al1=sigmoid(al1)
  al2=np.dot(theta2.T,al1)
  al2=sigmoid(al2)
  output=np.dot(theta3.T,al2)
  output=sigmoid(output)
  ct=cost(output,y)

  #Backward prop
  delout=output-y
  del3=np.multiply((theta3)@delout,np.multiply(al2,(1-al2)))
  del2=np.multiply((theta2)@del3,np.multiply(al1,(1-al1)))
  
  theta3_grad=al2@delout.T
  theta2_grad=al1@del3.T
  theta1_grad=x@del2.T
  
  theta3=theta3-alpha*theta3_grad
  theta2=theta2-alpha*theta2_grad
  theta1=theta1-alpha*theta1_grad
  return [theta1,theta2,theta3,ct,output]
  


# In[5]:


#checking
x=np.array([[100],[10]])
y=np.array([[0]])
theta1=np.random.rand(2,4)
theta2=np.random.rand(4,2)
theta3=np.random.rand(2,1)
#print(theta3.shape)
alpha=0.01
c=0
for i in range(1000):
  theta1,theta2,theta3,cos,out=prop(x,y,theta3,theta2,theta1,alpha)
  c=cos
  
#print("Output is :",out)
#print("Cost is :",c)


# In[6]:


train=pd.read_csv("fin.csv")


# In[7]:


#print(train.head())
y=train.iloc[:,4:5]
X=train.iloc[:,:4]
y=y.values
Y=np.zeros((len(y),3))
for i in range(len(y)):
    if y[i]=='Iris-setosa':
        Y.itemset((i,0),1)
    elif y[i]=='Iris-versicolor':
        Y.itemset((i,1),1)
    else:
        Y.itemset((i,2),1)

     


# In[8]:


#spliting data
x_train, x_test, y_train, y_test = train_test_split(X,Y, random_state=0)
#Feature scaling
x_train = preprocessing.scale(x_train)
x_test=preprocessing.scale(x_test)


# In[9]:


#Initixlising theta
theta1=np.random.rand(4,3)
theta2=np.random.rand(3,3)
theta3=np.random.rand(3,3)


# In[10]:



alpha=0.05;
X_rand=np.random.rand(1,8)
Y_rand=np.random.rand(1,1)
Y_rand=np.round(Y_rand)

for j in range(1000):
  ct=0
  for i in range(x_train.shape[0]):
    theta1,theta2,theta3,cos,val=prop(x_train[i].reshape((4,1)),y_train[i].reshape(3,1),theta3,theta2,theta1,alpha)
    ct+=cos  

#print("Final cost :",ct/X.shape[0])


# In[11]:


#Testing on test set
ct=0
ans=[]
for i in range(x_test.shape[0]):
      al1=np.dot(theta1.T,x_test[i].reshape((4,1)))
      al1=sigmoid(al1)
      al2=np.dot(theta2.T,al1)
      al2=sigmoid(al2)
      output=np.dot(theta3.T,al2)
      output=sigmoid(output)
      #print(np.round(output).argmax())
      ans.append(np.int(np.round(output).argmax()))
      #print(output)
score=0
for i in range(y_test.shape[0]):
  if y_test[i][ans[i]]==1:
    score=score+1
print("Accuracy: ",score/y_test.shape[0]*100.0,"%")
   
 
  
  
  


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




