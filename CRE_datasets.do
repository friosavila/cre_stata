*8Datasets for replicating CRE

*1. Within and between estimates inrandom-eﬀects models: Advantages anddrawbacks of correlated random eﬀects andhybrid models
*Authors: Reinhard Schunck
*Stata Journal, 2013

use http://www.stata-press.com/data/mlmus2/smoking
mark nonmiss
markout nonmiss birwt smoke mage black
egen msmoke = mean(smoke) if nonmiss==1, by(momid)
generate dsmoke = smoke-msmok

*******
***2. Correlated Random Effects Models with Endogenous Explanatory Variables and Unbalanced Panels
**Author(s): Riju Joshi and Jeffrey M. Wooldridge
*Source: Annals of Economics and Statistics , June 2019, No. 134 (June 2019), pp. 243-268
*Michigan: standardized test scores from 1992 to 1998 at Michigan schools
*Note: use the data on standardized test scores from 1992 to 1998 at Michigan schools to determine the effects of spending on math test outcomes for fourth graders.
*Sent email to Riju joshi on July 25

*******
***3. Dmitry 2023_replication data added 2 files
*3.1 Lacetera, N., Macis, M. and Slonim, R. (2012a), "Replication Data for: Will There Be Blood? Incentives and Displacement Effects in Pro-Social Behavior" https://www.openicpsr.org/openicpsr/project/114774/version/V1/view
*3.2 — —, — —, — — (2023), "Replication Data for: Will There Be Blood? Incentives and Displacement Effects in Pro-Social Behavior", https://drive.google.com/file/d/1D0h8d29oOt7kpuH9bBBweAmTeIDd6IS7/view.WorldCat