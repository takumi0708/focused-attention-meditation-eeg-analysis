function save_psd_csv(psd, freq, EEG, filepath)
%SAVE_PSD_CSV PSDを frequency × channel のCSVとして保存する
%   -> epoch平均を取って、frequency × channel のCSVにしたい
%
%   入力:
%       psd      - channel × frequency × epoch
%       freq     - 周波数軸
%       EEG      - EEGLABのEEG構造体
%       filepath - 保存先
%
%   出力:
%       CSVファイル
    arguments (Input)
    
        psd double
        freq double
        EEG struct
        filepath {mustBeTextScalar}
    
    end
    
    % エポック平均 psdはch x f になってる
    mead_psd = mean(psd, 3);
    
    % 転置する
    mead_psd = mead_psd';

    % ch名
    channel_names = string({EEG.chanlocs.labels});

    % テーブル作成
    T = array2table(mead_psd, ...
        "VariableNames",channel_names);

    % 先頭列に周波数列を追加
    T = addvars(T, freq, ...
        'Before',1, ...
        'NewVariableNames', 'Frequency(Hz)');

    
    % filepath ディレクトリに CSV保存
    writetable(T, filepath);
end