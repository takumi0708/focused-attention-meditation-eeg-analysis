
% sub-001～003 のEEGデータについて
% サンプリング周波数、チャネル数、データ長、
% Fz/Ozの存在を確認する

clear;
clc;

%% ========================================
% 設定
% =========================================

% このスクリプトはプロジェクトルートから実行する想定
data_dir = fullfile(pwd, "data", "preprocessed");

subjects = ["sub-001", "sub-002", "sub-003"];
periods  = ["pre", "post"];
tasks    = ["restCE01", "slMedita"];


%% ========================================
% 全ファイルを確認
% =========================================

for s = 1:length(subjects)

    subject = subjects(s);

    fprintf("\n==============================\n");
    fprintf("%s\n", subject);
    fprintf("==============================\n");

    for p = 1:length(periods)

        period = periods(p);

        for t = 1:length(tasks)

            task = tasks(t);

            %% ファイルを探す

            folder = fullfile( ...
                data_dir, ...
                subject, ...
                period);

            pattern = sprintf( ...
                "*task-%s*icrm.set", ...
                task);

            files = dir(fullfile(folder, pattern));

            if isempty(files)
                fprintf("ERROR: ファイルなし\n");
                continue;
            end

            %% EEGLABで読み込む

            EEG = pop_loadset( ...
                'filename', files(1).name, ...
                'filepath', char(folder));
            %% チャネル名

            channel_labels = string({EEG.chanlocs.labels});

            has_Fz = any(strcmpi(channel_labels, "Fz"));
            has_Oz = any(strcmpi(channel_labels, "Oz"));

            %% データ時間

            duration_sec = EEG.pnts / EEG.srate;

            %% 結果表示

            fprintf("\n%s / %s / %s\n", ...
                subject, period, task);

            fprintf("  Sampling rate : %.1f Hz\n", EEG.srate);
            fprintf("  Channels      : %d\n", EEG.nbchan);
            fprintf("  Samples       : %d\n", EEG.pnts);
            fprintf("  Duration      : %.1f sec\n", duration_sec);
            fprintf("  Fz            : %d\n", has_Fz);
            fprintf("  Oz            : %d\n", has_Oz);

        end
    end
end