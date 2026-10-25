function eeg_viewer_app()

% =========================================================
% L-FAME EEG Viewer
%
% Subject / Session / Condition をGUIで選択して
% EEG Viewerを起動する
% ==========================================================


%% =========================================================
% パス設定
% ==========================================================

root_dir = ...
    "C:\MATLAB\focused-attention-meditation-eeg-analysis\data\processed";

functions_dir = ...
    "C:\MATLAB\focused-attention-meditation-eeg-analysis\code\functions";

addpath(genpath(functions_dir));


%% =========================================================
% GUI作成
% ==========================================================

fig = uifigure( ...
    'Name', 'L-FAME EEG Viewer', ...
    'Position', [500 300 420 330]);


%% =========================================================
% Subject
% ==========================================================

uilabel(fig, ...
    'Text', 'Subject', ...
    'Position', [40 250 100 30]);


subjectDropDown = uidropdown(fig, ...
    'Position', [150 250 220 30], ...
    'ValueChangedFcn', @subjectChanged);


%% =========================================================
% Session
% ==========================================================

uilabel(fig, ...
    'Text', 'Session', ...
    'Position', [40 200 100 30]);


sessionDropDown = uidropdown(fig, ...
    'Position', [150 200 220 30], ...
    'ValueChangedFcn', @sessionChanged);


%% =========================================================
% Condition
% ==========================================================

uilabel(fig, ...
    'Text', 'Condition', ...
    'Position', [40 150 100 30]);


conditionDropDown = uidropdown(fig, ...
    'Position', [150 150 220 30]);


%% =========================================================
% 表示ボタン
% ==========================================================

uibutton(fig, ...
    'Text', 'EEGを表示', ...
    'Position', [125 85 170 40], ...
    'ButtonPushedFcn', @viewEEG);


%% =========================================================
% Status
% ==========================================================

statusLabel = uilabel(fig, ...
    'Text', '', ...
    'Position', [40 35 340 25]);


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
                "Subjectが見つかりません";

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
                "EEGファイルが見つかりません";

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


        %% EEGファイル検索

        eeg_dir = fullfile( ...
            root_dir, ...
            subject, ...
            session);


        file_pattern = ...
            "*_task-" + ...
            condition + ...
            "_eeg_preproc_icrm.set";


        files = dir(fullfile( ...
            eeg_dir, ...
            file_pattern));


        if isempty(files)

            uialert( ...
                fig, ...
                "EEGファイルが見つかりません", ...
                "データなし");

            return;

        end


        %% EEG読み込み

        EEG = pop_loadset( ...
            'filename', files(1).name, ...
            'filepath', char(eeg_dir));


        %% EEG Viewer起動

        open_eegplot( ...
            EEG, ...
            subject, ...
            session, ...
            condition);


        statusLabel.Text = ...
            "Viewing: " + ...
            subject + " / " + ...
            session + " / " + ...
            condition;

    end

end