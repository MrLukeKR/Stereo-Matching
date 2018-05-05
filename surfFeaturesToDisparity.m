function disparity = surfFeaturesToDisparity(leftImage, rightImage, windowSize, maxSearchSpace)
width = size(leftImage,2);
height = size(leftImage,1);

progressBar = waitbar(0,  'Performing SURF Feature Matching...');

leftSubImage   = leftImage (1 : windowSize, 1 : windowSize);
surfFeatures = detectSURFFeatures(leftSubImage, 'MetricThreshold', 1);
leftDescriptor = extractFeatures(leftSubImage, surfFeatures);

featureSize = min(8, size(leftDescriptor, 1));

disparity = zeros(height - windowSize, width - windowSize);

for y = 1 : height - windowSize
    leftDescriptors = zeros(featureSize * 64, width - windowSize);
    rightDescriptors = zeros(featureSize * 64, width - windowSize);
    disparityLine = zeros(1, width - windowSize);
    
    parfor x = 1 : width - windowSize
        leftSubImage  = leftImage (y : y + windowSize - 1, x : x + windowSize - 1);
        rightSubImage = rightImage(y : y + windowSize - 1, x : x + windowSize - 1);

        leftSURF = detectSURFFeatures(leftSubImage, 'MetricThreshold', 1);
        rightSURF = detectSURFFeatures(rightSubImage, 'MetricThreshold', 1);
        
        [leftDescriptor, lPoints] = extractFeatures(leftSubImage, leftSURF);
        [rightDescriptor, rPoints] = extractFeatures(rightSubImage, rightSURF);
        

        leftDescriptors(:,x) = reshape(leftDescriptor(1:featureSize, :)', [featureSize * 64 1]);
        rightDescriptors(:,x) = reshape(rightDescriptor(1:featureSize, :)', [featureSize * 64 1]);
    end
    
    for rightX = 1 : width - windowSize
        SSDs = [];
        
        bound = maxSearchSpace + windowSize;
        
        for leftX = max(1, rightX) : min(rightX + bound, width - windowSize)
            diff = leftDescriptors(:, leftX) - rightDescriptors(:, rightX);
            diffSq = diff .^2;
            SSDs = [SSDs, sum(sum(diffSq))];
        end
        
        [val, loc] = min(SSDs);
        
        disparityLine(rightX) = loc;
    end
    
    disparity(y, :) = disparityLine;
    imshow(disparity./max(max(disparity)));
    waitbar(y / height, progressBar);
end
close(progressBar);
disparity = disparity./max(max(disparity));
end