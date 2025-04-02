clc; clear; close all;

% Select Image
[file, path] = uigetfile({'*.jpg;*.png;*.tif;*.bmp'}, 'Select an Image');
if isequal(file, 0)
    disp('User canceled file selection');
    return;
end
imgPath = fullfile(path, file);
disp(['File selected: ', imgPath]);

% Read Image
img = imread(imgPath);
grayImg = rgb2gray(img);

% Contrast Enhancement
grayImg = adapthisteq(grayImg); 

% Edge Detection for Grain Boundaries
edges = edge(grayImg, 'canny');  

% Convert Edge Map to Binary Image
binaryImg = imbinarize(grayImg, 'adaptive', 'Sensitivity', 0.4);

% Overlay Edge Map to Restore Boundaries
binaryImg = binaryImg | edges;  

% Morphological Operations
binaryImg = bwareaopen(binaryImg, 20); 
binaryImg = imfill(binaryImg, 'holes'); 
se = strel('disk', 1);
binaryImg = imclose(binaryImg, se); 

% Display Images
figure;
subplot(1,2,1); imshow(img); title('Original Micrograph');
subplot(1,2,2); imshow(binaryImg); title('Processed Binary Image');

% Save Processed Image
saveas(gcf, 'processed_image.fig');
disp('Processed image saved.');

% Grain Analysis
[labeledGrains, numGrains] = bwlabel(binaryImg);
stats = regionprops(labeledGrains, 'Area');

% Adjust Scale Based on Image Scale Bar
scaleFactor = 100 / 70;  
grainAreas = [stats.Area] * (scaleFactor^2); 
grainSizes = 2 * sqrt(grainAreas / pi);  

% Compute Statistical Parameters
stdGrainSize = std(grainSizes); % Standard Deviation
avgGrainSize = mean(grainSizes);
maxGrainSize = max(grainSizes);
minGrainSize = min(grainSizes);

% Display Results
disp(['Total Number of Grains: ', num2str(numGrains)]);
disp(['Average Grain Size: ', num2str(avgGrainSize), ' µm']);
disp(['Maximum Grain Size: ', num2str(maxGrainSize), ' µm']);
disp(['Minimum Grain Size: ', num2str(minGrainSize), ' µm']);
disp(['Standard Deviation: ', num2str(stdGrainSize), ' µm']);

% Plot Grain Size Distribution with KDE
figure;
histogram(grainSizes, 'BinWidth', 0.5, 'Normalization', 'pdf', 'FaceColor', 'b', 'EdgeColor', 'k');
hold on;
x_values = linspace(min(grainSizes), max(grainSizes), 1000);
density = ksdensity(grainSizes, x_values);
plot(x_values, density, 'r', 'LineWidth', 2);
xlabel('Grain Size (µm)');
ylabel('Probability Density');
title('Grain Size Distribution');
legend('Histogram', 'KDE Curve');
grid on;
set(gca, 'FontSize', 14);