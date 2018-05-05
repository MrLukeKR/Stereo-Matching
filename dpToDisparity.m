function disparity = dpToDisparity(leftImage, rightImage, windowSize)
width = size(leftImage,2);
height = size(leftImage,1);

progressBar = waitbar(0,  'Performing Dynamic Programming...');

dsi = zeros(width - windowSize, width - windowSize);

dsiSize = size(dsi,2);

disparity = zeros(height - windowSize, width - windowSize);

for y = 1 : height - windowSize
    parfor leftX = 1 : width - windowSize
        leftPatch = leftImage(y : y + windowSize - 1, leftX : leftX + windowSize - 1);        
        
        for rightX = 1 : width - windowSize
            rightPatch = rightImage(y : y + windowSize - 1, rightX : rightX + windowSize - 1);
        
            diff = double(leftPatch) - double(rightPatch);
            diffSq = diff .^2;
            SSE = sum(sum(diffSq));
            
            dsi(rightX, leftX) = SSE;
        end
    end
    
    dsi = dsi./max(max(dsi));
    
    C = zeros(dsiSize, dsiSize);
    Pointers = zeros(dsiSize, dsiSize);
    occlusionConstant = 0.1;
    
    for i = 2 : dsiSize
        C(i, 1) = C(i-1,1) + occlusionConstant;
        C(1, i) = C(1,i-1) + occlusionConstant;
        Pointers(i,1) = 2;
        Pointers(1,i) = 3;
    end
    
    for i = 2 : dsiSize
        for j = 2 : dsiSize
            values = [C(i-1,j-1) + dsi(i,j), C(i-1,j) + occlusionConstant, C(i,j-1) + occlusionConstant];
            [val, idx] = min(values);
            C(i, j) = val;
            Pointers(i,j) = idx;
        end
    end
    
    i = dsiSize;
    j = dsiSize;
    path = [];
    
    while(i ~= 1 || j ~= 1)
        switch(Pointers(i,j))
            case 1
                i = i -1;
                j = j - 1;
            case 2
                i = i - 1;
            case 3
                j = j - 1;
        end
        
        path = [path;i,j];
    end
  
    set(gca, 'YDir','reverse')
    
    newScanline = zeros(1, dsiSize);
    
    for zX = 1 : size(path,1)
        xLoc = path(zX,1);
        yLoc = path(zX,2);
        if(zX < size(path,1) && xLoc == path(zX+1,1) + 1 && yLoc == path(zX+1,2) + 1)
        newScanline(xLoc) = sqrt((xLoc - yLoc) ^ 2);      
        else
        newScanline(xLoc) = 0; 
        end
    end
    
    disparity(y, :) = newScanline;
    waitbar(y / height, progressBar);
end
close(progressBar);
disparity = disparity ./ max(max(disparity));
end