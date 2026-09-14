function [freq,psd] = calc_psd(epochs, fs)
%CALC_PSD 各チャネル・各エポックのPSDをWelch法で計算する
%
%   入力:
%       epochs - channel × sample × epoch の3次元配列
%       fs     - サンプリング周波数 [Hz]
%
%   出力:
%       freq   - 周波数軸 [Hz]
%       psd    - channel × frequency × epoch のPSD
%{
-freq
->１ch,１エポックで周波数軸出す
-psd
-> ch x epoch_samples x epoch の３次元配列
%}
    arguments (Input)
        epochs double
        fs (1,1) double {mustBePositive}
    end

    % サイズ取得
    [n_channels, ~, n_epochs] = size(epochs);

    % 最初の1チャネル・1エポックで周波数軸を取得
    [pxx, freq] = pwelch( ...
        squeeze(epoch(1, :, 1)), ...
        [], ... % 窓関数
        [], ... % オーバーラップ
        [], ... % FFT点数
        fs);

    % 周波数の点
    n_freq = length(freq); 

    % 結果格納用 ch x freq になってる
    psd = zeros(n_channels, n_freq, n_epochs);
    
    % 各チャネル
    for e = 1:n_epochs

        for ch = 1:n_channels

            signal = squeeze(epochs(ch, :, e));

            pxx = pwelch( ...
                signal, ...
                [], ...
                [], ...
                [], ...
                fs);

            psd(ch, :, e) = pxx;

        end

    end

    
end