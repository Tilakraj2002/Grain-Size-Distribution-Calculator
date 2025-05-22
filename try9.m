% MATLAB script to identify grain boundaries and compute grain size distribution
clear all; close all; clc;

% Step 1: Prompt user to upload the image
disp('Please upload the micrograph image for analysis.');
[filename, filepath] = uigetfile({'*.jpg;*.png;*.tif', 'Image Files (*.jpg, *.png, *.tif)'}, 'Select a micrograph image');
if isequal(filename, 0)
    disp('No file selected. Exiting...');
    return;
end
img_path = fullfile(filepath, filename);
img = imread(img_path);

% Convert to grayscale if the image is RGB
if size(img, 3) == 3
    img_gray = rgb2gray(img);
else
    img_gray = img;
end

% Step 2: Preprocess the image
% Apply Gaussian filter to reduce noise
img_smooth = imgaussfilt(img_gray, 2);

% Enhance contrast
img_adj = imadjust(img_smooth);

% Step 3: Detect grain boundaries using edge detection
% Use Canny edge detection to find grain boundaries
edges = edge(img_adj, 'Canny', [0.05 0.2]);

% Dilate edges to connect broken boundaries
se = strel('disk', 1);
edges_dilated = imdilate(edges, se);

% Step 4: Create a binary mask and clean up
% Invert the edges to use for watershed segmentation
binary_img = ~edges_dilated;

% Remove small objects (noise)
binary_img = bwareaopen(binary_img, 50);

% Step 5: Segment grains using watershed transform
% Compute distance transform
D = bwdist(~binary_img);
D = -D;

% Apply watershed transform
L = watershed(D);
L(~binary_img) = 0;

% Step 6: Overlay grain boundaries on the original image
% Create an RGB version of the original grayscale image
img_rgb = cat(3, img_gray, img_gray, img_gray);

% Highlight grain boundaries in red
img_rgb(:,:,1) = img_rgb(:,:,1) + uint8(255 * (L == 0)); % Red channel
img_rgb(:,:,2) = img_rgb(:,:,2) - uint8(50 * (L == 0));  % Reduce green
img_rgb(:,:,3) = img_rgb(:,:,3) - uint8(50 * (L == 0));  % Reduce blue

% Step 7: Compute grain size distribution
% Label the grains
[labeled, num_grains] = bwlabel(L);

% Compute properties of each grain (area in pixels)
props = regionprops(labeled, 'Area', 'PixelIdxList');

% Assuming the scale bar represents 50 µm for a certain number of pixels
% From the image, estimate the pixel-to-µm conversion
% Let's assume the scale bar of 50 µm is approximately 200 pixels (adjust based on your image)
pixels_per_um = 100 / 50; % pixels per µm
um_per_pixel = 1 / pixels_per_um; % µm per pixel

% Convert area from pixels to µm²
grain_areas_um2 = [props.Area] * (um_per_pixel^2);

% Convert area to equivalent diameter (assuming grains are roughly circular)
grain_diameters_um = 2 * sqrt(grain_areas_um2 / pi);

% Step 8: Display results
% Display the processed image with highlighted grain boundaries
figure;
subplot(1, 2, 1);
imshow(img_rgb);
title('Processed Image with Grain Boundaries Highlighted');

% Display grain size distribution as a histogram
subplot(1, 2, 2);
histogram(grain_diameters_um, 20);
title('Grain Size Distribution');
xlabel('Grain Diameter (µm)');
ylabel('Frequency');
grid on;

% Compute and display average grain size
avg_grain_size = mean(grain_diameters_um);
q1 = prctile(grain_diameters_um, 25);
q2 = prctile(grain_diameters_um, 50);
q3 = prctile(grain_diameters_um, 75);
p90 = prctile(grain_diameters_um, 90);
fprintf('Average Grain Size: %.2f µm\n', avg_grain_size);
fprintf('first quartile: %.2f µm\n', q1);
fprintf('Second Quartile: %.2f µm\n', q2);
fprintf('Third Quartile: %.2f µm\n', q3);
fprintf('Only ten percent of the grains are of size greater than: %.2f µm\n', p90);


% Step 9: Save the processed image
[~, name, ~] = fileparts(filename);
output_filename = sprintf('%s_processed.jpg', name);
imwrite(img_rgb, output_filename);
disp(['Processed image saved as: ', output_filename]);
