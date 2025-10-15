% run_experiment.m
%
% Train stochastic trajectories into a recurrent
% network of SEMs.
%
% This setting realizes experiment 1 of:
%   D. Kappel, B. Nessler, and W. Maass. STDP Installs in
%   Winner-Take-All Circuits an Online Approximation to
%   Hidden Markov Model Learning. PLOS Computational
%   Biology, 2014.
%
%
% Institute for Theoretical Computer Science
% Graz University of Technology
%
% 10.10.2011
% David Kappel
% http://www.igi.tugraz.at/kappel/
%
function run_experiment( varargin )

% RUN_EXPERIMENT  main entry point
% Usage:
%   run_experiment()                            % use defaults
%   run_experiment(train_method)                % override train_method
%   run_experiment(train_method, w_coeff)       % override w_coeff
%   run_experiment(train_method, w_coeff, v_coeff) % override all three
%
% Examples:
%   run_experiment('st', 0.5, 0.8)

% parse optional args (keeps backward compatible calling style)
train_method = [];
w_coeff = [];
v_coeff = [];

if nargin >= 1
    train_method = varargin{1};
end
if nargin >= 2
    w_coeff = varargin{2};
end
if nargin >= 3
    v_coeff = varargin{3};
end
default_params = default_options(train_method, w_coeff, v_coeff);
%% init
for iiii = 1:50
    close all
    clearvars -except iiii default_params
    run snn1.7/snn_include;
    snn_include( 'sem', 'hmmsem', 'plotting' );




    %% train the network

    ex_path = do_learning_task( '/data/guozhang/RESULTS/HMM/', ...
        { [ 1,2,2,1,4,5,1,7,6,1], ...     %dealy 1, near cue 2, far cue 3, R1 cue 4, reward 5, noreward 6, R2 cue 7,
        [ 1,3,3,1,4,6,1,7,5,1 ], ...     %far
        }, ...
        default_params{:}, ...
        'pat_labels', { 'delay', 'near cue', 'far cue', 'R1 cue', 'reward','noreward', 'R2 cue'}, ...
        'free_run_pat_lenghts', [0.050,0.050,0.150], ...
        'num_neurons', 100, ...             % number of WTA neurons
        'num_inputs', 200, ...              % number of afferent neurons
        'free_run_time', 0.400, ...         % free run time (s)
        'save_interval', 50, ...           % number of iterations between 2 save files
        'num_train_sets', 1000, ...        % number of training iterations
        'collect', '[At,R]', ...
        'num_epochs', 1, ...
        'changelog_flag', 'N' );
    %before 8.30 21h 28m
    % [ 1,2,2,1,4,5,1,6,6,1], ...     %dealy 1, near cue 2, far cue 3, R1 cue 4, reward 5, R2 cue 6,
    % [ 1,3,3,1,4,4,1,6,5,1 ], ...     %far

    % ex_path = do_learning_task( 'D:\temp\', ...
    %                   { [ 1,2,5,6,7 ], ...     %AB-hold-ab
    %                     [ 2,1,5,7,6 ], ...     %BA-hold-ba
    %                     [ 3,4,5,8,9 ], ...     %CD-hold-cd
    %                     [ 4,3,5,9,8 ] }, ...   %DC-hold-dc
    %                   default_params{:}, ...
    %                   'free_run_seqs', { [ 1,2,5 ], ...    %AB-hold
    %                                      [ 2,1,5 ], ...    %BA-hold
    %                                      [ 3,4,5 ], ...    %CD-hold
    %                                      [ 4,3,5 ] }, ...  %DC-hold
    %                   'pat_labels', { 'A', 'B', 'C', 'D', 'hold', 'a', 'b', 'c', 'd' }, ...
    %                   'free_run_pat_lenghts', [0.050,0.050,0.150], ...
    %                   'num_neurons', 100, ...             % number of WTA neurons
    %                   'num_inputs', 200, ...              % number of afferent neurons
    %                   'free_run_time', 0.400, ...         % free run time (s)
    %                   'save_interval', 100, ...           % number of iterations between 2 save files
    %                   'num_train_sets', 5000, ...        % number of training iterations
    %                   'collect', '[At,R]', ...
    %                   'num_epochs', 1, ...
    %                   'changelog_flag', 'N' );



    %% evaluate training result

    fprintf('\n\nevaluating training perforamnce:\n')

    eval_mem_task( ex_path );



    %% display results

    % data = load( [ex_path,'mem_task_test.mat'] );
    %
    % plot_mem_task( data, [], 'seq_id', 1, 'data_set', 'test_data', ...
    %                'plot_spikes', false, 'neuron_order', data.I, 'fig_file', 'evoced_1', ...
    %                'peth_set', 'peth_test', 'dy', 0.5, 'base_path', ex_path );
    %
    % plot_mem_task( data, [], 'seq_id', 2, 'data_set', 'test_data', ...
    %                'plot_spikes', false, 'neuron_order', data.I, 'fig_file', 'evoced_2', ...
    %                'peth_set', 'peth_test', 'dy', 0.5, 'base_path', ex_path );

    % explore_data_set( ex_path )

end
end