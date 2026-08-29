T = readtable("../participants.tsv", ...
    "FileType", "text", ...
    "Delimiter", "\t");

% pre / post の人数
n_pre  = sum(strcmp(string(T.pre_test),  "done"));
n_post = sum(strcmp(string(T.post_test), "done"));

fprintf("Pre-test : %d 人\n", n_pre);
fprintf("Post-test: %d 人\n", n_post);

%% Pre/Postの両方が揃っている被験者
both_done = strcmp(string(T.pre_test), "done") & ...
    strcmp(string(T.post_test), "done");

n_both = sum(both_done);

fprintf("Pre/Post 両方あり: %d 人\n", n_both);

% 両方参加してる人をtsvで出す
T_both = T(both_done, :);

% tsv保存
writetable(T_both, "../participants_both_done.tsv", ...
    "FileType", "text", ...
    "Delimiter", "\t");

