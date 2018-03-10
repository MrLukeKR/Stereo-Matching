clear;

filenames = dir('im*.png');
filenames = sort({filenames.name});

windowSize = 8;

im = imread(filenames{1});
data = repmat(uint8(0),[size(im,1) size(im,2) length(filenames)]);

for ii = 1:length(filenames)
    data(:,:,ii) = rgb2gray(imread(filenames{ii}));
end

dsi = zeros(size(data,2) - windowSize, size(data,2) - windowSize);

im1 = data(:,:,1);
im2 = data(:,:,2);

joint = imfuse(im1,im2);

%imshow(joint);

disparityImage = [];
alternateImage = [];

for y = 1 + (windowSize / 2) : size(im1,1) - (windowSize / 2)
    for x1 = 1 + (windowSize / 2) : size(im1,2) - (windowSize / 2)
        leftPatch = im1(y - (windowSize / 2):y + (windowSize/2) - 1, x1 - (windowSize/2):x1+(windowSize / 2) - 1);
        
        for x2 = 1 + (windowSize / 2) : size(im1,2) - (windowSize / 2)
            rightPatch = im2(y - (windowSize / 2): y + (windowSize/2) - 1, x2 - (windowSize/2):x2+(windowSize / 2) - 1);
            diff = double(leftPatch) - double(rightPatch);
            diffSq = diff .^2;
            SSE = sum(sum(diffSq));
            
            dsi(x2 - windowSize/2,x1-windowSize/2) = SSE;
        end
    end
    
    dsi = dsi ./ max(dsi);
    imshow(dsi);
    
    C = zeros(size(dsi,1),size(dsi,2));
    Pointers = zeros(size(dsi,1),size(dsi,2));
    occlusionConstant = 0.1;
    
    for i = 2 : size(dsi,2)
        C(i, 1) = C(i-1,1) + occlusionConstant;
        C(1, i) = C(1,i-1) + occlusionConstant;
        Pointers(i,1) = 2;
        Pointers(1,i) = 3;
    end
    
    for i = 2 : size(dsi,2)
        for j = 2 : size(dsi,1)
            values = [C(i-1,j-1) + dsi(i,j), C(i-1,j) + occlusionConstant, C(i,j-1) + occlusionConstant];
            [val, idx] = min(values);
            C(i, j) = val;
            Pointers(i,j) = idx;
        end
    end
    
    i = size(dsi,2);
    j = size(dsi,1);
    path = [];
    
    disparity = 0;  
    newScanline = zeros(1,size(dsi,1));
    
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
    
    hold on;
    plot(path(:,2),path(:,1));
    hold off;
    set(gca, 'YDir','reverse')
    
    newScanline = zeros(1,size(dsi,1));
    
    
    for zX = 1 : size(path,1)
        xLoc = path(zX,1);
        yLoc = path(zX,2);
        if(zX < size(path,1) && xLoc == path(zX+1,1) + 1 && yLoc == path(zX+1,2) + 1)
        newScanline(xLoc) = sqrt((xLoc - yLoc) ^ 2);      
        else
        newScanline(xLoc) = 0; 
        end
    end
    
    disparityImage = [disparityImage; newScanline];
end

imshow(disparityImage ./ max(disparityImage));