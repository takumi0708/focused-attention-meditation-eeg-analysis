%% MWエポックをFFTしてCSV保存

fs = EEG_MW.srate;          % 250 Hz
N = size(MW_epoch, 2);      % 1000 sample
nChan = size(MW_epoch, 1);  % 65 ch
nEpoch = size(MW_epoch, 3); % 60 epoch

%% 周波数軸
f = (0:N/2) * (fs/N);

%% 保存先
output_dir = '../results/csv/sub-001/pre/MW';

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% エポックごとに処理
for ep = 1:nEpoch

    % 1列目 = 周波数
    % 2列目以降 = 各chのpower
    fft_results = zeros(length(f), 1 + nChan);
    fft_results(:, 1) = f';

    %% 65chを回す
    for ch = 1:nChan

        % ep番目のエポック、ch番目の信号
        raw_signal = double(MW_epoch(ch, :, ep));

        %% FFT
        Y = fft(raw_signal);

        P2 = abs(Y / N);

        P1 = P2(1:N/2 + 1);

        P1(2:end-1) = 2 * P1(2:end-1);

        % power spectrum
        power_spec = P1 .^ 2;

        %% 2列目以降に格納
        fft_results(:, ch + 1) = power_spec';

    end

    %% ヘッダー作成
    col_names = cell(1, 1 + nChan);

    col_names{1} = 'Frequency_Hz';

    for ch = 1:nChan
        col_names{ch + 1} = sprintf('Ch_%d', ch);
    end

    %% table化
    result_table = array2table( ...
        fft_results, ...
        'VariableNames', col_names);

    %% ファイル名
    filename = sprintf('epoch_%03d.csv', ep);

    %% CSV保存
    writetable( ...
        result_table, ...
        fullfile(output_dir, filename));

end

disp("MWのFFT結果を保存しました");