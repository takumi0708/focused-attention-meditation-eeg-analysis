function plot_multichannel_wave(epoches, EEG, ep, ch_range, condition, save_dir)
%PLOT_MULTICHANNEL_WAVE
% 指定エポックの複数チャネル原波形を縦に並べて保存する
%
%   epoches   - channel × samples × epochs
%   EEG       - EEGLABのEEG構造体
%   ep        - エポック番号
%   ch_range  - 表示するチャネル番号
%   condition - 条件名
%   save_dir  - 保存先

    arguments
        epoches
        EEG struct
        ep (1,1) double {mustBePositive, mustBeInteger}
        ch_range double
        condition string
        save_dir string
    end

    fs = EEG.srate;

    % 指定エポック・チャネルを取得
    data = double(epoches(ch_range, :, ep));

    % 時間軸
    n_samples = size(data, 2);
    time = (0:n_samples-1) / fs;

    % チャネル名
    ch_names = string({EEG.chanlocs(ch_range).labels});

    % 波形同士を離す間隔
    offset = max(std(data, 0, 2)) * 5;

    % Figure
    fig = figure("Visible", "off");
    fig.Position = [100 100 1400 850];

    hold on;

    for i = 1:length(ch_range)

        y_offset = (length(ch_range) - i) * offset;

        plot( ...
            time, ...
            data(i,:) + y_offset, ...
            "k", ...
            "LineWidth", 1.2);

    end

    % チャネル名
    % Y軸にチャネル名
    yticks((0:length(ch_range)-1) * offset);
    yticklabels(flip(ch_names));

    % PowerPoint用に大きくする
    xlabel("Time (s)", ...
        "FontSize", 24, ...
        "FontWeight", "bold");

    ylabel("Channel", ...
        "FontSize", 24, ...
        "FontWeight", "bold");

    title(condition + "  Ch" + ...
        ch_range(1) + "-" + ch_range(end), ...
        "FontSize", 28, ...
        "FontWeight", "bold");

    % 目盛り・チャネル名
    ax = gca;
    ax.FontSize = 20;
    ax.LineWidth = 1.2;

    xlim([0 time(end)]);

    box off;

    % 保存先
    output_dir = fullfile(save_dir, condition);

    if ~exist(output_dir, "dir")
        mkdir(output_dir);
    end

    filename = condition + ...
        "_Ch" + ch_range(1) + "-" + ch_range(end) + ...
        "_ep" + ep + ".png";

    exportgraphics( ...
        fig, ...
        fullfile(output_dir, filename), ...
        "Resolution", 300);

    close(fig);

end