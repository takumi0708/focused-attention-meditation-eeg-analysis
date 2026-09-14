function [relative_psd] = calc_relative_psd(psd, freq, freq_range)
% CALC_RELATIVE_PSD 指定周波数範囲を基準に相対PSDを計算する
%
%   入力:
%       psd        - channel × frequency × epoch のPSD
%       freq       - 周波数軸 [Hz]
%       freq_range - 基準とする周波数範囲 [下限 上限]
%   出力:
%       relative_psd - channel × frequency × epoch の相対PSD

%{
指定範囲の周波数の配列取得
指定範囲の総パワー計算（相対出すために全体を足す）
角周波数のPSDを総パワーで割る
%}
    arguments
        psd double
        freq double
        freq_range (1,2) double
    end

    % 指定範囲の周波数の取得(範囲外は０になる)
    idx = freq >= freq_range(1) && freq <= freq_range(2);

    % 総パワーの計算
    total_power = sum(psd(:, idx, :), 2);

    % 相対パワーの配列
    % ./は要素ごとの割り算
    relative_psd = psd ./ total_power;

    
end
