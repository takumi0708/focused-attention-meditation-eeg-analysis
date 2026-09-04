%{
作成９．４日
やること
ーsub-001の分析
ーpre/post においてMF・MWの４枚の脳波を出す
ーMF・MWの全エポックのfft画像を保存
ーMF・MWの群平均で平均fft画像を出す
%}

%% 脳波読み込み pre post MF MW の４条件
post_data_dir = ...
    'C:\Users\zhang\OneDrive\Desktop\EEG_analysis\focused-attention-meditation-eeg-analysis\data\derivatives\eeglab_preproc\sub-001\ses-posmedita\eeg';
pre_data_dir = ...
    'C:\Users\zhang\OneDrive\Desktop\EEG_analysis\focused-attention-meditation-eeg-analysis\data\derivatives\eeglab_preproc\sub-001\ses-premedita\eeg';

% pre MF/MW
pre_MF = pop_loadset( ...
    'filename', 'sub-001_ses-premedita_task-slMedita_eeg_preproc_icrm.set', ...
    'filepath', pre_data_dir);

pre_MW = pop_loadset( ...
    'filename', 'sub-001_ses-premedita_task-restCE01_eeg_preproc_icrm.set', ...
    'filepath', pre_data_dir);

% post Mf/MW
post_MF = pop_loadset( ...
    'filename', 'sub-001_ses-posmedita_task-slMedita_eeg_preproc_icrm.set', ...
    'filepath', post_data_dir);

post_MW = pop_loadset( ...
    'filename', 'sub-001_ses-posmedita_task-restCE01_eeg_preproc_icrm.set', ...
    'filepath', post_data_dir);

%% 4条件の原波形を確認

% EEGLABで脳波の表示
% ４つの条件の脳波保存
% 各条件20chずつ保存（１条件４枚の画像）

fig_dir = ...
    "C:\Users\zhang\OneDrive\Desktop\EEG_analysis\focused-attention-meditation-eeg-analysis\code\被験者1分析\figure";

% 4条件
EEGs = {pre_MF, pre_MW, post_MF, post_MW};

sessions = {'pre', 'pre', 'post', 'post'};
conditions = {'MF', 'MW', 'MF', 'MW'};

sec = 10; % 表示時間


for i = 1:4
    %今の脳波
    EEG = EEGs{i};

    fs = EEG.srate;
    nSample = sec * fs;
    nChan = EEG.nbchan;

    %　保存フォルダ dir
    save_dir = fullfile( ...
        fig_dir, ...
        "sub-001", ...
        sessions{i}, ...
        conditions{i});

    % なければ作成
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end
    
    % 20chずつ原波形を保存

    
    for chStart = 1:20:nChan

        % 今回表示する最後のチャネル
        chEnd = min(chStart + 19, nChan);

        % 対象データ
        data = double(EEG.data(chStart:chEnd, 1:nSample));

        % 時間軸
        % MATLABは1 から始まるから
        t = (0:nSample-1) / fs;

        % 波形同士が重ならないように間隔を設定
        offset = 5 * median(std(data, 0, 2));

        figure;
        hold on;

        % 20chを同じFigureに描画
        for ch = 1:size(data, 1)

            plot(t, data(ch,:) + (ch-1)*offset, "k");

        end

        % y軸にチャネル名を表示
        yticks((0:size(data,1)-1) * offset);

        if ~isempty(EEG.chanlocs)

            labels = {EEG.chanlocs(chStart:chEnd).labels};
            yticklabels(labels);

        else

            labels = arrayfun( ...
                @num2str, ...
                chStart:chEnd, ...
                'UniformOutput', false);

            yticklabels(labels);

        end

        xlabel('Time (s)');
        ylabel('Channel');

        title(sprintf( ...
            '%s %s Ch%d-%d', ...
            sessions{i}, ...
            conditions{i}, ...
            chStart, ...
            chEnd));

        xlim([0 nSample/fs]);

        hold off;

        %% 保存
        filename = sprintf( ...
            '%s_%s_Ch%02d-%02d.png', ...
            sessions{i}, ...
            conditions{i}, ...
            chStart, ...
            chEnd);

        exportgraphics( ...
            gcf, ...
            fullfile(save_dir, filename), ...
            'Resolution', 300);

        close(gcf);

    end

end