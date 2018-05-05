function disparity = gradientFeaturesToDisparity(leftImage, rightImage, windowSize, maxSearchSpace)
width = size(leftImage,2);
height = size(leftImage,1);
featureSize = (windowSize ^ 2) * 2;

progressBar = waitbar(0,  'Performing Gradient Feature Matching...');

disparity = zeros(height - windowSize, width - windowSize);

for y = 1 : height - windowSize
    leftDescriptors = zeros(featureSize, width - windowSize);
    rightDescriptors = zeros(featureSize, width - windowSize);
    disparityLine = zeros(1, width - windowSize);
    
    parfor x = 1 : width - windowSize
        leftSubImage = leftImage(y : y + windowSize - 1, x : x + windowSize - 1);
        [ leftGx, leftGy ] = imgradientxy(leftSubImage);
        leftDescriptor = [ leftGx(:); leftGy(:) ];
        leftDescriptors(:,x) = leftDescriptor;
        
        rightSubImage = rightImage(y : y + windowSize - 1, x : x + windowSize - 1);
        [ rightGx, rightGy ] = imgradientxy(rightSubImage);        
        rightDescriptor = [ rightGx(:); rightGy(:) ];
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