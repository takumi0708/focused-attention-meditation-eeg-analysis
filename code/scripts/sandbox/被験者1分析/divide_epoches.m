function epochs = divide_epoches(EEG, epoch_sec)
%DIVIDE_EPOCHES 連続EEGを指定秒数ごとに分割する
%
%   入力:
%       EEG       - EEGLABのEEG構造体
%       epoch_sec - エポック長 [秒]
%
%   出力:
%       epochs    - channel × samples × epochs

    arguments
        EEG struct
        epoch_sec (1,1) double {mustBePositive}
    end

    data = EEG.data;
    fs = EEG.srate;

    % 1エポックのサンプル数
    samples_per_epoch = round(epoch_sec * fs);

    % 作成できるエポック数
    n_epochs = floor(size(data, 2) / samples_per_epoch);

    % 余った部分を削除
    data = data(:, 1 : samples_per_epoch * n_epochs);

    % channel × samples × epochs
    epochs = reshape( ...
        data, ...
        size(data, 1), ...
        samples_per_epoch, ...
        n_epochs);

end