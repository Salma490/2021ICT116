Predicting Gallstone Disease from Clinical, Laboratory and Body-Composition Data in R

Student: A.S. Salma (2021/ICT/116)
Module: Bioinformatics, ICA 3
Repository: 2021ICT116

1. Abstract

Gallstone disease is common and is normally diagnosed by ultrasound. We asked whether routine blood tests and body-composition measurements can identify patients with gallstones. Using a public dataset of 319 patients from one Turkish hospital (158 with gallstones, 161 controls), we compared 38 variables between groups with Wilcoxon and Fisher tests and trained logistic regression, random forest and support vector machine classifiers in R. Fifteen variables differed significantly after multiple-testing correction. The strongest were higher C-reactive protein (CRP) and lower vitamin D in patients with gallstones, and both held in men and women separately. Cross-validated AUC was 0.83 to 0.86 and test-set AUC 0.85 to 0.90, with no clear difference between models. The data come from a single centre and are cross-sectional, so the models are research tools and not diagnostic tests.

2. Introduction

Gallstone disease is one of the most common digestive disorders. The source publication for our dataset reports a prevalence of 10% to 20% among European adults and notes that the number of cases is rising (Esen et al., 2024). Many people have no symptoms, but stones can cause biliary colic, cholecystitis and bile duct obstruction. Known risk factors include female sex, age, obesity, metabolic syndrome and systemic inflammation (Esen et al., 2024).

Abdominal ultrasonography is the preferred way to detect gallstones. It is accurate in skilled hands, but it requires equipment and trained staff that are not available everywhere. In contrast, blood tests and bioimpedance body-composition scales are cheap, non-invasive and widely available. If these routine measurements carry information about gallstone status, they could help identify people who should be referred for imaging.

This project uses a public clinical dataset to ask two questions:

Which laboratory, body-composition and clinical variables differ between patients with and without gallstones?
How well can simple machine-learning models predict gallstone status from these variables?

Our hypothesis was that inflammatory, metabolic and body-composition markers would differ between the two groups and that a model built on them would classify patients clearly better than chance.

3. Data

Source. The Gallstone dataset from the UCI Machine Learning Repository (https://archive.ics.uci.edu/dataset/1150/gallstone-1), released under a Creative Commons Attribution 4.0 (CC BY 4.0) licence. It was introduced by Esen et al. (2024).

Collection. Data come from 454 participants treated at the Internal Medicine Outpatient Clinic of Ankara VM Medical Park Hospital between June 2022 and June 2023. After removing 134 people who had undergone gallbladder surgery, 319 patients remained (Esen et al., 2024). The study was approved by the Ankara City Hospital Ethics Committee (E2-23-4632), and the data contain no names or identifiers.

Variables. The file has 319 rows and 39 columns: the target (gallstone status) and 38 features. These cover demographics (age, sex, height, weight, BMI), comorbidities (coronary artery disease, hypothyroidism, hyperlipidemia, diabetes mellitus, a comorbidity count), bioimpedance measures taken with a Tanita MC780 device (body water, fat, lean, muscle, bone and protein measures, visceral fat), hepatic fat grade from ultrasonography (0 to 4), and 13 laboratory values (glucose, lipids, AST, ALT, ALP, creatinine, GFR, CRP, hemoglobin, vitamin D). Ages range from 20 to 96 years. There are 162 men and 157 women.

Data quality. There were no missing values and no duplicate rows. Two values were judged implausible: an obesity percentage of about 2,000% and a muscle mass below 20 kg. Both were set to missing and imputed with the training-set median inside the modelling pipeline (Section 4). Other extreme values, such as glucose up to about 570 mg/dL, were retained because they are medically possible. Two patients aged over 85 (87 and 96 years) were also retained.

A label-coding discrepancy. The UCI variable description states that gallstone status 0 means gallstones are present and 1 means absent. The source publication states the opposite: 1 represents a person with gallstones (Esen et al., 2024). We followed the publication, because its reported breakdown of gallstone patients by sex (90 women and 68 men, 158 patients) matches exactly the group coded 1 in the file (90 women, 68 men), whereas the group coded 0 has 161 patients (67 women, 94 men). Under this coding the associations also match the clinical picture (for example, higher CRP, more body fat and more women among patients with gallstones). The publication's abstract does state 161 patients with gallstones and 158 controls, which is inconsistent with its own breakdown, and another analysis of this dataset also used 158 gallstone cases and 161 controls (Chakraborty and Mukherjee, 2025). We therefore treat the discrepancy as a documentation error, but we note it as a limitation. In everything below, 158 patients have gallstones and 161 are controls.

4. Methods

All analysis was done in R, in one R Markdown notebook (code/gallstone_analysis.Rmd) with a rendered HTML copy.

Cleaning. Column names were standardised with janitor. Gallstone status, sex, and the four yes/no conditions were converted to factors. Comorbidity count (0 to 3) and hepatic fat grade (0 to 4) were kept numeric because they are ordered scales. Missing values and duplicates were checked with skimr, naniar and base R, and ranges were inspected with boxplots.

Exploratory analysis. We plotted group distributions of key variables and used Spearman correlation (robust to outliers) to show relationships among numeric variables. Principal component analysis (PCA) of standardised numeric variables was used to see whether the groups separate. One patient with an obesity percentage near 2,000 was left out of the PCA only.

Statistical comparison. Shapiro-Wilk tests showed that many variables were not normally distributed, so numeric variables were compared between groups with two-sided Wilcoxon rank-sum tests. Categorical variables were compared with Fisher's exact test, which is suitable for small counts. As an effect size for numeric variables we used |2 x AUC - 1|, where AUC is the probability that a random patient from one group has a higher value than a random patient from the other. It ranges from 0 (no difference) to 1 (complete separation). Because 38 tests were run, p-values were adjusted with the Benjamini-Hochberg method (Benjamini and Hochberg, 1995), and adjusted p < 0.05 was called significant. Because the gallstone group contained a higher proportion of women, the Wilcoxon tests for the strongest variables were repeated separately in men and women.

Predictive modelling. The data were split into a stratified training set (80%, 256 patients) and a test set (20%, 63 patients) with caret (seed 123). Three classifiers were trained on the training set only: logistic regression, random forest (randomForest) and a radial-kernel support vector machine (kernlab). Model settings were tuned with 10-fold cross-validation repeated three times, using the area under the ROC curve (AUC) as the criterion. Median imputation, centring and scaling were done inside each cross-validation fold to avoid information leaking from validation folds. For logistic regression, predictors that were correlated above 0.9 with another predictor were removed. The test set was used once, at the end, to report accuracy, sensitivity, specificity (using a 0.5 probability threshold, with gallstones as the positive class) and AUC with a 95% confidence interval (pROC). Random forest variable importance was extracted with varImp.

Software. R with tidyverse, readxl, janitor, skimr, naniar, corrplot, caret, randomForest, e1071, kernlab and pROC. Exact versions are recorded in the SessionInfo section of the rendered notebook.

5. Results
5.1 Exploratory analysis

The two groups were almost balanced (158 with gallstones, 161 controls). The key clinical variables show clear differences in a few measurements, but substantial overlap in most (Figure 1). Many body-composition variables are strongly correlated with each other, as expected for weight, BMI, fat and muscle measures (Figure 2). In the PCA, the first two components explained 27.5% and 20.9% of the variance, and patients with and without gallstones overlapped extensively (Figure 3). No single dominant axis of variation separates the groups.

Key clinical variables by gallstone status

Figure 1. Boxplots of 14 key clinical variables by gallstone status.

Spearman correlation heatmap

Figure 2. Spearman correlation between numeric variables, ordered by hierarchical clustering. Blocks of strongly correlated body-composition measures are visible.

PCA of numeric variables

Figure 3. PCA of standardised numeric variables. One patient with an implausible obesity value was excluded. Groups overlap extensively.

5.2 Statistical comparison

Of the 38 variables tested, 15 differed significantly between the groups after correction for multiple testing (Table 1, Figure 4). The largest differences were for CRP, which was higher in patients with gallstones (median 1.29 vs 0 mg/L, effect size 0.58, adjusted p < 0.001), and for vitamin D, which was lower (17.0 vs 25.3 ng/mL, effect size 0.44, adjusted p < 0.001). AST was moderately lower in patients with gallstones (effect size 0.33). Patients with gallstones also had higher body fat, total fat content and visceral fat area, lower lean mass and bone mass, more hyperlipidemia (5.1% vs 0%) and a higher proportion of women (57.0% vs 41.6%). The remaining effects were small (0.15 to 0.26).

In the sex-stratified tests, CRP, vitamin D and AST differed significantly in both men and women (unadjusted p between 1e-13 and 0.0055 in each sex). Bone mass and hemoglobin differed significantly only in men, and body fat and lean mass were borderline in each sex (unadjusted p between 0.026 and 0.070).

Table 1. Variables that differed significantly between patients with and without gallstones (Benjamini-Hochberg adjusted p < 0.05). Values are medians for numeric variables and percentages for sex (% female) and hyperlipidemia (% with the condition). Effect size = |2 x AUC - 1|.

Variable	Gallstone	Control	Higher in	Effect	Adj. p
C-reactive protein (mg/L)	1.29	0	Gallstone	0.58	< 0.001
Vitamin D (ng/mL)	17.0	25.3	Control	0.44	< 0.001
AST (U/L)	16.5	20.0	Control	0.33	< 0.001
Total body fat ratio (%)	31.0	25.8	Gallstone	0.26	0.0004
Lean mass (%)	68.8	73.9	Control	0.26	0.0004
Bone mass (kg)	2.6	2.9	Control	0.25	0.0006
Total fat content (kg)	24.8	20.1	Gallstone	0.22	0.003
Hemoglobin (g/dL)	14.2	14.9	Control	0.22	0.003
Extracellular water (kg)	16.6	17.5	Control	0.21	0.0055
HDL cholesterol (mg/dL)	47.5	45.0	Gallstone	0.20	0.007
Hyperlipidemia (%)	5.1	0	Gallstone	n/a	0.011
Visceral fat area	12.5	10.6	Gallstone	0.18	0.017
Sex (% female)	57.0	41.6	Gallstone	n/a	0.021
Extracellular fluid / total body water (%)	42	42	Control	0.15	0.046
Creatinine (mg/dL)	0.74	0.82	Control	0.15	0.046

Top variables by significance

Figure 4. The 15 variables with the smallest adjusted p-values. The dashed line marks adjusted p = 0.05.

5.3 Predictive modelling

In cross-validation on the training set, the mean AUC was 0.858 for logistic regression, 0.835 for random forest and 0.829 for the SVM (Figure 5). On the held-out test set, AUC was 0.894 (95% CI 0.810 to 0.978), 0.898 (0.822 to 0.974) and 0.845 (0.748 to 0.942) respectively, and accuracy was 0.810, 0.825 and 0.746 (Table 2, Figure 6). The confidence intervals overlap, so the data do not show that any model outperformed the others.

Table 2. Model performance. Cross-validation (CV) values are means over 30 resamples on the training set. Test values come from the 63 held-out patients, with gallstones as the positive class.

Model	CV AUC	CV sensitivity	CV specificity	Test AUC (95% CI)	Test accuracy	Test sensitivity	Test specificity
Logistic regression	0.858	0.719	0.811	0.894 (0.810 to 0.978)	0.810	0.839	0.781
Random forest	0.835	0.739	0.781	0.898 (0.822 to 0.974)	0.825	0.871	0.781
Support vector machine	0.829	0.737	0.799	0.845 (0.748 to 0.942)	0.746	0.806	0.688

Cross-validation comparison

Figure 5. Distribution of cross-validated ROC (AUC), sensitivity and specificity for the three models (30 resamples).

ROC curves on the test set

Figure 6. ROC curves of the three models on the held-out test set (63 patients).

In random forest variable importance, CRP and vitamin D were the two most important variables, followed by a group of variables with similar, smaller importance (Figure 7). In the logistic regression, vitamin D (odds ratio 0.40 per standard deviation, p = 0.0001) and CRP (odds ratio 5.86, p = 0.011) were the clearest independent predictors. Other coefficients, such as obesity percentage and bone mass, were unstable because they are strongly correlated with other body-composition variables, so we do not interpret them.

Random forest variable importance

Figure 7. The 15 most important variables in the random forest (scaled 0 to 100).

6. Discussion

Main findings. Two measurements stood out. Patients with gallstones had higher CRP and lower vitamin D than controls. These were the two largest effects in the statistical tests, the two most important variables in the random forest, and the two clearest predictors in the logistic regression. They remained significant in men and women separately, so the higher proportion of women among patients with gallstones does not explain them. Several body-composition differences (higher fat, lower lean and bone mass, lower hemoglobin and creatinine) were also found. These are partly sex-related, since women typically differ from men on these measures, and the sex-stratified tests supported only some of them, so we treat them as weaker evidence.

Comparison with the literature. The original authors also report vitamin D and CRP as the most important features, together with total body water, lean mass, total body fat ratio and bone mass, and they discuss vitamin D deficiency and raised CRP as being associated with gallstone formation (Esen et al., 2024). Most of our top variables are in their list. Their best accuracy was 85.4% with gradient boosting on a 70/30 split, and ours was 0.81 to 0.83 for logistic regression and random forest on an 80/20 split, so the performance is comparable, though the splits and tuning differ. Our SVM performed better than the SVM reported in the original paper (AUC 0.48). One possible reason is that we standardised the variables inside the modelling pipeline, but we did not test this. Total body water, which the original authors rank highly, was not among our 15 significant variables, which may reflect the different test used.

Unexpected and uncertain results. AST was lower and HDL slightly higher in patients with gallstones, which is not the usual pattern, and our data do not allow us to explain it. HDL had a small effect size (0.20) and may be a chance finding. CRP also needs caution: 58.4% of controls had a recorded CRP of exactly 0, compared with 19.6% of patients with gallstones. A recorded 0 probably means a value below the detection limit, but the documentation does not say, so differences in how CRP was recorded could contribute to the result.

Limitations. (1) The data come from one hospital, with no external validation. (2) The test set is small (63 patients), so the performance estimates are imprecise, as the wide confidence intervals show. Cross-validation estimates are more stable. (3) The data are cross-sectional, so we can describe associations but not causes, and we cannot say whether low vitamin D or high CRP precede gallstones. (4) People who had gallbladder surgery were excluded, so the data do not represent all patients with gallstone disease. (5) Many body-composition variables are strongly correlated, which makes individual coefficients and importance scores hard to interpret. (6) Two implausible values were imputed. (7) The group labels in the public files conflict with the publication, and we resolved this by inference (Section 3).

Real-world implications. An AUC of about 0.85 with a wide margin of error is not accurate enough to replace ultrasound. A model like this could at most support screening, for example by flagging patients for imaging, and it would need external validation in other populations first. The more useful result for clinicians may be the finding that two cheap blood tests, CRP and vitamin D, differ strongly between groups.

7. Conclusion and future work

In this dataset, patients with gallstones had higher CRP and lower vitamin D than controls, and simple models using routine measurements predicted gallstone status with a cross-validated AUC of about 0.83 to 0.86, with no clear difference between logistic regression, random forest and SVM. The results are consistent with the original publication but come from a single centre and a small test set. Future work should validate the models on data from other hospitals, clarify how CRP was measured and recorded, use larger samples with prospective follow-up, and check the dataset's label coding with its authors.

8. Reproducibility

Repository structure:

2021ICT116/
├── README.md                      this report
├── code/
│   ├── 00_check_data.R            quick check that the data load
│   ├── gallstone_analysis.Rmd     full analysis (cleaning, EDA, tests, models)
│   └── gallstone_analysis.html    rendered notebook, including SessionInfo
├── data/
│   ├── dataset-uci.xlsx           raw UCI data
│   ├── gallstone_clean.csv        cleaned data
│   ├── statistical_test_results.csv
│   └── model_performance.csv
└── figures/                       all figures used in this report

To reproduce the results:

Clone the repository and open 2021ICT116.Rproj in RStudio.
Install the required packages once in the console: install.packages(c("tidyverse", "readxl", "janitor", "skimr", "naniar", "corrplot", "pheatmap", "caret", "randomForest", "e1071", "kernlab", "pROC", "rmarkdown", "knitr"))
Open code/gallstone_analysis.Rmd and click Knit. The notebook reads data/dataset-uci.xlsx and writes the figures to figures/ and the result tables to data/.

Random seeds are fixed (set.seed(123)), so results should reproduce on the same package versions. The R and package versions used are listed in the SessionInfo section at the end of code/gallstone_analysis.html. Training the random forest takes a few minutes.

9. References

Benjamini, Y. and Hochberg, Y. (1995) 'Controlling the false discovery rate: a practical and powerful approach to multiple testing', Journal of the Royal Statistical Society: Series B, 57(1), pp. 289-300.

Chakraborty, C. and Mukherjee, N. (2025) 'Bayesian hybrid machine learning of gallstone risk', arXiv, 2506.14561.

Esen, I., Arslan, H., Aktürk, S., Gülşen, M., Kültekin, N. and Özdemir, O. (2024) Gallstone [Dataset]. UCI Machine Learning Repository. Available at: https://archive.ics.uci.edu/dataset/1150/gallstone-1 (Licence: CC BY 4.0).

Esen, I., Arslan, H., Aktürk Esen, S., Gülşen, M., Kültekin, N. and Özdemir, O. (2024) 'Early prediction of gallstone disease with a machine learning-based method from bioimpedance and laboratory data', Medicine, 103(8), e37258. doi:10.1097/MD.0000000000037258.

Karatzoglou, A., Smola, A., Hornik, K. and Zeileis, A. (2004) 'kernlab: an S4 package for kernel methods in R', Journal of Statistical Software, 11(9), pp. 1-20.

Kuhn, M. (2008) 'Building predictive models in R using the caret package', Journal of Statistical Software, 28(5), pp. 1-26.

Liaw, A. and Wiener, M. (2002) 'Classification and regression by randomForest', R News, 2(3), pp. 18-22.

R Core Team (2024) R: a language and environment for statistical computing. Vienna: R Foundation for Statistical Computing. Available at: https://www.R-project.org/.

Robin, X. et al. (2011) 'pROC: an open-source package for R and S+ to analyze and compare ROC curves', BMC Bioinformatics, 12, 77.

Wickham, H. et al. (2019) 'Welcome to the tidyverse', Journal of Open Source Software, 4(43), 1686.