function result = calc_mean_band_psd(excel_path, band_name)
% calc_mean_band_psd
%
% PSD Excelの指定した帯域シートを読み込み、
% 4条件それぞれの平均PSDを計算する。
%
% 入力
%   excel_path : PSD Excelファイル
%   band_name  : 'alpha', 'theta', 'delta', 'beta'
%
% 出力
%   result : 1行のtable


%% 指定した帯域のシートを読み込む

T = readtable( ...
    excel_path, ...
    'Sheet', band_name);


%% 各条件の平均PSD

pre_MF  = mean(T.pre_MF);
post_MF = mean(T.post_MF);
pre_MW  = mean(T.pre_MW);
post_MW = mean(T.post_MW);


%% Tableにする

result = table( ...
    pre_MF, ...
    post_MF, ...
    pre_MW, ...
    post_MW, ...
    'VariableNames', { ...
        'pre_MF', ...
        'post_MF', ...
        'pre_MW', ...
        'post_MW' ...
    });

end