function disparity = hogFeaturesToDisparity(leftImage, rightImage, windowSize, maxSearchSpace)
width = size(leftImage,2);
height = size(leftImage,1);

progressBar = waitbar(0,  'Performing HOG Feature Matching...');

cellSize = [windowSize/2 windowSize/2];
leftSubImage   = leftImage (1 : windowSize, 1 : windowSize);
leftDescriptor = extractHOGFeatures(leftSubImage,'CellSize', cellSize);

featureSize = size(leftDescriptor, 2);

disparity = zeros(height - windowSize, width - windowSize);

for y = 1 : height - windowSize
    leftDescriptors = zeros(featureSize, width - windowSize);
    rightDescriptors = zeros(featureSize, width - windowSize);
    disparityLine = zeros(1, width - windowSize);
    
    parfor x = 1 : width - windowSize
        leftSubImage  = leftImage (y : y + windowSize - 1, x : x + windowSize - 1);
        rightSubImage = rightImage(y : y + windowSize - 1, x : x + windowSize - 1);

        leftDescriptor = extractHOGFeatures(leftSubImage,'CellSize', cellSize);
        leftDescriptors(:,x) = leftDescriptor;
        
        rightDescriptor = extractHOGFeatures(rightSubImage, 'CellSize', cellSize);
        rightDescriptors(:,x) = rightDescriptor;
    end
    
    parfor rightX = 1 : width - windowSize
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
    waitbar(y / height, progressBar);
end
close(progressBar);
disparity = disparity./max(max(disparity));
end