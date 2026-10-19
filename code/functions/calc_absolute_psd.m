function [freq, abs_psd] = calc_absolute_psd(signal, fs)
% calc_absolute_psd
% Welch法を使って絶対PSDを計算する
%
% Inputs:
%   signal : 1チャネル分のEEGデータ
%   fs     : サンプリング周波数 [Hz]
%
% Outputs:
%   freq    : 周波数 [Hz]
%   abs_psd : 絶対PSD [uV^2/Hz]

    % Welch法によるPSD計算
    [abs_psd, freq] = pwelch(signal, [], [], [], fs);

    % 解析対象を1～45 Hzに限定
    idx = freq >= 1 & freq <= 45;

    freq = freq(idx);
    abs_psd = abs_psd(idx);

end