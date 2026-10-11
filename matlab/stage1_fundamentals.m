%% Stage 1 - Fundamentals
clear; close all; clc;

scriptDir   = fileparts(mfilename("fullpath"));
projectRoot = fileparts(scriptDir);

videoFile  = fullfile(projectRoot, "data", "solidWhiteRight.mp4");
resultsDir = fullfile(projectRoot, "results", "stage1");

if ~isfolder(resultsDir)
    mkdir(resultsDir);
end

%% Video properties
v = VideoReader(videoFile);
fprintf("Resolution: %d x %d | FPS: %.1f | Duration: %.1f s | Frames: %d\n", ...
    v.Width, v.Height, v.FrameRate, v.Duration, v.NumFrames);

%% Image as a matrix
firstFrame = read(v, 1);

figFrame = figure("Name", "First Frame");
imshow(firstFrame);
title("First Frame");

frameSize = size(firstFrame)
frameClass = class(firstFrame)

row = 450;
col = 280;

lanePixel = squeeze(firstFrame(row, col, :))'
asphaltPixel = squeeze(firstFrame(450, 480, :))'

exportgraphics(figFrame, fullfile(resultsDir, "first_frame.png"));

%% RGB -> HSV -> grayframe
hsvFrame = rgb2hsv(firstFrame);
grayFrame = rgb2gray(firstFrame);

figColor = figure("Name", "Color spaces");
tiledlayout(2, 3, "TileSpacing", "compact");
nexttile; imshow(firstFrame); title("RGB");
nexttile; imshow(hsvFrame(:, :, 1)); title("Hue");
nexttile; imshow(hsvFrame(:, :, 2)); title("Saturation");
nexttile; imshow(hsvFrame(:, :, 3)); title("Value");
nexttile; imshow(grayFrame); title("Grayscale");

graySize = size(grayFrame)
grayClass = class(grayFrame)

exportgraphics(figColor, fullfile(resultsDir, "color_space.png"));

%% Filtering
% Box filter
boxKernel = ones(3)/9
boxFiltered = conv2(double(grayFrame), boxKernel, "same");
boxFiltered = uint8(boxFiltered)

% Gaussian filter
gaussKernel = fspecial("gaussian", 15, 2);
figGaussian = figure("Name", "Gaussian Kernel");
surf(gaussKernel);
title("Gaussian Kernel, \sigma = 2");

% Compare filters on a zoomed region
crop = grayFrame(400:540, 150:450);
sigmas = [1 2 4];

figSmoothing = figure("Name", "Smoothing");
tiledlayout(1, 2 + numel(sigmas), "TileSpacing", "compact");
nexttile; imshow(crop); title("Original")
nexttile; imshow(boxFiltered(400:540, 150:450)); title("Box 3x3")

for s = sigmas
    nexttile;
    imshow(imgaussfilt(crop, s));
    title("Gaussian \sigma = " + s);
end

blurredFrame = imgaussfilt(grayFrame, 2);

exportgraphics(figGaussian, fullfile(resultsDir, "gaussian.png"));
exportgraphics(figSmoothing, fullfile(resultsDir, "smoothing.png"));

imwrite(blurredFrame, fullfile(resultsDir, "blurred_frame.png"));

%% Histogram
figHistogram = figure("Name", "Histogram");
tiledlayout(1, 2, "TileSpacing", "compact");
nexttile; imshow(grayFrame); title("Grayscale");
nexttile; [counts, bins] = imhist(grayFrame); bar(bins, counts, 1); xlim([0 255]); title("Histogram - whole frame");

% sky x road
[h, w] = size(grayFrame);
skyRegion = grayFrame(1:round(0.4*h), :);
roadRegion = grayFrame(round(0.6*h):end, :);

figSkyRoad = figure("Name", "Histogram - sky x road");
tiledlayout(2, 2, "TileSpacing", "compact");
nexttile; imshow(skyRegion); title("Top 40% - Sky");
nexttile; [counts, bins] = imhist(skyRegion); bar(bins, counts, 1); xlim([0 255]); title("Histogram - Sky");
nexttile; imshow(roadRegion); title("Bottom 60% - Road");
nexttile; [counts, bins] = imhist(roadRegion); bar(bins, counts, 1); xlim([0 255]); title("Histogram - Road");

% How many pixels are bright?
threshold = 200;
brightFraction = mean(roadRegion(:) > threshold)*100;
fprintf("Road pixels brighter than %d: %.2f%%\n", threshold, brightFraction);

brightMask = roadRegion > threshold;
figBrightness = figure("Name", "Bright Pixels");
imshow(brightMask);
title("Road pixels > " + threshold);

exportgraphics(figHistogram, fullfile(resultsDir, "whole_histogram.png"));
exportgraphics(figSkyRoad, fullfile(resultsDir, "brightness_sky_road.png"));
exportgraphics(figBrightness, fullfile(resultsDir, "brightness_threshold.png"));

imwrite(brightMask,   fullfile(resultsDir, "bright_mask.png"));
