%% sub-001 post : MF / MW を4秒エポック化してFFT → CSV保存

clear;
clc;

eeglab;

%% =========================
% データパス
% ==========================
data_path = '../data/preprocessed/sub-001/ses-posmedita/eeg/';

%% =========================
% MW = restCE01
% ==========================
EEG_MW = pop_loadset( ...
    'filename', 'sub-001_ses-posmedita_task-restCE01_eeg_preproc_icrm.set', ...
    'filepath', data_path);

%% =========================
% MF = slMedita
% ==========================
EEG_MF = pop_loadset( ...
    'filename', 'sub-001_ses-posmedita_task-slMedita_eeg_preproc_icrm.set', ...
    'filepath', data_path);

%% =========================
% 4秒エポック化
% ==========================
epoch_sec = 4;

% MW
samples_per_epoch_MW = EEG_MW.srate * epoch_sec;
nEpoch_MW = floor(EEG_MW.pnts / samples_per_epoch_MW);

MW_data = EEG_MW.data(:, 1:nEpoch_MW * samples_per_epoch_MW);

MW_epoch = reshape( ...
    MW_data, ...
    EEG_MW.nbchan, ...
    samples_per_epoch_MW, ...
    nEpoch_MW);

% MF
samples_per_epoch_MF = EEG_MF.srate * epoch_sec;
nEpoch_MF = floor(EEG_MF.pnts / samples_per_epoch_MF);

MF_data = EEG_MF.data(:, 1:nEpoch_MF * samples_per_epoch_MF);

MF_epoch = reshape( ...
    MF_data, ...
    EEG_MF.nbchan, ...
    samples_per_epoch_MF, ...
    nEpoch_MF);

%% 確認
fprintf('MW epochs : %d\n', nEpoch_MW);
fprintf('MF epochs : %d\n', nEpoch_MF);

disp(size(MW_epoch));
disp(size(MF_epoch));


%% =========================
% MF : FFT → CSV
% ==========================
fs = EEG_MF.srate;
N = size(MF_epoch, 2);
nChan = size(MF_epoch, 1);
nEpoch = size(MF_epoch, 3);

f = (0:N/2) * (fs/N);

output_dir = '../results/csv/sub-001/post/MF';

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

for ep = 1:nEpoch

    fft_results = zeros(length(f), 1 + nChan);
    fft_results(:, 1) = f';

    for ch = 1:nChan

        raw_signal = double(MF_epoch(ch, :, ep));

        Y = fft(raw_signal);

        P2 = abs(Y / N);
        P1 = P2(1:N/2 + 1);
        P1(2:end-1) = 2 * P1(2:end-1);

        power_spec = P1 .^ 2;

        fft_results(:, ch + 1) = power_spec';

    end

    % ヘッダー
    col_names = cell(1, 1 + nChan);
    col_names{1} = 'Frequency_Hz';

    for ch = 1:nChan
        col_names{ch + 1} = sprintf('Ch_%d', ch);
    end

    result_table = array2table( ...
        fft_results, ...
        'VariableNames', col_names);

    filename = sprintf('epoch_%03d.csv', ep);

    writetable( ...
        result_table, ...
        fullfile(output_dir, filename));

end

disp("Post MF 保存完了");


%% =========================
% MW : FFT → CSV
% ==========================
fs = EEG_MW.srate;
N = size(MW_epoch, 2);
nChan = size(MW_epoch, 1);
nEpoch = size(MW_epoch, 3);

f = (0:N/2) * (fs/N);

output_dir = '../results/csv/sub-001/post/MW';

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

for ep = 1:nEpoch

    fft_results = zeros(length(f), 1 + nChan);
    fft_results(:, 1) = f';

    for ch = 1:nChan

        raw_signal = double(MW_epoch(ch, :, ep));

        Y = fft(raw_signal);

        P2 = abs(Y / N);
        P1 = P2(1:N/2 + 1);
        P1(2:end-1) = 2 * P1(2:end-1);

        power_spec = P1 .^ 2;

        fft_results(:, ch + 1) = power_spec';

    end

    % ヘッダー
    col_names = cell(1, 1 + nChan);
    col_names{1} = 'Frequency_Hz';

    for ch = 1:nChan
        col_names{ch + 1} = sprintf('Ch_%d', ch);
    end

    result_table = array2table( ...
        fft_results, ...
        'VariableNames', col_names);

    filename = sprintf('epoch_%03d.csv', ep);

    writetable( ...
        result_table, ...
        fullfile(output_dir, filename));

end

disp("Post MW 保存完了");