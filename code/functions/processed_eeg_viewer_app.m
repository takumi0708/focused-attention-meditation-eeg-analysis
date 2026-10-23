function processed_eeg_viewer_app()

    % =========================================================
    % L-FAME Processed EEG Viewer
    %
    % Subject / Session / Condition を選択
    %
    % eegplotで脳波を表示
    %
    % eegplot上で
    %   ・Channelを選択
    %   ・現在表示している4.096秒区間のPSDを見る
    %
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
        'Name', 'L-FAME Processed EEG Viewer', ...
        'Position', [500 300 400 320]);


    %% =========================================================
    % 共通レイアウト
    % ==========================================================

    x_label = 40;
    x_input = 150;

    w_label = 90;
    w_input = 210;

    h_element = 30;


    %% =========================================================
    % Subject
    % ==========================================================

    uilabel(fig, ...
        'Text', 'Subject', ...
        'Position', [x_label 250 w_label h_element]);

    subjectDropDown = uidropdown(fig, ...
        'Position', [x_input 250 w_input h_element], ...
        'ValueChangedFcn', @subjectChanged);


    %% =========================================================
    % Session
    % ==========================================================

    uilabel(fig, ...
        'Text', 'Session', ...
        'Position', [x_label 200 w_label h_element]);

    sessionDropDown = uidropdown(fig, ...
        'Position', [x_input 200 w_input h_element], ...
        'ValueChangedFcn', @sessionChanged);


    %% =========================================================
    % Condition
    % ==========================================================

    uilabel(fig, ...
        'Text', 'Condition', ...
        'Position', [x_label 150 w_input h_element]);

    conditionDropDown = uidropdown(fig, ...
        'Position', [x_input 150 w_input h_element]);


    %% =========================================================
    % 表示ボタン
    % ==========================================================

    uibutton(fig, ...
        'Text', '脳波を見る', ...
        'Position', [115 90 170 36], ...
        'ButtonPushedFcn', @viewEEG);


    %% =========================================================
    % Status
    % ==========================================================

    statusLabel = uilabel(fig, ...
        'Text', '', ...
        'Position', [40 35 320 25]);


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

            statusLabel.Text = ...
                "Subjectフォルダが見つかりません";

            return;

        end


        subjectDropDown.Items = cellstr(subjects);

        subjectDropDown.Value = subjects(1);


        loadSessions();

    end



    %% =========================================================
    % Session一覧
    % ==========================================================

    function loadSessions()

        subject = string(subjectDropDown.Value);


        subject_dir = fullfile( ...
            root_dir, ...
            subject);


        dirs = dir(subject_dir);

        dirs = dirs([dirs.isdir]);

        names = string({dirs.name});


        % pre / postだけ取得
        sessions = names( ...
            ismember(names, ["pre", "post"]));


        if isempty(sessions)

            sessionDropDown.Items = {''};
            conditionDropDown.Items = {''};

            statusLabel.Text = ...
                "Sessionが見つかりません";

            return;

        end


        sessionDropDown.Items = cellstr(sessions);

        sessionDropDown.Value = sessions(1);


        loadConditions();

    end



    %% =========================================================
    % Condition一覧
    % ==========================================================

    function loadConditions()

        subject = string(subjectDropDown.Value);

        session = string(sessionDropDown.Value);


        session_dir = fullfile( ...
            root_dir, ...
            subject, ...
            session);


        files = dir(fullfile( ...
            session_dir, ...
            "*_icrm.set"));


        if isempty(files)

            conditionDropDown.Items = {''};

            statusLabel.Text = ...
                "ICA処理済みEEGが見つかりません";

            return;

        end


        conditions = strings(0);


        for i = 1:length(files)

            filename = string(files(i).name);


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

            statusLabel.Text = ...
                "Conditionを取得できませんでした";

            return;

        end


        conditionDropDown.Items = ...
            cellstr(conditions);

        conditionDropDown.Value = ...
            conditions(1);


        statusLabel.Text = ...
            subject + " / " + ...
            session + " / " + ...
            conditions(1);

    end



    %% =========================================================
    % Subject変更
    % ==========================================================

    function subjectChanged(~, ~)

        loadSessions();

    end



    %% =========================================================
    % Session変更
    % ==========================================================

    function sessionChanged(~, ~)

        loadConditions();

    end



    %% =========================================================
    % EEG表示
    % ==========================================================

    function viewEEG(~, ~)

        subject = string(subjectDropDown.Value);

        session = string(sessionDropDown.Value);

        condition = string(conditionDropDown.Value);


        %% -------------------------
        % Sessionフォルダ
        % --------------------------

        eeg_dir = fullfile( ...
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


        %% -------------------------
        % ファイルがない
        % --------------------------

        if isempty(files)

            statusLabel.Text = ...
                "EEGファイルが見つかりません";

            uialert( ...
                fig, ...
                "該当する *_icrm.set がありません。", ...
                "データなし");

            return;

        end


        %% -------------------------
        % 複数ある
        % --------------------------

        if length(files) > 1

            statusLabel.Text = ...
                "複数のEEGファイルが見つかりました";

            uialert( ...
                fig, ...
                "該当する *_icrm.set が複数あります。", ...
                "エラー");

            return;

        end


        %% -------------------------
        % EEG読み込み
        % --------------------------

        statusLabel.Text = ...
            "Loading: " + ...
            subject + " / " + ...
            session + " / " + ...
            condition;

        drawnow;


        EEG = pop_loadset( ...
            'filename', files(1).name, ...
            'filepath', char(eeg_dir));


        %% =====================================================
        % eegplot
        %
        % winlength = 4.096秒
        % ======================================================

        eegplot_tag = ...
            "L_FAME_EEGPLOT_" + ...
            subject + "_" + ...
            session + "_" + ...
            condition;


        eegplot( ...
            EEG.data, ...
            'srate', EEG.srate, ...
            'eloc_file', EEG.chanlocs, ...
            'events', EEG.event, ...
            'dispchans', 20, ...
            'winlength', 4.096, ...
            'tag', char(eegplot_tag), ...
            'title', char( ...
                subject + ...
                " / " + ...
                session + ...
                " / " + ...
                condition + ...
                " [ICA removed]"));


        %% =====================================================
        % 作成されたeegplot Figureを取得
        % ======================================================

        eegFig = findobj( ...
            'Type', 'figure', ...
            'Tag', char(eegplot_tag));


        if isempty(eegFig)

            warning( ...
                "eegplot Figureを取得できませんでした");

            return;

        end


        %% =====================================================
        % Channel一覧
        % ======================================================

        channel_labels = ...
            string({EEG.chanlocs.labels});


        %% =====================================================
        % PSD用 Channel選択
        %
        % eegplot右上に追加
        % ======================================================

        uicontrol( ...
            eegFig, ...
            'Style', 'text', ...
            'Units', 'normalized', ...
            'Position', [0.81 0.91 0.07 0.035], ...
            'String', 'PSD Channel', ...
            'HorizontalAlignment', 'center');


        psdChannelMenu = uicontrol( ...
            eegFig, ...
            'Style', 'popupmenu', ...
            'Units', 'normalized', ...
            'Position', [0.88 0.91 0.07 0.04], ...
            'String', cellstr(channel_labels));


        %% -------------------------
        % Fzを初期値
        % --------------------------

        fz_idx = find( ...
            strcmpi(channel_labels, "Fz"), ...
            1);


        if ~isempty(fz_idx)

            psdChannelMenu.Value = fz_idx;

        end


        %% =====================================================
        % PSD表示ボタン
        % ======================================================

        uicontrol( ...
            eegFig, ...
            'Style', 'pushbutton', ...
            'Units', 'normalized', ...
            'Position', [0.88 0.86 0.07 0.045], ...
            'String', 'PSD', ...
            'FontWeight', 'bold', ...
            'Callback', @showCurrentPSD);


        %% =====================================================
        % PSD callback
        % ======================================================

        function showCurrentPSD(~, ~)

            %% -----------------------------------------------
            % eegplotの現在位置を取得
            %
            % g.time
            %   = 現在表示されている開始時刻
            %
            % g.winlength
            %   = 現在の表示時間
            % -----------------------------------------------

            g = get( ...
                eegFig, ...
                'UserData');


            start_sec = g.time;

            duration_sec = g.winlength;


            %% -----------------------------------------------
            % Channel
            % -----------------------------------------------

            channel_idx = ...
                psdChannelMenu.Value;


            selected_channel = ...
                channel_labels(channel_idx);


            %% -----------------------------------------------
            % sample番号
            % -----------------------------------------------

            fs = EEG.srate;


            start_sample = ...
                round(start_sec * fs) + 1;


            end_sample = ...
                start_sample + ...
                round(duration_sec * fs) - 1;


            %% -----------------------------------------------
            % 最後を超えた場合
            % -----------------------------------------------

            if end_sample > EEG.pnts

                end_sample = EEG.pnts;

            end


            if start_sample < 1

                start_sample = 1;

            end


            %% -----------------------------------------------
            % 現在表示中の区間を取得
            % -----------------------------------------------

            signal = double( ...
                EEG.data( ...
                    channel_idx, ...
                    start_sample:end_sample));


            %% -----------------------------------------------
            % Welch法
            % -----------------------------------------------

            window_sec = 2;


            window_length = ...
                round(window_sec * fs);


            % signalよりwindowが長くならないようにする
            window_length = min( ...
                window_length, ...
                length(signal));


            window = ...
                hamming(window_length);


            noverlap = ...
                round( ...
                    window_length * 0.5);


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


            %% -----------------------------------------------
            % 1 ～ 45 Hz
            % -----------------------------------------------

            idx = ...
                freq >= 1 & ...
                freq <= 45;


            freq_plot = ...
                freq(idx);


            % dB変換しない
            psd_plot = ...
                pxx(idx);


            %% =================================================
            % PSD Figure
            % ==================================================

            psdFig = figure( ...
                'Name', ...
                char( ...
                    selected_channel + ...
                    " PSD | " + ...
                    subject + ...
                    " / " + ...
                    session + ...
                    " / " + ...
                    condition), ...
                'NumberTitle', 'off');


            %% -----------------------------------------------
            % 画面中央
            % -----------------------------------------------

            psdFig.Position(3) = 900;

            psdFig.Position(4) = 550;

            movegui( ...
                psdFig, ...
                'center');


            %% -----------------------------------------------
            % PSD
            % -----------------------------------------------

            plot( ...
                freq_plot, ...
                psd_plot, ...
                'LineWidth', 1.5);


            xlabel( ...
                'Frequency [Hz]');


            ylabel( ...
                'PSD [\muV^2/Hz]');


            title( ...
                selected_channel + ...
                " PSD | " + ...
                num2str(start_sec, '%.3f') + ...
                " - " + ...
                num2str( ...
                    start_sec + duration_sec, ...
                    '%.3f') + ...
                " sec");


            xlim([1 45]);


            grid on;


            %% -----------------------------------------------
            % 周波数帯域の境界
            % -----------------------------------------------

            xline( ...
                4, ...
                '--', ...
                'δ / θ');


            xline( ...
                8, ...
                '--', ...
                'θ / α');


            xline( ...
                13, ...
                '--', ...
                'α / β');


            xline( ...
                30, ...
                '--', ...
                'β / γ');


        end


        %% =====================================================
        % Status
        % ======================================================

        statusLabel.Text = ...
            "Viewing: " + ...
            subject + " / " + ...
            session + " / " + ...
            condition;

    end

end