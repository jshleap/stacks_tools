import pandas as pd
import matplotlib.pyplot as plt
from glob import glob
import re
from statannot import add_stat_annotation
from itertools import combinations
import seaborn as sns

plt.style.use('ggplot')
#sns.set(style="whitegrid")

snpfiles = glob('./m*_*/snps_r8.tsv')
covfiles = glob('./m*_*/cov_r8.tsv')


def one(i):
    d = pd.read_csv(i, comment='#', sep='\t')
    numerical = [int(re.sub('[^0-9]', '', x)) for x in
                 i.split('/')[1].split('_')]
    ndf = pd.DataFrame(
        [dict(zip(['m', 'M', 'n'], numerical)) for _ in range(d.shape[0])])
    d = pd.concat((d, ndf), axis=1)
    return d.groupby(list('mMn'), as_index=False).sum()


snps = pd.concat([one(f) for f in snpfiles])
#fig, ax = plt.subplots()
pairs = list(combinations(range(3,8),2))
pairs = pairs[:3] + pairs[-4:]
ax = sns.boxplot(data=snps, y='n_snps', x='m')#, ax=ax)
add_stat_annotation(ax, data=snps, x='m', y='n_snps', boxPairList=pairs,
                    test='Mann-Whitney', textFormat='star', verbose=2)
plt.savefig('m_snp.pdf')
plt.close()

pairs = list(combinations(range(1,9),2))
pairs = pairs[:3] + pairs[-4:]
ax = sns.boxplot(data=snps, y='n_snps', x='M')
add_stat_annotation(ax, data=snps, x='M', y='n_snps', boxPairList=pairs,
                    test='Mann-Whitney', textFormat='star', verbose=2)
plt.savefig('M_snp.pdf')
plt.close()

pairs = list(combinations(range(10),2))
pairs = pairs[:3] + pairs[-4:]
ax = sns.boxplot(data=snps, y='n_snps', x='n')
add_stat_annotation(ax, data=snps, x='n', y='n_snps', boxPairList=pairs,
                    test='Mann-Whitney', textFormat='star', verbose=2)
plt.savefig('n_snp.pdf')
plt.close()


covs = pd.concat([one(f) for f in covfiles])

fig, ax = plt.subplots()
covs.boxplot(column='mean_cov', by='m', ax=ax)
plt.savefig('m_cov.pdf')
plt.close()