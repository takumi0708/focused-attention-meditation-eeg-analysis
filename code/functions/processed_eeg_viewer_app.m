%{
実行例
ーsubject session(pre/post) condition(4条件)を選択
ーprocessed/sub-001/pre/からsub-001_ses-premedita_task-slMedita_eeg_preproc_icrm.setを読み込む

アプリの動き
ーprocessedフォルダを見る
ーsubject一覧を得る
ー選択したsubjectのpre/postを得る
ーそのsession直下の*_icrm.set を探す
ー対象の脳波を読み込む

sessyion 直下の4ファイルをどう選択する？
ーfile_pattern = ...
    "*_task-" + condition + "_eeg_preproc_icrm.set";
ーtask- の後ろのcondiotionで分岐できる
%}

function processed_eeg_viewer_app()

    % =========================================================
    % L-FAME Processed EEG Viewer
    %
    % Subject / Session / Condition をGUIで選択し、
    % ICA除去後の *_icrm.set をEEGLABで表示する
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
        'Position', [x_label 150 w_label h_element]);

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
    % Subject一覧を読み込む
    % ==========================================================

    function loadSubjects()

        % processed 内の sub-* フォルダを取得
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
    % Session一覧を読み込む
    % ==========================================================

    function loadSessions()

        subject = string(subjectDropDown.Value);


        subject_dir = fullfile( ...
            root_dir, ...
            subject);


        dirs = dir(subject_dir);

        dirs = dirs([dirs.isdir]);

        names = string({dirs.name});


        % pre / post だけ取得
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
    % Condition一覧を読み込む
    % ==========================================================

    function loadConditions()

        subject = string(subjectDropDown.Value);
        session = string(sessionDropDown.Value);


        session_dir = fullfile( ...
            root_dir, ...
            subject, ...
            session);


        % Session直下の *_icrm.set を取得
        files = dir(fullfile( ...
            session_dir, ...
            "*_icrm.set"));


        if isempty(files)

            conditionDropDown.Items = {''};

            statusLabel.Text = ...
                "ICA処理済みEEGが見つかりません";

            return;

        end


        % 条件名を格納
        conditions = strings(0);


        for i = 1:length(files)

            filename = string(files(i).name);

            % ファイル名の
            % task-XXXX
            % のXXXX部分だけ取り出す
            token = regexp( ...
                filename, ...
                'task-([^_]+)', ...
                'tokens', ...
                'once');


            if ~isempty(token)

                conditions(end + 1) = string(token{1});

            end

        end


        % 重複を削除
        conditions = unique(conditions, 'stable');


        if isempty(conditions)

            conditionDropDown.Items = {''};

            statusLabel.Text = ...
                "Conditionを取得できませんでした";

            return;

        end


        conditionDropDown.Items = cellstr(conditions);

        conditionDropDown.Value = conditions(1);


        statusLabel.Text = ...
            subject + " / " + ...
            session + " / " + ...
            conditions(1);

    end



    %% =========================================================
    % Subject変更時
    % ==========================================================

    function subjectChanged(~, ~)

        % Subjectが変わったら
        % Sessionを更新
        loadSessions();

    end



    %% =========================================================
    % Session変更時
    % ==========================================================

    function sessionChanged(~, ~)

        % Sessionが変わったら
        % Conditionを更新
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
        % 対象の *_icrm.set を検索
        % --------------------------

        file_pattern = ...
            "*_task-" + condition + "_eeg_preproc_icrm.set";


        files = dir(fullfile( ...
            eeg_dir, ...
            file_pattern));


        %% -------------------------
        % 見つからない場合
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
        % 複数見つかった場合
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
        % 読み込み中
        % --------------------------

        statusLabel.Text = ...
            "Loading: " + ...
            subject + " / " + ...
            session + " / " + ...
            condition;

        drawnow;


        %% -------------------------
        % EEGLABで読み込み
        % --------------------------

        EEG = pop_loadset( ...
            'filename', files(1).name, ...
            'filepath', char(eeg_dir));


        %% -------------------------
        % EEG表示
        %
        % データ自体は64chのまま
        % 画面上は20chずつ表示
        % --------------------------

        eegplot( ...
            EEG.data, ...
            'srate', EEG.srate, ...
            'eloc_file', EEG.chanlocs, ...
            'events', EEG.event, ...
            'dispchans', 20, ...
            'title', char( ...
                subject + ...
                " / " + ...
                session + ...
                " / " + ...
                condition + ...
                " [ICA removed]"));


        %% -------------------------
        % Status更新
        % --------------------------

        statusLabel.Text = ...
            "Viewing: " + ...
            subject + " / " + ...
            session + " / " + ...
            condition;

    end

end