function fig = plot_psd(filepath)
%PLOT_PSD PSDのCSVを読み込み、折れ線グラフで表示する
%
%   入力:
%       filepath - frequency × channel のPSD CSV
%                - 平均PSDでも・そうでなくてもOK
%
%   出力:
%       fig - Figureオブジェクト

    arguments
        filepath {mustBeTextScalar}
    end

    
    % CSV読み込み
    T = readtable(filepath);

    % 各チャネルを折れ線で表示
    plot(freq, psd);
end