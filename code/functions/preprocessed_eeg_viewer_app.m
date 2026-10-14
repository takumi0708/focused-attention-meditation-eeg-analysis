%{
アプリの動き
概要：被験者・セッション・条件の順番に読み込んでいく
------------------------------------------------
ー実行でウィンドウが表示
ーラベル・入力部分が描画される
ーloadSubjects()が実行される
　ー被験者のディレクトリ全部を取得
　ーloadSessions()で被験者のsessionを取得
ーloadSessions()が実行される
　ー被験者の値を取得
　ーセッションまでのディレクトリを得る
　ーセッション内のフォルダ一覧を得る
　ーフォルダ一覧の中でpre postが含まれるものだけ抽出
　ーloadConditions()を実行
ーloadConditions()
　ー被験者の値・セッションの値を取得
　ーディレクトリを得る
　ーコンディション一覧を得る
　ー被験者・セッション・条件（コンディション）をつなげる
　ーstatuslabelをテキストで表示
ーsubjectChanged(~, ~)
　ー被験者を変える
　ーloadSessions()
ーsessionChanged(~, ~)
　ーセッションを変える
　ーloadSessions()
ーviewEEG(~, ~)
　ー被験者・セッション・条件をつなげて、pop_loadsetで脳波を表示
%}

function preprocessed_eeg_viewer_app()

    % =========================================================
    % L-FAME Preprocessed EEG Viewer
    %
    % Subject / Session / Condition をGUIで選択し、
    % *_preica.set をEEGLABでスクロール表示する
    % =========================================================


    %% =========================================================
    % データのルートディレクトリ
    % ==========================================================

    root_dir = ...
        "C:\MATLAB\focused-attention-meditation-eeg-analysis\data\preprocessed";


    %% =========================================================
    % アプリのウィンドウ
    % ==========================================================

    fig = uifigure( ...
        'Name', 'L-FAME Preprocessed EEG Viewer', ...
        'Position', [500 300 400 320]);


    %% =========================================================
    % 共通レイアウト
    % ==========================================================

    x_label = 40; % ラベルの左画面からの位置
    x_input = 150; % 入力部分の左画面からの位置

    w_label = 90; % ラベルの横幅
    w_input = 210; % 入力部分の横幅

    h_element = 30; % 各パーツの高さ


    %% =========================================================
    % Subject
    % ==========================================================

    uilabel(fig, ...
        'Text', 'Subject', ...
        'Position', [x_label 250 w_label h_element]);
    
    % @subjectChanged 選択が変わった時、subjectChangedの関数が走る
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

        % root_dir 内の sub-* フォルダを取得
        dirs = dir(fullfile(root_dir, "sub-*"));

        % フォルダだけ残す
        dirs = dirs([dirs.isdir]);

        % 名前を取り出す
        subjects = string({dirs.name});


        % 見つからなかった場合
        if isempty(subjects)

            subjectDropDown.Items = {''};
            sessionDropDown.Items = {''};
            conditionDropDown.Items = {''};

            statusLabel.Text = ...
                "Subjectフォルダが見つかりません";

            return;

        end


        % Subject一覧を設定
        subjectDropDown.Items = cellstr(subjects);

        % 最初の被験者を選択
        subjectDropDown.Value = subjects(1);


        % 最初の被験者のSessionを取得
        loadSessions();

    end



    %% =========================================================
    % Session一覧を読み込む
    % ==========================================================

    function loadSessions()

        % 現在選択されているSubject
        subject = string(subjectDropDown.Value);


        % Subjectディレクトリ
        subject_dir = fullfile( ...
            root_dir, ...
            subject);


        % 中にあるフォルダを取得
        dirs = dir(subject_dir);

        dirs = dirs([dirs.isdir]);

        names = string({dirs.name});


        % pre / post だけ取得
        % ディレクトリのnames内にpre postが含まれるものだけ抽出
        sessions = names( ...
            ismember(names, ["pre", "post"]));


        % Sessionがない場合
        if isempty(sessions)

            sessionDropDown.Items = {''};
            conditionDropDown.Items = {''};

            statusLabel.Text = ...
                "Sessionが見つかりません";

            return;

        end


        % Session一覧を設定
        sessionDropDown.Items = cellstr(sessions);

        % 最初のSessionを選択
        sessionDropDown.Value = sessions(1);


        % Conditionを更新
        loadConditions();

    end



    %% =========================================================
    % Condition一覧を読み込む
    % ==========================================================

    function loadConditions()

        subject = string(subjectDropDown.Value);
        session = string(sessionDropDown.Value);


        % Sessionディレクトリ
        session_dir = fullfile( ...
            root_dir, ...
            subject, ...
            session);


        % Session内のフォルダ一覧
        dirs = dir(session_dir);

        dirs = dirs([dirs.isdir]);

        names = string({dirs.name});


        % L-FAMEで使う条件
        validConditions = [ ...
            "Medita", ...
            "restCE01", ...
            "restCE02", ...
            "slMedita"];


        % 実際に存在する条件だけ残す
        conditions = names( ...
            ismember(names, validConditions));


        % 条件がなければ終了
        if isempty(conditions)

            conditionDropDown.Items = {''};

            statusLabel.Text = ...
                "Conditionが見つかりません";

            return;

        end


        % Condition一覧を設定
        conditionDropDown.Items = cellstr(conditions);

        % 最初のConditionを選択
        conditionDropDown.Value = conditions(1);


        % Status表示
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
        % Sessionも再取得する
        loadSessions();

    end



    %% =========================================================
    % Session変更時
    % ==========================================================

    function sessionChanged(~, ~)

        % Sessionが変わったら
        % Conditionを再取得する
        loadConditions();

    end



    %% =========================================================
    % EEG表示
    % ==========================================================

    function viewEEG(~, ~)

        % 現在の選択値
        subject = string(subjectDropDown.Value);
        session = string(sessionDropDown.Value);
        condition = string(conditionDropDown.Value);


        % Conditionフォルダ
        eeg_dir = fullfile( ...
            root_dir, ...
            subject, ...
            session, ...
            condition);


        %% -------------------------
        % *_preica.set を探す
        % --------------------------

        files = dir(fullfile( ...
            eeg_dir, ...
            "*_preica.set"));


        %% -------------------------
        % ファイルがない場合
        % --------------------------

        if isempty(files)

            statusLabel.Text = ...
                "EEGファイルが見つかりません";

            uialert( ...
                fig, ...
                "該当する *_preica.set がありません。", ...
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
                "該当する *_preica.set が複数あります。", ...
                "エラー");

            return;

        end


        %% -------------------------
        % 読み込み中表示
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
        % EEGスクロール表示
        % --------------------------

        eegplot( ...
            EEG.data, ...
            'srate', EEG.srate, ...
            'eloc_file', EEG.chanlocs, ...
            'events', EEG.event, ...
            'dispchans', 20, ...
            'title', char(subject + " / " + session + " / " + condition));


        %% -------------------------
        % 完了表示
        % --------------------------

        statusLabel.Text = ...
            "Viewing: " + ...
            subject + " / " + ...
            session + " / " + ...
            condition;

    end

end