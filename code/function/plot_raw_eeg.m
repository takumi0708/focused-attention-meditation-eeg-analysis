function fig = plot_raw_eeg(EEG, start_sec, duration_sec, channels)

%
%   入力:
%       EEG          - EEGLABのEEG構造体
%       start_sec    - 表示開始時間 [秒]
%       duration_sec - 表示時間 [秒]
%       channels     - 表示するチャネル番号
%
%   出力:
%       fig          - Figureオブジェクト

    arguments (Input)
        EEG struct
        start_sec (1,1) double {mustBeNonnegative}
        duration_sec (1,1) double {mustBePositive}
        channels double
    end

    plot(time, data');
end