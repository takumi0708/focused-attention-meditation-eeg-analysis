%% 全被験者
% pre/post × MF/MW
% 4秒エポック化 → FFT → CSV保存

clear;
clc;

eeglab;

%% =========================
% 基本設定
% ==========================
input_root  = fullfile('data', 'preprocessed');
output_root = fullfile('results', 'csv');

sessions = {'ses-premedita', 'ses-posmedita'};
states   = {'MF', 'MW'};

epoch_sec = 4;

%% =========================
% 被験者フォルダを自動取得
% ==========================
subject_dirs = dir(fullfile(input_root, 'sub-*'));

% フォルダだけ残す
subject_dirs = subject_dirs([subject_dirs.isdir]);

fprintf('Subjects found : %d\n', length(subject_dirs));

%% =========================
% 被験者ループ
% ==========================
for sub_idx = 1:length(subject_dirs)

    subject = subject_dirs(sub_idx).name;

    fprintf('\n');
    fprintf('========================================\n');
    fprintf('Subject : %s\n', subject);
    fprintf('========================================\n');

    %% =========================
    % Pre / Post
    % ==========================
    for s = 1:length(sessions)

        session = sessions{s};

        % 保存用の短い名前
        if strcmp(session, 'ses-premedita')
            session_short = 'pre';
        else
            session_short = 'post';
        end

        %% =========================
        % MF / MW
        % ==========================
        for st = 1:length(states)

            state = states{st};

            %% State → L-FAME task
            if strcmp(state, 'MF')
                task_name = 'slMedita';

            elseif strcmp(state, 'MW')
                task_name = 'restCE01';
            end

            %% -------------------------
            % 入力フォルダ
            % --------------------------
            data_path = fullfile( ...
                input_root, ...
                subject, ...
                session, ...
                'eeg');

            %% -------------------------
            % ファイル名
            % --------------------------
            filename = sprintf( ...
                '%s_%s_task-%s_eeg_preproc_icrm.set', ...
                subject, ...
                session, ...
                task_name);

            full_input_file = fullfile(data_path, filename);

            %% =========================
            % ファイルが存在するか確認
            % ==========================
            if ~exist(full_input_file, 'file')

                fprintf( ...
                    'SKIP : %s / %s / %s がありません\n', ...
                    subject, ...
                    session_short, ...
                    state);

                continue;
            end

            fprintf('\n%s / %s / %s\n', ...
                subject, session_short, state);

            fprintf('Loading : %s\n', filename);

            %% =========================
            % EEGLAB読み込み
            % ==========================
            EEG = pop_loadset( ...
                'filename', filename, ...
                'filepath', data_path);

            %% =========================
            % 基本情報
            % ==========================
            fs     = EEG.srate;
            nChan  = EEG.nbchan;

            fprintf('Channels      : %d\n', nChan);
            fprintf('Sampling rate : %.1f Hz\n', fs);
            fprintf('Duration      : %.2f sec\n', ...
                EEG.pnts / fs);

            %% =========================
            % 4秒エポック化
            % ==========================
            samples_per_epoch = round(fs * epoch_sec);

            nEpoch = floor( ...
                EEG.pnts / samples_per_epoch);

            % 完全な4秒区間だけ使用
            data_use = EEG.data( ...
                :, ...
                1:nEpoch * samples_per_epoch);

            % channel × sample × epoch
            epoch_data = reshape( ...
                data_use, ...
                nChan, ...
                samples_per_epoch, ...
                nEpoch);

            fprintf('Epochs        : %d\n', nEpoch);

            %% =========================
            % FFT設定
            % ==========================
            N = samples_per_epoch;

            f = (0:N/2) * (fs/N);

            %% =========================
            % 保存先
            % ==========================
            output_dir = fullfile( ...
                output_root, ...
                subject, ...
                session_short, ...
                state);

            if ~exist(output_dir, 'dir')
                mkdir(output_dir);
            end

            %% =========================
            % CSVヘッダー
            % ==========================
            col_names = cell(1, nChan + 1);

            col_names{1} = 'Frequency_Hz';

            for ch = 1:nChan

                label = EEG.chanlocs(ch).labels;

                if ~isempty(label)
                    col_names{ch + 1} = label;
                else
                    col_names{ch + 1} = ...
                        sprintf('Ch_%d', ch);
                end
            end

            %% =========================
            % 各エポック
            % ==========================
            for ep = 1:nEpoch

                % 1列目=frequency
                % 残り=各channel
                fft_results = zeros( ...
                    length(f), ...
                    nChan + 1);

                fft_results(:,1) = f';

                %% 各channel
                for ch = 1:nChan

                    raw_signal = double( ...
                        epoch_data(ch,:,ep));

                    %% FFT
                    Y = fft(raw_signal);

                    P2 = abs(Y / N);

                    P1 = P2(1:N/2 + 1);

                    P1(2:end-1) = ...
                        2 * P1(2:end-1);

                    power_spec = P1 .^ 2;

                    %% 格納
                    fft_results(:, ch + 1) = ...
                        power_spec';
                end

                %% table化
                result_table = array2table( ...
                    fft_results, ...
                    'VariableNames', col_names);

                %% CSV名
                csv_name = sprintf( ...
                    'epoch_%03d.csv', ep);

                %% 保存
                writetable( ...
                    result_table, ...
                    fullfile(output_dir, csv_name));
            end

            fprintf( ...
                'Saved : %d CSV files\n', ...
                nEpoch);

        end
    end
end

fprintf('\n');
disp('========================================');
disp('All subjects finished');
disp('========================================');