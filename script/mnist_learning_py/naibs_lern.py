import numpy as np
from sklearn.naive_bayes import BernoulliNB

resized_train_images = np.load('train_images.npy')
train_labels = np.load('train_labels.npy')

nb = BernoulliNB()
nb.fit(resized_train_images, train_labels)

np.save('class_log_prior_.npy', nb.class_log_prior_)# 事前確率の対数を書き込む
np.save('feature_log_prob_.npy', nb.feature_log_prob_)# 特徴ベクトルの対数確率を書き込む

