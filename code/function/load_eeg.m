function EEG = load_eeg(filepath)
%LOAD_EEG 脳波.setを読み込む
%
%   入力:
%       filepath - 読み込む .set ファイルのパス
%
%   出力:
%       EEG - EEGLABのEEG構造体
    arguments
        filepath {mustBeTextScalar}
    end
    
    EEG = pop_loadset(filepath);
end