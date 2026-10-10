%% Stage 1 - Fundamentals

%% Video properties

videoFile = fullfile("data", "solidWhiteRight.mp4");

v = VideoReader(videoFile);
fprintf("Resolution: %d x %d | FPS: %.1f | Duration: %.1f s | Frames: %d\n", ...
    v.Width, v.Height, v.FrameRate, v.Duration, v.NumFrames);

%% Image as a matrix

firstFrame = read(v, 1);
imshow(firstFrame);
title("First Frame");

frameSize = size(firstFrame)
frameClass = class(firstFrame)

row = 450;
col = 280;

lanePixel = squeeze(firstFrame(row, col, :))'
asphaltPixel = squeeze(firstFrame(450, 480, :))'

%% RGB -> HSV -> grayframe

hsvFrame = rgb2hsv(firstFrame);
grayFrame = rgb2gray(firstFrame);

figure("Name", "Color Spaces");
tiledlayout(2, 3, "TileSpacing", "compact");
nexttile; imshow(firstFrame); title("RGB");
nexttile; imshow(hsvFrame(:, :, 1)); title("Hue");
nexttile; imshow(hsvFrame(:, :, 2)); title("Saturation");
nexttile; imshow(hsvFrame(:, :, 3)); title("Value");
nexttile; imshow(grayFrame); title("Grayscale");

graySize = size(grayFrame)
grayClass = class(grayFrame)

%% Filtering

% Box filter
boxKernel = ones(3)/9
boxFiltered = conv2(double(grayFrame), boxKernel, "same");
boxFiltered = uint8(boxFiltered)

% Gaussian filter
gaussKernel = fspecial("gaussian", 15, 2);
figure("Name", "Gaussian Kernel");
surf(gaussKernel);
title("Gaussian Kernel, \sigma = 2");

% Compare filters on a zoomed region
crop = grayFrame(400:500, 150 :450);
sigmas = [1 2 4];

figure("Name", "Smoothing");
tiledlayout(1, 2 + numel(sigmas), "TileSpacing", "compact");
nexttile; imshow(crop); title("Original")
nexttile; imshow(boxFiltered(400:450, 150:450)); title("Box 3x3")

for s = sigmas
    nexttile;
    imshow(imgaussfilt(crop, s));
    title("Gaussian \sigma = " + s);
end

blurredFrame = imgaussfilt(grayFrame, 2);