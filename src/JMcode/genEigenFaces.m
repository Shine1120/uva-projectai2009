function [eigenFaces] = genEigenFaces(allImages)
%GENEIGENFACES Constructs a matrix of eigenfaces from allImages
%   allImages -- a 2d matrix of moneyvectors 

%% eigenvalue/vector decomposition
Psi = mean(allImages);
Difference = allImages - repmat(Psi, size(allImages, 1), 1);
[smallVectors,Values] = eig(Difference*Difference');
bigVectors = Difference'*smallVectors;
Values = diag(Values);

%% Sort the eigenvectors and values
[Values indexes] = sort(Values,'descend');
bigVectors = bigVectors(:,indexes);

%% eigenface construction
eigenFaces = zeros(size(bigVectors));
for i = 1:size(bigVectors,2)
    eigenFaces(:,i) = bigVectors(:,i)/norm(bigVectors(:,i));
end

