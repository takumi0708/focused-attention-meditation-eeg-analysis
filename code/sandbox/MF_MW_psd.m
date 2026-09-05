%% sub-001 pre : MF / MW を4秒エポックに分割

clear;
clc;

%% EEGLAB起動
eeglab;

%% データの場所
data_path = 'data/preprocessed/sub-001/ses-premedita/eeg/';

%% =========================
% MW = restCE01
% ==========================
EEG_MW = pop_loadset( ...
    'filename', 'sub-001_ses-premedita_task-restCE01_eeg_preproc_icrm.set', ...
    'filepath', data_path);

%% =========================
% MF = slMedita
% ==========================
EEG_MF = pop_loadset( ...
    'filename', 'sub-001_ses-premedita_task-slMedita_eeg_preproc_icrm.set', ...
    'filepath', data_path);

%% 基本情報
disp('--- MW ---'); % 240s
disp(size(EEG_MW.data)); % ch x points
disp(EEG_MW.srate); % sampling rate

disp('--- MF ---'); % 約480s
disp(size(EEG_MF.data));
disp(EEG_MF.srate);

%% =========================
% 4秒エポック
% ==========================

epoch_sec = 4;

% 1エポックあたりの、サンプル数（250Hz x 4s=1000 points）
samples_per_epoch_MW = EEG_MW.srate * epoch_sec;
samples_per_epoch_MF = EEG_MF.srate * epoch_sec;

%% 完全な4秒区間だけ使用
% floor -> 整数値にする
% points / 1 エポックあたりのサンプル数 = エポック数
nEpoch_MW = floor(EEG_MW.pnts / samples_per_epoch_MW);
nEpoch_MF = floor(EEG_MF.pnts / samples_per_epoch_MF);

%% 必要な長さだけ切り出す
% EEGLABは行：チャンネル　列：時間サンプル
MW_data = EEG_MW.data(:, 1:nEpoch_MW*samples_per_epoch_MW);
MF_data = EEG_MF.data(:, 1:nEpoch_MF*samples_per_epoch_MF);

%% 3次元化
% channel × sample × epoch

MW_epoch = reshape( ...
    MW_data, ... %対象データ
    EEG_MW.nbchan, ... %１次元
    samples_per_epoch_MW, ... %　２次元
    nEpoch_MW); % ３次元

MF_epoch = reshape( ...
    MF_data, ...
    EEG_MF.nbchan, ...
    samples_per_epoch_MF, ...
    nEpoch_MF);

%% 確認
disp('--- Epoch result ---');

fprintf('MW epochs : %d\n', nEpoch_MW);
fprintf('MF epochs : %d\n', nEpoch_MF);

disp('MW size');
disp(size(MW_epoch));

disp('MF size');
disp(size(MF_epoch));