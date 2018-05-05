%function disparity = lbpToDisparity(leftImage, rightImage, windowSize)
leftImage(:, :) = rgb2gray(imread('im2.png')); %Load in the left iamge
rightImage(:, :) = rgb2gray(imread('im6.png')); %Load in the right iamge

width = size(leftImage,2);
height = size(leftImage,1);

labels = 16;
propagations = 50;

progressBar = waitbar(0,  'Performing Loopy Belief Propagation...');

Direction = struct('UP', 1, 'LEFT', 2, 'DOWN', 3, 'RIGHT', 4, 'CENTER', 5);

messages = zeros(height, width, 5, labels);

for belief = 1 : propagations

    waitbar(belief / propagations, progressBar);
end
close(progressBar);
%end



function messageArray = PassMessage(x, y, dir, width, labels, messageArray)
costs = zeroes(labels);
newMessage = zeroes(labels);

for i = 1 : labels
    for j = 1 : labels
        costs(j) = SmoothCost(i, j) + messageArray(y, x, Direction.CENTER, j);
        
        for d = 1 : 5
            if(dir ~= d) 
                costs(j) = costs(j) + messageArray(y, x, dir, j);
            end
        end
    end
    newMessage(i) = min(costs);
end

switch(dir)
    case Direction.LEFT
        messageArray(y, x - 1, Direction.RIGHT) = newMessage;
    case Direction.RIGHT
        messageArray(y, x + 1, Direction.LEFT) = newMessage;
    case Direction.UP
        messageArray(y - 1, x, Direction.DOWN) = newMessage;
    case Direction.DOWN
        messageArray(y + 1, x, Direction.UP) = newMessage;
end
end

function cost = DataCost(x, y, label, leftSubImage, rightSubImage)
    diff   = leftSubImage(:, x) - rightSubImage(:, x);
    diffSq = diff .^2;
    cost = sum(sum(diffSq));
end

function cost = SmoothCost(x, y)
    lambda = 10;
    truncation = 3;
    cost = lambda * min(abs(x - y), truncation);
end