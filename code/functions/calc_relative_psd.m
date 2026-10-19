function rel_psd = calc_relative_psd(abs_psd)
% calc_relative_psd
% 絶対PSDから相対PSDを計算する
%
% Input:
%   abs_psd : 絶対PSD
%
% Output:
%   rel_psd : 相対PSD

    % 全周波数帯域の総パワー
    total_power = sum(abs_psd);

    % 各周波数の割合を計算
    rel_psd = abs_psd / total_power;

end