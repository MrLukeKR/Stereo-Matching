clear;
filenames = dir('im*.png');
filenames = sort({filenames.name});

im = imread(filenames{1});
data = repmat(uint8(0),[size(im,1) size(im,2) length(filenames)]);

for ii = 1:length(filenames)
    data(:,:,ii) = rgb2gray(imread(filenames{ii}));
end

im1 = data(:,:,1);
im2 = data(:,:,2);

windowSize = 16;
featureSize = size(extractHOGFeatures(im1(1 : windowSize+1, 1 : windowSize+1)),2);
disparity = zeros(size(im1,1) - windowSize, size(im1,2) - windowSize);

for y = 1 + (windowSize / 2) : size(im1,1) - (windowSize / 2)
    im2hogFeatures = zeros(size(im1,1) - (windowSize/2), featureSize);
    disparityLine = zeros(1, size(im1,1) - (windowSize/2));
    for x = 1 + (windowSize / 2) : size(im1,2) - (windowSize/2)
        subImage = im2(y - (windowSize / 2) : y + (windowSize / 2) - 1, x - (windowSize /2)  : x + (windowSize / 2) -1);
        im2hogFeature = extractHOGFeatures(subImage);
        
        im2hogFeatures(x,:) = im2hogFeature;
    end
    for x = 1 + (windowSize / 2) : size(im1,2) - (windowSize/2)
        subImage = im1(y - (windowSize / 2) : y + (windowSize / 2) - 1, x - (windowSize /2)  : x + (windowSize / 2) -1);
        im1hogFeature = extractHOGFeatures(subImage);
        
        SSDs = zeros(1, size(im1,2) - windowSize);
        
        for x1 = 1 : size(im1,2) - windowSize
            SSDs(x1) = sum((im2hogFeatures(x1, :) - im1hogFeature) .^2);
        end
        
        [val, loc] = min(SSDs);
        disparityLine(x - (windowSize /2)) = abs(loc - x);
    end
    disparity(y - (windowSize / 2) ,:) = disparityLine;
    imshow(disparity./max(disparity));
end

imshow(disparity./max(disparity));