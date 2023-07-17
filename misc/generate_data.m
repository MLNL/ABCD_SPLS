function [X, Y, wx, wy] = generate_data(n, correl, nfeatx, nfeaty, sparsityx, sparsityy)
%GEN_SIM_DATA Generates simulated data with specified correlation
%   Generates data with two views and specified correlations and weight
%   sparsities
%   INPUTS:
%   n: integer number of samples in the output for each view
%   correlations: array containing correlations between 0 and 1 one for
%   each desired dimension
%   X_features integer number of features in X view
%   Y_features integer number of features in Y view
%   X_sparsity float fraction of active variables involved in the
%   correlated signals from X view. If 1 then all variables
%   Y_sparsity float fraction of active variables involved in the
%   correlated signals from Y view. If 1 then all variables
%
% Author: James Chapman
%
% Website: http://www.mlnl.cs.ucl.ac.uk/

%Store the true weights
true_weights={};
covs={};
%Mean for each feature in each view (in principal could be non zero)
mean=zeros(nfeatx+nfeaty,1);

%Loop through each view to set up the within view covariance and
%weights involved in the correlations
features=[nfeatx,nfeaty];
sparsities=[sparsityx,sparsityy];
for i = 1:2
    %The covariance for each view is set to be identity (but in
    %principal and in my python code this could be any PSD)
    cov_=eye(features(i));
    %Generate some random weights. NOTE: in principal we could set
    %these manually (e.g. as an input to the function) to do things
    %like have some bits of the brain light up. if we did this then the
    %only required piece in the rest of the loop is the normalization
    %step
    weights_=random('Normal',0,1,features(i),length(correl));
    %If using a fraction of the variables then mask off some of these
    %weights.
    if sparsities(i)<1
        %Convert fraction of variables to number of variables
        sparsities(i)=ceil(sparsities(i)*features(i));
        mask_=random_mask(features(i),length(correl),sparsities(i));
        weights_=weights_.*mask_;
    end
    %This ensures that each latent dimension is uncorrelated (i.e. the
    %weights are orthogonal. At the moment it uses guassian elimination
    %which can break sparsity in dimensions after the first
    weights_ = decorrelate_dims(weights_, cov_);
    %Normalize the weights so that the CCA constraints are fulfilled
    weights_=weights_./diag(sqrt(transpose(weights_)*cov_*weights_))';
    %Store these weights so we have ground truth
    true_weights{i}=weights_;
    covs{i}=cov_;
end

%Start with a block diagonal covariance for the joint (X,Y)~N(0,cov) where cov has
%zeros in the upper right and lower left quadrants so there is no
%covariance between the views.
cov=blkdiag(covs{1},covs{2});

%Now we add the covariance between views.
cross=zeros(nfeatx,nfeaty);
%For each correlation we add to the cross-covariance matrix. This
%defines the population correlation
for k=1:length(correl)
    A=correl(k)*true_weights{1}(:,k)*true_weights{2}(:,k)';
    cross=cross+covs{1}*A*covs{2};
end

%Stick the cross-covariance and its transpose top right and bottom left
cov(1+nfeatx:end, 1:nfeatx) = cross';
cov(1:nfeatx, 1+nfeatx:end) = cross;

%This is just me sampling from the joint multivariate normal distribution
cholesky=chol(cov)';
X=chol_sample(mean,cholesky,n);
Y=X(:,nfeatx+1:end);
X=X(:,1:nfeatx);

%I've split the cell to match my python
wx=true_weights{1};
wy=true_weights{2};


function mask = random_mask(p,k,active)
%This is a bit messy at the moment if I'm honest. I Basically make a random
%binary mask with features*latentdimensions and then shuffle it until each
%dimension has at least one active variable and they are all unique. If you
%can think of a good way to do this in matlab then an easy improvement.
mask=[ones(k,active) zeros(k,p-active)];
mask=reshape(mask(randperm(k*p)),p,k);
[C,ia,ic] = unique(transpose(mask),'rows');
while (sum(sum(mask,1)==0)>0) || (max(ia(:))<size(mask,2))
    mask=mask(:);
    mask=reshape(mask(randperm(k*p)),p,k);
    [C,ia,ic] = unique(transpose(mask),'rows');
end


function [weights_] = decorrelate_dims(weights_,cov_)
%Loop through each dimension of weights and subtract any correlation to the
%previous dimension.
A=transpose(weights_)*cov_*weights_;
for k = 2:size(A,1)
    weights_(:,k:end)=weights_(:,k:end)-weights_(:,k-1)*A(k-1,k:end)/A(k-1,k-1);
    A=transpose(weights_)*cov_*weights_;
end


function sample = chol_sample(mean,cholesky,n)
sample=transpose(mean+cholesky*random('Normal',0,1,size(mean,1),n));
