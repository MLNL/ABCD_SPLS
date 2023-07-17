## CCA/PLS models

In this section, we present the formulations of the different CCA and PLS models implemented in the toolkit.

Notations:

- $\mathbf{X}$ and $\mathbf{Y}$ are matrices for data modalities containing one (standardized) variable/feature per column and one example/sample per row,
- $||\mathbf{w}||_2$ is the L2-norm of a vector $\mathbf{w}$, i.e., square root of the sum of squares of weight values,
- $||\mathbf{w}||_1$ is the L1-norm of a vector $\mathbf{w}$, i.e., sum of absolute weight values.

### Canonical Correlation Analysis (CCA)

CCA finds a pair of weights, $\mathbf{u}$ and $\mathbf{v}$, such that the __correlation__ between the projections of $\mathbf{X}$ and $\mathbf{Y}$ onto these weights are maximised:
$$
max_{\mathbf{u},\mathbf{v}} \text{ } corr(\mathbf{Xu},\mathbf{Yv})
$$

Most commonly though, CCA is expressed in the form of a constrained optimization problem:
$$
max_{\mathbf{u},\mathbf{v}} \text{ } \mathbf{u}^T\mathbf{X}^T\mathbf{Yv}
$$
$$
\text{subject to } \mathbf{u}^T\mathbf{X}^T\mathbf{Xu} = 1,\\
\mathbf{v}^T\mathbf{Y}^T\mathbf{Yv} = 1
$$

We highlight that it is not possible to obtain a solution for this standard CCA when the number of variables exceeds the number of examples (technically speaking, the optimization problem is ill posed). Two approaches have been proposed to address this problem:

- reducing the dimensionality of the data with Principal Component Analysis (PCA),
- using regularized extensions of CCA (e.g., adding L1-norm and/or L2-norm regularization).

We note that although PLS always has a solution (i.e., never ill posed) irrespective of the number of variables, it might still benefit from regularization (e.g., adding L1-norm regularization).

### CCA with PCA dimensionality reduction (PCA-CCA)

PCA transforms each modality of multivariate data into uncorrelated principal components. PCA is often used as naive dimensionality reduction technique, as principal components explaining little variance arre assumed to be noise and discarded, and the remaining principal components are entered into CCA.

However, PCA when applied before CCA can be also seen as a technique similar to regularization, and in practice it often gives similar results to [Regularized CCA](#regularized-cca-rcca) when the number of principal components are chosen data-driven. For additional details, see our upcoming tutorial paper. 

### Partial Least Squares (PLS)

PLS finds a pair of weights, $\mathbf{u}$ and $\mathbf{v}$, such that the __covariance__ between the projections of $\mathbf{X}$ and $\mathbf{Y}$ onto these weights are maximised:
$$
max_{\mathbf{u},\mathbf{v}} \text{ } cov(\mathbf{Xu},\mathbf{Yv})
$$

Similar to CCA, PLS is most often expressed as a constrained optimization problem in the following form:
$$
max_{\mathbf{u},\mathbf{v}} \text{ } \mathbf{u}^T\mathbf{X}^T\mathbf{Yv}
$$
$$
\text{subject to } ||\mathbf{u}||_2^2 = 1,\\
||\mathbf{v}||_2^2 = 1
$$

PLS is a family of methods. Depending on the modelling aim, PLS variants can be divided into two main groups:

- __symmetric variants__ (PLS-mode A, PLS-SVD): with the aim of identifying associations between two data modalities,
- __asymmetric variants__ (PLS1, PLS2): with the aim of predicting one modality from another modality.

All PLS variants use the same optimization problem but they differ in their [deflation strategies](#deflation-methods). Therefore, whereas all variants yield the same first associative effect, the weights from the second associative effects will be different. 

### Regularized CCA (RCCA)

In RCCA, __L2-norm regularization__ is added to the CCA optimization, which leads to the following constrained optimization problem:
$$
max_{\mathbf{u},\mathbf{v}} \text{ } \mathbf{u}^T\mathbf{X}^T\mathbf{Yv}
$$
$$
\text{subject to } (1-\tau_{u})\mathbf{u}^T\mathbf{X}^T\mathbf{Xu}+\tau_{u}||\mathbf{u}||_2^2 = 1,
$$

$$
(1-\tau_{v})\mathbf{v}^T\mathbf{Y}^T\mathbf{Yv}+\tau_{v}||\mathbf{v}||_2^2 = 1
$$

The two hyperparameters of RCCA ($\tau_{u}$, $\tau_{v}$) control the amount of L2-norm regularization. We can see that these hyperparameters provide a smooth transition between CCA ($\tau_{u}=\tau_{v}=0$, not regularized) and PLS ($\tau_{u}=\tau_{v}=1$, most regularized), thus RCCA can be thought of as a mixture of CCA and PLS optimization.

### Sparse PLS (SPLS)

In SPLS, __L1-norm regularization__ is added to the PLS optimization, which leads to the following constrained optimization problem:
$$
max_{\mathbf{u},\mathbf{v}} \text{ } \mathbf{u}^T\mathbf{X}^T\mathbf{Yv}
$$
$$
\text{subject to } ||\mathbf{u}||_2^2 \le 1,\\
||\mathbf{u}||_1 \le c_u,\\
||\mathbf{v}||_2^2 \le 1,\\
||\mathbf{v}||_1 \le c_v\\
$$

The two hyperparameters of SPLS ($c_{u}$, $c_{v}$) control the amount of L1-norm regularization. These hyperparameters set an upper limit to the L1-norm of the weights, thus imposing sparsity on the weights (i.e., some of the weight values will be set to 0).

Similar to PLS, SPLS can also have different variants based on the deflation strategies.

## Analysis frameworks

In order to optimize the hyperparameters (i.e., number of principal components or regularization parameter) and to perform statistical inference (i.e., assess the number of significant associative effects), the CCA/PLS model is embedded in an analytical framework.

1. In a __statistical framework__, CCA/PLS is fitted on the entire data and usually there is no hyperparameter optimization (i.e., the number of principal components or regularization parameters is fixed).
2. In a __machine learning framework__, CCA/PLS is fitted on a training set and evaluated on a test set (outer data split), thus it assesses how well the associative effect found in the training set generalizes to an independent test set. Moreover, the hyperparameters are usually optimized, therefore the training set is further divided into an inner training and validation set (inner data split). To account for robustness, the outer and inner data splitting processes are often repeated multiple times.

The figure below illustrates a machine learning framework with multiple holdouts/test sets. It is adapted from [Mihalik, A. et al. (2020)](https://doi.org/10.1016/j.biopsych.2019.12.001).

<p align="center">
   <img src="../figures/framework.png" width="695" height="217">
</p>


Both the statistical and machine learning frameworks are available in the toolkit, and in both cases the number of significant associative effects is assessed based on permutation testing.

An important component of the CCA/PLS framework is testing the __stability__ of the model. In the toolkit, the stability of the CCA/PLS models is measured as the average similarity of weights across different splits of the training data. Of course, this can be calculated if at least two splits of data are available for the training set.

## Deflation methods

CCA/PLS models and their regularized variants can be divided into three groups based on their deflation strategy.

1. __CCA__, __RCCA__ and __PLS-SVD__ can be all seen as subcases of the generalized eigenvalue problem. The iterative solution of the generalized eigenvalue problem uses generalized deflation, which thus will be the deflation strategy for these models. This deflation can be written as:
$$
\mathbf{X}\leftarrow\mathbf{X}-\mathbf{Xuu}^T\mathbf{B_{x}}
$$
$$
\mathbf{Y}\leftarrow\mathbf{Y}-\mathbf{Yvv}^T\mathbf{B_{y}}
$$
where we used the same notations as in the CCA/PLS models and $\mathbf{B_{x}},\mathbf{B_{y}}$ define the different subcases of the generalized eigenvalue problem. In case of RCCA, $\mathbf{B_{x}} = (1-\tau_{u})\mathbf{X}^T\mathbf{X}+\tau_{u}\mathbf{I}$ and $\mathbf{B_{y}} = (1-\tau_{v})\mathbf{Y}^T\mathbf{Y}+\tau_{v}\mathbf{I}$, where $\tau_{u}$ and $\tau_{v}$ are the hyperparameters of L2-norm regularization in [RCCA](#regularized-cca-rcca). CCA and PLS-SVD are specific cases of $\tau_{u}=\tau_{v}=0$ and $\tau_{u}=\tau_{v}=1$, respectively.

2. __PLS-mode A__ uses the following deflation:
$$
\mathbf{X}\leftarrow\mathbf{X}-\mathbf{X}\mathbf{u}\mathbf{p}^T
$$
$$
\mathbf{Y}\leftarrow\mathbf{Y}-\mathbf{Y}\mathbf{v}\mathbf{q}^T
$$
where $\mathbf{p}=\frac{\mathbf{X}^T\mathbf{Xu}}{\mathbf{u}^T\mathbf{X}^T\mathbf{Xu}}$ and
$\mathbf{q}=\frac{\mathbf{Y}^T\mathbf{Yv}}{\mathbf{v}^T\mathbf{Y}^T\mathbf{Yv}}$.

3. __PLS1__ and __PLS2__ are regression methods (PLS1 refers to the variant with a single output variable and PLS2 refers to the variant with multiple output variables), in which case only the input data needs to be deflated as follows:
$$
\mathbf{X}\leftarrow\mathbf{X}-\mathbf{X}\mathbf{u}\mathbf{p}^T
$$
where the same notations are used as above.


