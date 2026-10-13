%% Stage 2 - Edges and Region of interest
clear; close all; clc;

scriptDir = fileparts(which("stage2_edges_roi"));
projectRoot = fileparts(scriptDir);

videoFile = fullfile(projectRoot, "data", "solidWhiteRight.mp4");
resultsDir = fullfile(projectRoot, "results", "stage2");

assert(isfile(videoFile), "Video not found: %s", videoFile);

if ~isfolder(resultsDir)
    mkdir(resultsDir)
end

v = VideoReader(videoFile);
frame = readFrame(v);
grayFrame = rgb2gray(frame);
blurredFrame = imgaussfilt(grayFrame, 2);
[h, w] = size(grayFrame);

%% Gradient
