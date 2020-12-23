import pandas as pd
import tensorflow as tf
from tensorflow import keras
from sklearn.model_selection import train_test_split
import numpy as np
import pylab as pl
from sklearn.preprocessing import StandardScaler
import seaborn as sns
import matplotlib.pyplot as plt 

# Prepare data
hive_data_2019_jun_validate = pd.read_csv('data/hive_data_2019_jun.validate.csv')
hive_data_2020_jun_train = pd.read_csv('data/hive_data_2020_jun.train.csv')
hive_data_2019_jun_validate.loc[hive_data_2019_jun_validate['weight_delta_direction'] == 'UP','weight_delta_direction'] = 1.0
hive_data_2019_jun_validate.loc[hive_data_2019_jun_validate['weight_delta_direction'] == 'DOWN','weight_delta_direction'] = 0.0
hive_data_2020_jun_train.loc[hive_data_2020_jun_train['weight_delta_direction'] == 'UP','weight_delta_direction'] = 1.0
hive_data_2020_jun_train.loc[hive_data_2020_jun_train['weight_delta_direction'] == 'DOWN','weight_delta_direction'] = 0.0

properties = list(hive_data_2020_jun_train.columns.values)
properties.remove('weight_delta_direction')
X_train = hive_data_2020_jun_train[properties]
y_train = hive_data_2020_jun_train['weight_delta_direction']


properties = list(hive_data_2019_jun_validate.columns.values)
properties.remove('weight_delta_direction')
X_test = hive_data_2019_jun_validate[properties]
y_test = hive_data_2019_jun_validate['weight_delta_direction']

# Standardization
sc = StandardScaler()
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)

# Train 
model = keras.Sequential([
keras.layers.Dense(4, activation=tf.nn.relu, input_shape=(7,)), 
keras.layers.Dense(4, activation=tf.nn.relu),
keras.layers.Dense(1, activation=tf.nn.sigmoid), # Output single value.
])

model.compile(optimizer='adam',
              loss='binary_crossentropy',
              metrics=['accuracy'])

y_train = np.asarray(y_train).astype('float32')
y_test = np.asarray(y_test).astype('float32')
model.fit(X_train, y_train, epochs=200, batch_size=1)

# Validate 
test_loss, test_acc = model.evaluate(X_test, y_test)
print('Test accuracy:', test_acc)

new_prediction = model.predict(X_test)
new_prediction = (new_prediction > 0.5)
cm = confusion_matrix(y_test, new_prediction)

# Plot confusion matrix
ax= plt.subplot()
sns.heatmap(cm, annot=True, ax = ax);
ax.set_xlabel('Predicted labels');ax.set_ylabel('True labels'); 
ax.set_title('Confusion Matrix'); 
ax.xaxis.set_ticklabels(['DOWN', 'UP']); ax.yaxis.set_ticklabels(['DOWN', 'UP']);
