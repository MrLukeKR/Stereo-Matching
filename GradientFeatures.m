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
windowSize = 32;

disparity = zeros(size(im1,1) - windowSize, size(im1,2) - windowSize);

for y = 1 + (windowSize / 2) : size(im1,1) - (windowSize / 2)
    im2Descriptors = zeros(size(im1,1) - (windowSize/2), (windowSize^2) * 2);
    disparityLine = zeros(1, size(im1,1) - (windowSize/2));
    for x = 1 + (windowSize / 2) : size(im1,2) - (windowSize/2)
        subImage = im2(y - (windowSize / 2) : y + (windowSize / 2) - 1, x - (windowSize /2)  : x + (windowSize / 2) -1);
        [Gx2, Gy2] = imgradientxy(subImage);
        f1Im2 = Gx2(:);
        f2Im2 = Gy2(:);
        
        descriptorIm2 = [f1Im2;f2Im2];
        im2Descriptors(x,:) = descriptorIm2;
    end
    for x = 1 + (windowSize / 2) : size(im1,2) - (windowSize/2)
        [Gx1, Gy1] = imgradientxy(im1(y - (windowSize / 2) : y + (windowSize / 2) -1, x - (windowSize /2)  : x + (windowSize / 2)-1));
        f1Im1 = Gx1(:);
        f2Im1 = Gy1(:);
        
        descriptorIm1 = [f1Im1;f2Im1];
        maxCorrelation = 0;
        SSDs = zeros(1, size(im1,2) - windowSize);
        
        for x1 = 1 : size(im1,2) - windowSize
            SSDs(x1) = sum((im2Descriptors(x1, :)' - descriptorIm1) .^2);
        end
        
        [val, loc] = min(SSDs);
        disparityLine(x - (windowSize /2)) = abs(loc - x);
    end
    disparity(y - (windowSize / 2) ,:) = disparityLine;
    imshow(disparity./max(disparity));
end

imshow(disparity./max(disparity));