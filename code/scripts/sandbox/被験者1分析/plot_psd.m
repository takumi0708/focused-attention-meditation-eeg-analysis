function plot_psd(epoches, EEG, ch_name, condition, save_dir)
%PLOT_PSD 指定チャネルの各エポックのPSDを計算・保存する
%
%   入力:
%       epoches  - channel × samples × epochs
%       EEG      - EEGLABのEEG構造体
%       ch_name  - チャネル名（例："Fz"）
%       condition  - Pre MWなどの状態
%       save_dir - 保存先の親フォルダ

    arguments
        epoches
        EEG struct
        ch_name string
        condition string
        save_dir string
    end

    % チャネル番号を取得
    channel_names = string({EEG.chanlocs.labels});
    ch_idx = find(channel_names == ch_name);

    if isempty(ch_idx)
        error("チャネル %s が見つかりません。", ch_name);
    end

    % 保存フォルダ
    ch_dir = fullfile(save_dir, ch_name + "_psd");

    if ~exist(ch_dir, "dir")
        mkdir(ch_dir);
    end

    fs = EEG.srate;
    n_epochs = size(epoches, 3);

    for ep = 1:n_epochs

        % 指定チャネルの波形
        wave = double(squeeze(epoches(ch_idx, :, ep)));

        % Welch法
        [psd, freq] = pwelch(wave, [], [], [], fs);

        % 1～45 Hz
        idx = freq >= 1 & freq <= 45;
        freq_plot = freq(idx);
        psd_plot = psd(idx);

        % Figure
        fig = figure("Visible", "off");

        plot(freq_plot, psd_plot, ...
            "LineWidth", 1.5);

        xlabel("Frequency [Hz]", ...
            "FontSize", 18);

        ylabel("PSD [\muV^2/Hz]", ...
            "FontSize", 18);

        title(condition + " - " + ch_name + " PSD - Epoch " + ep, ...
        "FontSize", 22, ...
        "FontWeight", "bold");

        ax = gca;
        ax.FontSize = 16;

        xlim([1 45]);
        grid on;

        fig.Position = [100 100 1000 500];

        % 保存
        filename = ch_name + "_psd_ep" + ep + ".jpg";
        filepath = fullfile(ch_dir, filename);

        exportgraphics(fig, filepath, ...
            "Resolution", 150);

        close(fig);

    end

end