function processed_eeg_psd_viewer_app()

    % =========================================================
    % L-FAME EEG + PSD Viewer
    %
    % Subject / Session / Condition / Channel を選択し、
    % 指定した開始時間から4.096秒間について
    %
    %   上：原波形
    %   下：PSD
    %
    % を同時に表示する
    %
    % PSDはdB変換せず、
    % μV^2/Hz のまま表示する
    % =========================================================


    %% =========================================================
    % データのルートディレクトリ
    % ==========================================================

    root_dir = ...
        "C:\MATLAB\focused-attention-meditation-eeg-analysis\data\processed";


    %% =========================================================
    % アプリのウィンドウ
    % ==========================================================

    fig = uifigure( ...
        'Name', 'L-FAME EEG + PSD Viewer', ...
        'Position', [500 200 500 500]);


    %% =========================================================
    % 共通レイアウト
    % ==========================================================

    x_label = 40;
    x_input = 160;

    w_label = 100;
    w_input = 250;

    h = 30;


    %% =========================================================
    % Subject
    % ==========================================================

    uilabel(fig, ...
        'Text', 'Subject', ...
        'Position', [x_label 430 w_label h]);

    subjectDropDown = uidropdown(fig, ...
        'Position', [x_input 430 w_input h], ...
        'ValueChangedFcn', @subjectChanged);


    %% =========================================================
    % Session
    % ==========================================================

    uilabel(fig, ...
        'Text', 'Session', ...
        'Position', [x_label 380 w_label h]);

    sessionDropDown = uidropdown(fig, ...
        'Position', [x_input 380 w_input h], ...
        'ValueChangedFcn', @sessionChanged);


    %% =========================================================
    % Condition
    % ==========================================================

    uilabel(fig, ...
        'Text', 'Condition', ...
        'Position', [x_label 330 w_label h]);

    conditionDropDown = uidropdown(fig, ...
        'Position', [x_input 330 w_input h], ...
        'ValueChangedFcn', @conditionChanged);


    %% =========================================================
    % Channel
    % ==========================================================

    uilabel(fig, ...
        'Text', 'Channel', ...
        'Position', [x_label 280 w_label h]);

    channelDropDown = uidropdown(fig, ...
        'Position', [x_input 280 w_input h], ...
        'Items', {''});


    %% =========================================================
    % 開始時間
    % ==========================================================

    uilabel(fig, ...
        'Text', 'Start [sec]', ...
        'Position', [x_label 220 w_label h]);

    startField = uieditfield(fig, ...
        'numeric', ...
        'Position', [x_input 220 120 h], ...
        'Value', 0);


    %% =========================================================
    % 表示時間
    % ==========================================================

    uilabel(fig, ...
        'Text', '表示時間: 4.096 sec', ...
        'Position', [x_label 175 220 h]);


    %% =========================================================
    % 表示ボタン
    % ==========================================================

    uibutton(fig, ...
        'Text', '原波形 + PSDを見る', ...
        'Position', [140 115 220 42], ...
        'ButtonPushedFcn', @viewEEGandPSD);


    %% =========================================================
    % Status
    % ==========================================================

    statusLabel = uilabel(fig, ...
        'Text', '', ...
        'Position', [40 40 420 50]);


    %% =========================================================
    % 現在読み込んでいるEEG
    % ==========================================================

    currentEEG = [];


    %% =========================================================
    % 初期化
    % ==========================================================

    loadSubjects();



    %% =========================================================
    % Subject一覧
    % ==========================================================

    function loadSubjects()

        dirs = dir(fullfile(root_dir, "sub-*"));

        dirs = dirs([dirs.isdir]);

        subjects = string({dirs.name});


        if isempty(subjects)

            subjectDropDown.Items = {''};
            sessionDropDown.Items = {''};
            conditionDropDown.Items = {''};
            channelDropDown.Items = {''};

            statusLabel.Text = ...
                "Subjectフォルダが見つかりません";

            return;

        end


        subjectDropDown.Items = ...
            cellstr(subjects);

        subjectDropDown.Value = ...
            subjects(1);


        loadSessions();

    end



    %% =========================================================
    % Session一覧
    % ==========================================================

    function loadSessions()

        subject = ...
            string(subjectDropDown.Value);


        subject_dir = ...
            fullfile( ...
                root_dir, ...
                subject);


        dirs = dir(subject_dir);

        dirs = dirs([dirs.isdir]);

        names = string({dirs.name});


        sessions = names( ...
            ismember( ...
                names, ...
                ["pre", "post"]));


        if isempty(sessions)

            sessionDropDown.Items = {''};
            conditionDropDown.Items = {''};
            channelDropDown.Items = {''};

            statusLabel.Text = ...
                "Sessionが見つかりません";

            return;

        end


        sessionDropDown.Items = ...
            cellstr(sessions);

        sessionDropDown.Value = ...
            sessions(1);


        loadConditions();

    end



    %% =========================================================
    % Condition一覧
    % ==========================================================

    function loadConditions()

        subject = ...
            string(subjectDropDown.Value);

        session = ...
            string(sessionDropDown.Value);


        session_dir = ...
            fullfile( ...
                root_dir, ...
                subject, ...
                session);


        files = dir(fullfile( ...
            session_dir, ...
            "*_icrm.set"));


        if isempty(files)

            conditionDropDown.Items = {''};
            channelDropDown.Items = {''};

            statusLabel.Text = ...
                "ICA処理済みEEGが見つかりません";

            return;

        end


        conditions = strings(0);


        for i = 1:length(files)

            filename = ...
                string(files(i).name);


            token = regexp( ...
                filename, ...
                'task-([^_]+)', ...
                'tokens', ...
                'once');


            if ~isempty(token)

                conditions(end + 1) = ...
                    string(token{1});

            end

        end


        conditions = unique( ...
            conditions, ...
            'stable');


        if isempty(conditions)

            conditionDropDown.Items = {''};
            channelDropDown.Items = {''};

            statusLabel.Text = ...
                "Conditionを取得できませんでした";

            return;

        end


        conditionDropDown.Items = ...
            cellstr(conditions);

        conditionDropDown.Value = ...
            conditions(1);


        loadCurrentEEG();

    end



    %% =========================================================
    % EEGを読み込む
    % ==========================================================

    function loadCurrentEEG()

        subject = ...
            string(subjectDropDown.Value);

        session = ...
            string(sessionDropDown.Value);

        condition = ...
            string(conditionDropDown.Value);


        %% -------------------------
        % EEGフォルダ
        % --------------------------

        eeg_dir = ...
            fullfile( ...
                root_dir, ...
                subject, ...
                session);


        %% -------------------------
        % 対象ファイル
        % --------------------------

        file_pattern = ...
            "*_task-" + ...
            condition + ...
            "_eeg_preproc_icrm.set";


        files = dir(fullfile( ...
            eeg_dir, ...
            file_pattern));


        if isempty(files)

            currentEEG = [];

            channelDropDown.Items = {''};

            statusLabel.Text = ...
                "EEGファイルが見つかりません";

            return;

        end


        if length(files) > 1

            currentEEG = [];

            channelDropDown.Items = {''};

            statusLabel.Text = ...
                "複数のEEGファイルが見つかりました";

            return;

        end


        %% -------------------------
        % EEG読み込み
        % --------------------------

        statusLabel.Text = ...
            "Loading EEG...";

        drawnow;


        currentEEG = pop_loadset( ...
            'filename', ...
            files(1).name, ...
            'filepath', ...
            char(eeg_dir));


        %% -------------------------
        % Channel一覧
        % --------------------------

        channel_labels = ...
            string({currentEEG.chanlocs.labels});


        channelDropDown.Items = ...
            cellstr(channel_labels);


        % Fzがあれば初期値Fz
        if any(strcmpi(channel_labels, "Fz"))

            idx = strcmpi( ...
                channel_labels, ...
                "Fz");

            channelDropDown.Value = ...
                channel_labels(idx);

        else

            channelDropDown.Value = ...
                channel_labels(1);

        end


        %% -------------------------
        % データ全体の長さ
        % --------------------------

        total_sec = ...
            currentEEG.pnts / ...
            currentEEG.srate;


        statusLabel.Text = ...
            subject + " / " + ...
            session + " / " + ...
            condition + ...
            " | length: " + ...
            round(total_sec, 1) + ...
            " sec";

    end



    %% =========================================================
    % Subject変更
    % ==========================================================

    function subjectChanged(~, ~)

        currentEEG = [];

        loadSessions();

    end



    %% =========================================================
    % Session変更
    % ==========================================================

    function sessionChanged(~, ~)

        currentEEG = [];

        loadConditions();

    end



    %% =========================================================
    % Condition変更
    % ==========================================================

    function conditionChanged(~, ~)

        currentEEG = [];

        loadCurrentEEG();

    end



    %% =========================================================
    % 原波形 + PSD表示
    % ==========================================================

    function viewEEGandPSD(~, ~)

        %% -------------------------
        % EEG確認
        % --------------------------

        if isempty(currentEEG)

            uialert( ...
                fig, ...
                "EEGが読み込まれていません。", ...
                "エラー");

            return;

        end


        EEG = currentEEG;


        %% -------------------------
        % GUIの値
        % --------------------------

        subject = ...
            string(subjectDropDown.Value);

        session = ...
            string(sessionDropDown.Value);

        condition = ...
            string(conditionDropDown.Value);

        selected_channel = ...
            string(channelDropDown.Value);

        start_sec = ...
            startField.Value;


        %% -------------------------
        % 表示時間は4.096秒固定
        % --------------------------

        duration_sec = 4.096;


        %% -------------------------
        % Startチェック
        % --------------------------

        if start_sec < 0

            uialert( ...
                fig, ...
                "Startは0秒以上にしてください。", ...
                "入力エラー");

            return;

        end


        %% -------------------------
        % Channel番号
        % --------------------------

        channel_labels = ...
            string({EEG.chanlocs.labels});


        channel_idx = find( ...
            strcmpi( ...
                channel_labels, ...
                selected_channel), ...
            1);


        if isempty(channel_idx)

            uialert( ...
                fig, ...
                "Channelが見つかりません。", ...
                "エラー");

            return;

        end


        %% -------------------------
        % サンプリング周波数
        % --------------------------

        fs = EEG.srate;


        %% -------------------------
        % 秒 → サンプル
        % --------------------------

        start_sample = ...
            round(start_sec * fs) + 1;


        end_sample = ...
            start_sample + ...
            round(duration_sec * fs) - 1;


        %% -------------------------
        % 範囲チェック
        % --------------------------

        if start_sample > EEG.pnts

            uialert( ...
                fig, ...
                "開始時間がEEG範囲を超えています。", ...
                "範囲エラー");

            return;

        end


        if end_sample > EEG.pnts

            uialert( ...
                fig, ...
                "4.096秒区間がEEG範囲を超えています。", ...
                "範囲エラー");

            return;

        end


        %% -------------------------
        % 選択Channelの4.096秒区間
        % --------------------------

        signal = double( ...
            EEG.data( ...
                channel_idx, ...
                start_sample:end_sample));


        %% -------------------------
        % 時間軸
        % --------------------------

        time = ...
            (0:length(signal)-1) ...
            / fs ...
            + start_sec;


        %% =====================================================
        % Welch法でPSD
        % ======================================================

        % 2秒窓
        window_sec = 2;

        window_length = ...
            round(window_sec * fs);


        window = ...
            hamming(window_length);


        % 50% overlap
        noverlap = ...
            round( ...
                window_length * 0.5);


        % FFT点数
        nfft = max( ...
            512, ...
            2^nextpow2( ...
                window_length));


        [pxx, freq] = pwelch( ...
            signal, ...
            window, ...
            noverlap, ...
            nfft, ...
            fs);


        %% -------------------------
        % 1～45 Hz
        % --------------------------

        freq_idx = ...
            freq >= 1 & ...
            freq <= 45;


        freq_plot = ...
            freq(freq_idx);


        % dB変換しない
        psd_plot = ...
            pxx(freq_idx);


        %% =====================================================
        % Figure
        % ======================================================

        %% =====================================================
        % Figure
        % ======================================================

        resultFig = figure( ...
            'Name', ...
            char( ...
            subject + ...
            " / " + ...
            session + ...
            " / " + ...
            condition + ...
            " / " + ...
            selected_channel), ...
            'NumberTitle', 'off');

        % Figureサイズ
        resultFig.Position(3) = 1100;   % 幅
        resultFig.Position(4) = 750;    % 高さ

        % 画面中央に移動
        movegui(resultFig, 'center');


        %% =====================================================
        % 上：原波形
        % ======================================================

        subplot(2, 1, 1);


        plot( ...
            time, ...
            signal, ...
            'LineWidth', ...
            1);


        xlabel( ...
            'Time [s]');


        ylabel( ...
            'Amplitude [\muV]');


        title( ...
            selected_channel + ...
            " Raw EEG (" + ...
            start_sec + ...
            " - " + ...
            (start_sec + duration_sec) + ...
            " sec)");


        xlim( ...
            [ ...
            start_sec, ...
            start_sec + duration_sec ...
            ]);


        grid on;


        %% =====================================================
        % 下：PSD
        % ======================================================

        subplot(2, 1, 2);


        plot( ...
            freq_plot, ...
            psd_plot, ...
            'LineWidth', ...
            1.5);


        xlabel( ...
            'Frequency [Hz]');


        ylabel( ...
            'PSD [\muV^2/Hz]');


        title( ...
            selected_channel + ...
            " PSD");


        xlim([1 45]);


        grid on;


        %% =====================================================
        % Status
        % ======================================================

        statusLabel.Text = ...
            "Viewing: " + ...
            subject + " / " + ...
            session + " / " + ...
            condition + ...
            " / " + ...
            selected_channel + ...
            " / " + ...
            start_sec + ...
            "-" + ...
            (start_sec + duration_sec) + ...
            " sec";

    end

end