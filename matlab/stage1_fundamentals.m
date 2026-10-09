%% Stage 1 - Fundamentals

videoFile = fullfile("..", "data", "solidWhiteRight.mp4");

v = VideoReader(videoFile);
fprintf("Resolution: %d x %d | FPS: %.1f | Duration: %.1f s | Frames: %d\n", ...
    v.Width, v.Height, v.FrameRate, v.Duration, v.NumFrames);