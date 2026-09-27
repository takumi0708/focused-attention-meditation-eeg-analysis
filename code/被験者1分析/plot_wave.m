function plot_wave(epoches, EEG, ch_name, save_dir)
%PLOT_WAVE 指定チャネルの各エポックの原波形を保存する
% 20260927 作成
% 
%   入力:
%       epoches  - channel × samples × epochs
%       EEG      - EEGLABのEEG構造体
%       ch_name  - チャネル名（例："Fz"）
%       save_dir - 保存先の親フォルダ

    arguments
        epoches
        EEG struct
        ch_name string
        save_dir string
    end

    % チャネル名を探す
    channel_names = string({EEG.chanlocs.labels});

    ch_idx = find(channel_names == ch_name);

    if isempty(ch_idx)
        error("チャネル %s が見つかりません。", ch_name);
    end

    
    % 保存フォルダを作る
    % 例：figure/Fz_wave
    ch_dir = fullfile(save_dir, ch_name + "_wave");

    if ~exist(ch_dir, "dir")
        mkdir(ch_dir);
    end
    
    % 原波形なので時間軸を作成
    n_samples = size(epoches, 2);

    time = (0:n_samples-1) / EEG.srate;

    
    % 全エポックを保存
    n_epochs = size(epoches, 3);

    for ep = 1:n_epochs

        % 指定チャネル・指定エポックを取得
        wave = squeeze(epoches(ch_idx, :, ep));

        % Figure作成
        fig = figure("Visible", "off");

        plot(time, wave, "LineWidth", 1.5);

        xlabel("Time [s]", "FontSize", 18);
        ylabel("Amplitude [\muV]", "FontSize", 18);

        % タイトル
        title(ch_name + " - Epoch " + ep, ...
            "FontSize", 22, ...
            "FontWeight", "bold");

        % 目盛りの文字サイズ
        ax = gca;
        ax.FontSize = 16;

        grid on;

        % Figure自体も少し大きくする
        fig.Position = [100 100 1000 500];


        % jpg 保存

        filename = ch_name + "_wave_ep" + ep + ".jpg";

        filepath = fullfile(ch_dir, filename);

        exportgraphics(fig, filepath, "Resolution", 150);

        close(fig);

    end

end