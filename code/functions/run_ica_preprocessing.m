%{
概要
ー.setファイルを読み込んで、ICA除去後の.setを出力する関数
ー閾値は選択できるようになってる（L-FAMEの論文は0.9以上で除去）

流れ
ーICA前の.setを読み込む
ーICA実施で64個のICAに分解
ーICAlabelを適用（学習済みの分類器により確率を算出）
ーic_threshold 以上の確率のICを除去
ー残ったICで64chに再構成

プログラムの挙動
ーファイルのディレクトリを受け取る
ーこれを分割して*.setのやつのみ取り出す
ーEEGを読み込む pop_loadset()
ーpop_runica()でICAを実行する
ーICAlabelでICの確率を算出
ーpop_icaflag()で閾値以上を除去する
ーbad_ic = find(EEG.reject.gcompreject)でbad channelを配列にまとめる
ーn_removedにbad_icに数を入れる
ーbad_idがあるなら、pop_subcomp()でノイズICを除去したICから元のチャンネル×時間波形のデータに逆変換（再構成）
ーその後ファイル名をpreica → icrm に置換して保存
%}
function n_removed = run_ica_preprocessing( ...
    input_file, ...
    output_dir, ...
    ic_threshold)

% RUN_ICA_PREPROCESSING
% 1つのpre-ICA EEGデータに対してICA前処理を実行する。
%
% この関数では以下の処理を行う。
%   1. EEGLAB形式の .set ファイルを読み込む
%   2. extended ICAを実行する
%   3. ICLabelで各独立成分を分類する
%   4. 指定した閾値に基づいてアーチファクトICを判定する
%   5. アーチファクトICを除去する
%   6. *_preproc_icrm.set として保存する
%
% Inputs
% -------
% input_file : char/string
%   入力する *_preproc_preica.set ファイルのパス。
%
% output_dir : char/string
%   ICA除去後の .set ファイルを保存するディレクトリ。
%
% ic_threshold : 7×2 double
%   ICLabelの各クラスに対する除去判定閾値。
%   行の順番は以下の通り。
%     1. Brain　脳活動
%     2. Muscle　筋電ノイズ（高周波）
%     3. Eye　眼球、瞬き
%     4. Heart　心電のEOGが影響
%     5. Line Noise　電源ノイズ
%     6. Channel Noise　電極などの接触不良ノイズ
%     7. Other　上記でも分類できない原因不明のノイズ群
%
% Outputs
% --------
% n_removed : double
%   除去した独立成分（IC）の数。
%
% Example
% -------
% n_removed = run_ica_preprocessing( ...
%     input_file, ...
%     output_dir, ...
%     ic_threshold);


%% =========================
% ファイル情報
%% =========================

[file_path, file_name, file_ext] = fileparts(input_file);

fprintf("Input:\n");
fprintf("%s\n", input_file);


%% =========================
% EEG読み込み
%% =========================

% char配列なので + ではなく [] で結合する
full_file_name = [file_name file_ext];

EEG = pop_loadset( ...
    'filename', full_file_name, ...
    'filepath', file_path);

EEG = eeg_checkset(EEG);


fprintf("\nEEG information\n");
fprintf("Channels : %d\n", EEG.nbchan);
fprintf("Samples  : %d\n", EEG.pnts);
fprintf("Srate    : %.1f Hz\n", EEG.srate);


%% =========================
% ICA
%% =========================

fprintf("\nRunning ICA...\n");

EEG = pop_runica( ...
    EEG, ...
    'icatype', 'runica', ...
    'extended', 1, ...
    'interrupt', 'on');

EEG = eeg_checkset(EEG);

fprintf("ICA completed\n");
fprintf("Number of ICs: %d\n", ...
    size(EEG.icaweights, 1));


%% =========================
% ICLabel
%% =========================

fprintf("\nRunning ICLabel...\n");

EEG = pop_iclabel( ...
    EEG, ...
    'default');

EEG = eeg_checkset(EEG);

fprintf("ICLabel completed\n");


%% =========================
% アーチファクトIC判定
%% =========================

fprintf("\nDetecting artifact ICs...\n");

% それぞれのICに対し、閾値以上ならtrue（除去）を各ICに関して行う
EEG = pop_icflag( ...
    EEG, ...
    ic_threshold);


%% 除去対象IC

bad_ic = find(EEG.reject.gcompreject);

n_removed = length(bad_ic);


fprintf("Artifact ICs:\n");

if isempty(bad_ic)

    fprintf("None\n");

else

    disp(bad_ic);

end

fprintf("Number of removed ICs: %d\n", n_removed);


%% =========================
% アーチファクトIC除去
%% =========================

if ~isempty(bad_ic)

    EEG = pop_subcomp( ...
        EEG, ...
        bad_ic, ...
        0);

    EEG = eeg_checkset(EEG);

end


%% =========================
% 出力ファイル名
%% =========================

% preica → icrm に置換
output_name = strrep( ...
    file_name, ...
    '_preproc_preica', ...
    '_preproc_icrm');

% 拡張子を追加
output_name = [output_name '.set'];


%% =========================
% 保存
%% =========================

fprintf("\nSaving EEG...\n");

% EEGLABとの互換性のためchar型に統一
output_name = char(output_name);
output_dir  = char(output_dir);

% データセット名も設定
[~, set_name, ~] = fileparts(output_name);
EEG.setname = set_name;

% 1つの .set ファイルとして保存
EEG = pop_saveset( ...
    EEG, ...
    'filename', output_name, ...
    'filepath', output_dir, ...
    'savemode', 'onefile');

fprintf("Saved:\n");
fprintf("%s\n", fullfile(output_dir, output_name));

end