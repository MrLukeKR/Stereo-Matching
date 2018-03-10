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

disparity = zeros(size(im1,1) - (windowSize/2), 1);

for y = 1 + (windowSize / 2) : size(im1,1) - (windowSize/2)

    for x = 1 + (windowSize / 2) : size(im1,2) - (windowSize/2)
        [Gx, Gy] = imgradientxy(im1(y - (windowSize / 2) : y + (windowSize / 2), x - (windowSize /2)  : x + (windowSize / 2)));
        f1Im1 = Gx(:);
        f2Im1 = Gy(:);
        
        descriptorIm1 = [f1Im1;f2Im1];
%        im1Descriptors(y,x,:) = descriptorIm1;
        
        for x1 = x : size(im1,2) - (windowSize/2)
            [Gx, Gy] = imgradientxy(im2(y - (windowSize / 2) : y + (windowSize / 2), x1 - (windowSize /2)  : x1 + (windowSize / 2)));
            f1Im2 = Gx(:);
            f2Im2 = Gy(:);
            
            descriptorIm2 = [f1Im2;f2Im2];
        %    im2Descriptors(y,x,:) = descriptorIm2;
            
            correlation = (1/(32*32)) * sum(sum((1 / (std2(descriptorIm1) * std2(descriptorIm2))) * ((descriptorIm1-mean(descriptorIm1)).*(descriptorIm2-mean(descriptorIm2)))));
            
            if (correlation >= maxCorrelation)
                maxCorrelation = correlation;
                disparity(y) = abs(x1 - x);
            end
        end
    end
end