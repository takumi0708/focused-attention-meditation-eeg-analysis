%% L-FAME eeglab_preproc
% Pre/Post両方参加した44人について
% preica の .set ファイル数を確認する

clear;
clc;


%% 1. Pre/Post両方参加した被験者を読み込む
T = readtable("../participants_both_done.tsv", ...
    "FileType", "text", ...
    "Delimiter", "\t");

subjects = string(T.participant_id);

% sub-01 → sub-001 に変換
num = extractAfter(subjects, "sub-");
subjects = "sub-" + compose("%03d", str2double(num));

fprintf("対象被験者: %d 人\n", length(subjects));


%% 2. 結果を入れるテーブルを準備
result = table();

result.participant = subjects;
result.pre_preica_set  = zeros(length(subjects), 1);
result.post_preica_set = zeros(length(subjects), 1);


%% 3. 被験者を1人ずつ確認
for i = 1:length(subjects)

    % 今確認している被験者
    % 例：sub-040
    sub = subjects(i);


    %% その被験者だけのHugging Face API
    url = ...
        "https://huggingface.co/api/datasets/" + ...
        "L-FAME-Dataset-Benchmark/L-FAME/tree/main/" + ...
        "derivatives/eeglab_preproc/" + sub + ...
        "?recursive=true&limit=1000";

    % sub-040 のファイル一覧だけ取得
    data_sub = webread(url);


    %% 4. APIからpathを取り出す
    % data_sub はcellなので1個ずつ取り出す

    n = length(data_sub);

    paths = strings(n, 1);

    for j = 1:n

        item = data_sub{j};

        paths(j) = string(item.path);

    end


    %% 5. Pre の preica.set を探す
    %
    % 条件
    % ① ses-premedita
    % ② preica
    % ③ .set で終わる

    pre_idx = ...
        contains(paths, "ses-premedita") & ...
        contains(paths, "preica") & ...
        endsWith(paths, ".set");


    %% 6. Post の preica.set を探す

    post_idx = ...
        contains(paths, "ses-posmedita") & ...
        contains(paths, "preica") & ...
        endsWith(paths, ".set");


    %% 7. true の数を数えて保存

    result.pre_preica_set(i) = sum(pre_idx);

    result.post_preica_set(i) = sum(post_idx);


    %% 進捗表示
    fprintf("%s  Pre:%d  Post:%d\n", ...
        sub, ...
        result.pre_preica_set(i), ...
        result.post_preica_set(i));

end


%% 8. 最終結果
disp(result)