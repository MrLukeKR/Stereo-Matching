filenames = dir('im*.png');
filenames = sort({filenames.name});

im = imread(filenames{1});
data = repmat(uint8(0),[size(im,1) size(im,2) length(filenames)]);

for ii = 1:length(filenames)
    data(:,:,ii) = rgb2gray(imread(filenames{ii}));
end

im1 = data(:,:,1);
im2 = data(:,:,2);

[im1hogFeatures, validFeat1] = extractHOGFeatures(im1,[2,2]);
[im2hogFeatures, validFeat2] = extractHOGFeatures(im2, [2,2]);

[features1, valid1] = extractFeatures(im1,validFeat1);
[features2, valid2] = extractFeatures(im2,validFeat2);

matches = matchFeatures(features1, features2);

showMatchedFeatures(im1,im2,valid1(matches(:,1)),valid2(matches(:,2)));