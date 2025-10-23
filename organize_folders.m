clear
% Base directory where the folders are located
base_dir = '/data/guozhang/RESULTS/HMM';

% Get trial folders (folders starting with '2025')
trial_folders = dir(fullfile(base_dir, '2025*'));
trial_folders = {trial_folders.name};

% Move the matching folders into the setting folder
for ii = 1:numel(trial_folders)

    source_folder = fullfile(base_dir, trial_folders{ii});
    a_file = fullfile(base_dir, trial_folders{ii},'data_set_00000000.mat');
    load(a_file,'net');

    setting_folder = sprintf('%s_w%.1f_v%.1f_singlestep', net.train_method, net.w_coeff, net.v_coeff);
    setting_path = fullfile(base_dir, setting_folder);
    if ~exist(setting_path, 'dir')
        mkdir(setting_path);
    end
    destination_folder = fullfile(setting_path, trial_folders{ii});

    % Move the folder
    copyfile(source_folder, destination_folder);

end
