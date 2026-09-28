%{
sub-001の分析

やること
- pre/post においてMF・MWの4条件の脳波を出す
- MF・MWの全エポックのPSD画像を保存
- MF・MWの平均PSD画像を出す
%}

clear;
clc;
close all;

%% 脳波読み込み pre/post × MF/MW の4条件

pre_data_dir = ...
    'C:\MATLAB\focused-attention-meditation-eeg-analysis\data\sub-001\pre';

post_data_dir = ...
    'C:\MATLAB\focused-attention-meditation-eeg-analysis\data\sub-001\post';

% pre MF/MW
pre_MF = pop_loadset( ...
    'filename', 'sub-001_ses-premedita_task-slMedita_eeg_preproc_icrm.set', ...
    'filepath', pre_data_dir);

pre_MW = pop_loadset( ...
    'filename', 'sub-001_ses-premedita_task-restCE01_eeg_preproc_icrm.set', ...
    'filepath', pre_data_dir);

% post MF/MW
post_MF = pop_loadset( ...
    'filename', 'sub-001_ses-posmedita_task-slMedita_eeg_preproc_icrm.set', ...
    'filepath', post_data_dir);

post_MW = pop_loadset( ...
    'filename', 'sub-001_ses-posmedita_task-restCE01_eeg_preproc_icrm.set', ...
    'filepath', post_data_dir);


%% 4条件の原波形を保存

fig_dir = ...
    "C:\MATLAB\focused-attention-meditation-eeg-analysis\code\被験者1分析\figure";

EEGs = {pre_MF, pre_MW, post_MF, post_MW};

sessions = {'Pre', 'Pre', 'Post', 'Post'};
conditions = {'MF', 'MW', 'MF', 'MW'};

sec = 10;


for i = 1:4

    EEG = EEGs{i};

    fs = EEG.srate;
    nSample = sec * fs;
    nChan = EEG.nbchan;

    save_dir = fullfile( ...
        fig_dir, ...
        "sub-001", ...
        sessions{i}, ...
        conditions{i}, ...
        "wave");

    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end


    % 20chずつ保存
    for chStart = 1:20:nChan

        chEnd = min(chStart + 19, nChan);

        data = double( ...
            EEG.data(chStart:chEnd, 1:nSample));

        t = (0:nSample-1) / fs;

        % 波形同士の間隔
        offset = 5 * median(std(data, 0, 2));

        % PowerPoint向けに大きなFigure
        fig = figure( ...
            'Position', [100 100 1400 850], ...
            'Color', 'w');

        hold on;


        % 各チャネルを黒で描画
        for ch = 1:size(data, 1)

            plot( ...
                t, ...
                data(ch,:) + (ch-1)*offset, ...
                'k', ...
                'LineWidth', 1);

        end


        % チャネル名
        yticks((0:size(data,1)-1) * offset);

        if ~isempty(EEG.chanlocs)

            labels = ...
                {EEG.chanlocs(chStart:chEnd).labels};

            yticklabels(labels);

        else

            labels = arrayfun( ...
                @num2str, ...
                chStart:chEnd, ...
                'UniformOutput', false);

            yticklabels(labels);

        end


        % PowerPoint向けに文字を大きくする
        xlabel( ...
            'Time (s)', ...
            'FontSize', 24, ...
            'FontWeight', 'bold');

        ylabel( ...
            'Channel', ...
            'FontSize', 24, ...
            'FontWeight', 'bold');

        title( ...
            sprintf( ...
                '%s %s  Ch%d-%d', ...
                sessions{i}, ...
                conditions{i}, ...
                chStart, ...
                chEnd), ...
            'FontSize', 28, ...
            'FontWeight', 'bold');


        % チャネル名・時間目盛りを大きくする
        ax = gca;
        ax.FontSize = 20;
        ax.LineWidth = 1.2;

        xlim([0 sec]);

        box off;

        hold off;


        %% 保存

        filename = sprintf( ...
            '%s_%s_Ch%02d-%02d.png', ...
            sessions{i}, ...
            conditions{i}, ...
            chStart, ...
            chEnd);

        exportgraphics( ...
            fig, ...
            fullfile(save_dir, filename), ...
            'Resolution', 300);

        close(fig);

    end

end