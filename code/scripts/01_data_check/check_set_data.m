%% =========================================
% sub-001 / sub-031 の preica データ形式を比較確認
% ==========================================
%
% 目的:
%   sub-001 : .set + .fdt
%   sub-031 : .set のみ
%
% をEEGLABで読み込み、
% EEG.data が数値配列として取得できるか確認する。
%
% 確認項目:
%   - チャネル数
%   - サンプル数
%   - サンプリング周波数
%   - EEG.data の型
%   - EEG.data のサイズ
%   - 実データが数値として入っているか
%

clear;
clc;


%% =========================================
% Hugging Face キャッシュの基準パス
% ==========================================

BASE_DIR = ...
    "C:\Users\zhang\.cache\huggingface\hub\" + ...
    "datasets--L-FAME-Dataset-Benchmark--L-FAME\" + ...
    "snapshots\53f4a329eed86a0053b2150cc4e754406662b5a3\" + ...
    "derivatives\eeglab_preproc";


%% =========================================
% 確認対象
% ==========================================

subjects = [
    "sub-001"
    "sub-031"
];

session = "ses-premedita";
task    = "restCE01";


%% =========================================
% 被験者ごとに読み込む
% ==========================================

for i = 1:length(subjects)

    subject = subjects(i);

    fprintf("\n");
    fprintf("========================================\n");
    fprintf("Subject: %s\n", subject);
    fprintf("========================================\n");


    %% -------------------------------------
    % EEGフォルダ
    % --------------------------------------

    eeg_dir = fullfile( ...
        BASE_DIR, ...
        subject, ...
        session, ...
        "eeg" ...
    );

    fprintf("EEG directory:\n%s\n\n", eeg_dir);


    %% -------------------------------------
    % .set ファイル名
    % --------------------------------------

    set_filename = ...
        subject + "_" + ...
        session + "_" + ...
        "task-" + task + "_" + ...
        "eeg_preproc_preica.set";

    set_path = fullfile( ...
        eeg_dir, ...
        set_filename ...
    );


    %% -------------------------------------
    % .fdt ファイル名
    % --------------------------------------

    fdt_filename = ...
        subject + "_" + ...
        session + "_" + ...
        "task-" + task + "_" + ...
        "eeg_preproc_preica.fdt";

    fdt_path = fullfile( ...
        eeg_dir, ...
        fdt_filename ...
    );


    %% -------------------------------------
    % ファイル存在確認
    % --------------------------------------

    set_exists = isfile(set_path);
    fdt_exists = isfile(fdt_path);

    fprintf(".set exists : %d\n", set_exists);
    fprintf(".fdt exists : %d\n", fdt_exists);


    % .set がなければ読み込めない
    if ~set_exists
        fprintf("ERROR: .set file not found.\n");
        continue;
    end


    %% -------------------------------------
    % EEGLABで読み込み
    % --------------------------------------

    try

        EEG = pop_loadset( ...
            'filename', char(set_filename), ...
            'filepath', char(eeg_dir) ...
        );

        fprintf("\nLoad successful.\n");


    catch ME

        fprintf("\nLoad failed.\n");
        fprintf("Error message:\n%s\n", ME.message);

        continue;

    end


    %% -------------------------------------
    % EEG基本情報
    % --------------------------------------

    fprintf("\n--- EEG information ---\n");

    fprintf( ...
        "Channels : %d\n", ...
        EEG.nbchan ...
    );

    fprintf( ...
        "Samples  : %d\n", ...
        EEG.pnts ...
    );

    fprintf( ...
        "Srate    : %.2f Hz\n", ...
        EEG.srate ...
    );


    %% -------------------------------------
    % EEG.data の確認
    % --------------------------------------

    fprintf("\n--- EEG.data ---\n");

    fprintf( ...
        "Class : %s\n", ...
        class(EEG.data) ...
    );

    fprintf("Size  : ");

    disp(size(EEG.data));


    %% -------------------------------------
    % 数値データか確認
    % --------------------------------------

    if isnumeric(EEG.data)

        fprintf( ...
            "EEG.data contains numeric EEG data.\n" ...
        );

    elseif ischar(EEG.data) || isstring(EEG.data)

        fprintf( ...
            "EEG.data points to an external file:\n" ...
        );

        disp(EEG.data);

    else

        fprintf( ...
            "Unknown EEG.data format.\n" ...
        );

    end


    %% -------------------------------------
    % 値が実際に入っているか確認
    % --------------------------------------

    if isnumeric(EEG.data)

        fprintf("\nFirst 5 samples of channel 1:\n");

        disp( ...
            EEG.data(1, 1:min(5, EEG.pnts)) ...
        );

    end


    %% -------------------------------------
    % 結果の簡単な判定
    % --------------------------------------

    fprintf("\n--- Result ---\n");

    if fdt_exists

        fprintf( ...
            "%s has .set + .fdt.\n", ...
            subject ...
        );

    else

        if isnumeric(EEG.data)

            fprintf( ...
                "%s has no .fdt, but EEG data loaded successfully.\n", ...
                subject ...
            );

            fprintf( ...
                "This suggests the EEG data are stored inside the .set file.\n" ...
            );

        else

            fprintf( ...
                "%s has no .fdt and EEG data were not loaded numerically.\n", ...
                subject ...
            );

        end

    end

end