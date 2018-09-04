#!/usr/bin/env python3

import numpy as np
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt

from fields import *

def product_code_to_int(c):
	# print("{}({}) {}({}) = {}".format(c, ord(c), 'A', ord('A'), ord(c) - ord('A')))
	return ord(c) - ord('A')


def prepare_data(f):
	X = []
	for i, line in enumerate(f):
		if i == 0:
			continue
		tmp = line.strip().split(',')
		# print(tmp)
		sale = []
		if tmp[offer_number] == '0' and (tmp[unuse_indicator] == 'Z' or tmp[unuse_indicator] == 'N'):
			for j, el in enumerate(tmp):
				element = el

				try:
					element = float(el)
					# print("{} -> {}".format(el, float(el)))
				except:
					# print("not floatable -> {}".format(el))
					pass

				if j == store_format_code:
					element = (.0 if tmp[store_format_code] == 'X' else 1.)
					# print("{}, {}".format(j, element))
				elif j == product_sub_group_code:
					element = product_code_to_int(tmp[product_sub_group_code])
					# print("{}, {}".format(j, element))
				elif j == calendar_date or j == step_indicator or j == offer_number or j == unuse_indicator:
					element = .0
				elif not element:
					element = .0

				sale.append(element)
			X.append(np.array(sale, dtype=np.float64))
	X = np.array(X, dtype=np.float64)

	print("min: {}".format(X.min(axis=0)))
	print("max: {}".format(X.max(axis=0)))

	miin = X.min(axis=0)
	maax = X.max(axis=0)

	for i, row in enumerate(X):
		for j, cel in enumerate(row):
			X[i][j] -= miin[j]
			if maax[j] - miin[j] > 0:
				X[i][j] /= (maax[j] - miin[j])

	return X

f = open('../data/1.csv', 'r')
data = prepare_data(f)

# for i in range(1, 248):
# 	print("{}:\t".format(i), end="")
# 	f = open('../data/{}.csv'.format(i), 'r')
# 	res = prepare_data(f)
# 	print(res.shape)
# 	print(data.shape)
# 	data = np.concatenate((data, res), axis=0)

print("min: {}".format(data.min(axis=0)))
print("max: {}".format(data.max(axis=0)))

pca = PCA()
pca.fit(data)

plt.bar([i for i in range(len(pca.explained_variance_ratio_))], pca.explained_variance_ratio_)

plt.show()
	
cumul = [pca.explained_variance_ratio_[0]]
