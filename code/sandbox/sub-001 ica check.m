% sub-001 の Post・slMeditaをicaして元のデータ
%と一致するか検証
clear;
clc;

%% フォルダ
data_dir = ...
    'C:\Users\zhang\OneDrive\ドキュメント\MATLAB\meditaion_anylysis\fucus-meditation-eeg\focused-attention-meditation-eeg-analysis\data\preprocessed\sub-001\ses-posmedita\eeg';

%% preica
% このファイルが下のicrmと似たようなデータになるかチェックする
EEG_pre = pop_loadset( ...
    'filename', 'sub-001_ses-posmedita_task-slMedita_eeg_preproc_preica.set', ...
    'filepath', data_dir);

%% icrm
EEG_icrm = pop_loadset( ...
    'filename', 'sub-001_ses-posmedita_task-slMedita_eeg_preproc_icrm.set', ...
    'filepath', data_dir);
%% サイズチェック
size(EEG_pre.data)
size(EEG_icrm.data)

%% ICA 
EEG_my = pop_runica(EEG_pre, ...
    'icatype', 'runica', ...
    'extended', 1);

%% 中身はあるかチェック
if isempty(EEG_my.data)
    error('ICA did not produce any components. Please check the input data.');
else
    disp('ICA completed successfully. Components are available.');
end
%% ICLabelで各独立成分を分類
EEG_my = pop_iclabel(EEG_my, 'default');

%% 分類結果を取り出す
prob = EEG_my.etc.ic_classification.ICLabel.classifications;

disp(prob)

%% Brain以外の代表的なartifactカテゴリ
% 列ごとにbrain muscleなどの確率は言ってる
% brain以外のicラベルの中での最大値を探してる　各行（ic）に対して
artifact_prob = max(prob(:,2:6), [], 2);

%% 0.9以上の成分
remove_IC = find(artifact_prob >= 0.9);

fprintf("除去対象IC数: %d\n", length(remove_IC));
disp(remove_IC)

%% アーチファクトICを除去
EEG_my_icrm = pop_subcomp(EEG_my, remove_IC, 0);

%% サイズ確認

fprintf("自作:   %d ch × %d samples\n", ...
    size(EEG_my_icrm.data,1), size(EEG_my_icrm.data,2));

fprintf("公開:   %d ch × %d samples\n", ...
    size(EEG_icrm.data,1), size(EEG_icrm.data,2));

%% 自作icrm と 公開icrm のチャネルごとの相関

nChan = EEG_icrm.nbchan;

r = zeros(nChan, 1);

for ch = 1:nChan

    % 自分でICA除去した脳波
    x = double(EEG_my_icrm.data(ch, :));

    % 公開されているicrm
    y = double(EEG_icrm.data(ch, :));

    % 相関係数
    R = corrcoef(x, y);
    
    % (1,2) or (2,1)
    r(ch) = R(1,2);

end

%% 結果
fprintf("平均相関 : %.4f\n", mean(r));
fprintf("最小相関 : %.4f\n", min(r));
fprintf("最大相関 : %.4f\n", max(r));

%% table
% チャネル番号と相関係数をテーブルにまとめる
result_table = table( ...
    (1:length(r))', ...   % チャネル番号：縦
    r, ...                % 相関係数：縦
    'VariableNames', {'Channel', 'Correlation'} ...
    );

disp(result_table);

%% 各チャネルのRMSE
rmse = zeros(EEG_icrm.nbchan, 1);

for ch = 1:EEG_icrm.nbchan

    x = double(EEG_my_icrm.data(ch,:));
    y = double(EEG_icrm.data(ch,:));

    rmse(ch) = sqrt(mean((x-y).^2));

end

result_table.RMSE = rmse;

disp(result_table)

%% 自分で作ったIC除去後データを .set で保存

out_dir = data_dir;   % 元データと同じフォルダに保存する場合

EEG_my_icrm = pop_saveset(EEG_my_icrm, ...
    'filename', 'sub-001_ses-posmedita_task-slMedita_eeg_preproc_icrm_my.set', ...
    'filepath', out_dir);

%% 保存した自作icrmを再読み込み
EEG_check = pop_loadset( ...
    'filename', 'sub-001_ses-posmedita_task-slMedita_eeg_preproc_icrm_my.set', ...
    'filepath', data_dir);

%% 基本情報確認
disp(EEG_check)

size(EEG_check.data)
EEG_check.nbchan
EEG_check.srate
EEG_check.pnts