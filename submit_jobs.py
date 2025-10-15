from slurmpy import Slurm
import numpy as np
import os
import argparse
import glob

def main(args):
    ncpus = 16
    slurm_config = {
        'nodes': '1',
        'time': '72:59:00',
        'ntasks-per-node': '1',
        'cpus-per-task': f'{ncpus}',
        'output': 'cccserver/parallel_1.log',
        'error': 'cccserver/parallel_1.err'
    }

    n_nodes = int(slurm_config['nodes'])

    run_template = """
    cd /home/guozhang/hmm-stdp
    {}
    """
    cmd = ''

    for train_method in ['rs','ct','is']:
        for w_coeff, v_coeff in [(0.5, 10), (0.5, 2), (0.5, 5), (0.1, 7)]:

            cmd += (f'srun -u --cpu-bind=threads -c {ncpus} matlab -nodisplay -nosplash'
                    f' -r "cd(\'/home/guozhang/hmm-stdp\'), addpath(genpath(cd)),'
                    f' run_experiment(\'{train_method}\', {w_coeff}, {v_coeff}), exit";\n')
    import pdb;
    pdb.set_trace()
    print(cmd)
    if cmd != '':
        hexid = np.random.randint(0, 16**5)
        run_name = 'ep{:05x}'.format(hexid)
        slurm_config['output'] = os.path.join('cccserver', f'{run_name}.log')
        slurm_config['error'] = os.path.join('cccserver', f'{run_name}.err')
        s = Slurm(run_name, slurm_config, bash_strict=False)
        s.run(run_template.format(cmd))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--devel', default=False, action='store_true')
    parser.add_argument('--use_lr_exp_decay', default=False, action='store_true')
    parser.add_argument('--use_rand_ini_w', default=False, action='store_true')
    parser.add_argument('--use_only_one_type', default=False, action='store_true')
    parser.add_argument('--neuron_output', default=False, action='store_true')
    parser.add_argument('--localized_readout', default=False, action='store_true')
    parser.add_argument('--use_uniform_neuron_type', default=False, action='store_true')
    parser.add_argument('--use_dale_law', default=False, action='store_true')
    parser.add_argument('--use_rand_connectivity', default=False, action='store_true')
    parser.add_argument('--recurrent_dampening_factor', default=1.0, type=float)
    parser.add_argument('--dampening_factor', default=0.5, type=float)
    parser.add_argument('--p_reappear', default='.5', type=float)
    parser.add_argument('--vc', default=1e-5, type=float)
    parser.add_argument('--rc', default=0.1, type=float)
    parser.add_argument('--comment', default='no-comment', type=str)
    parser.add_argument('--neuron_model', default='GLIF3', type=str)
    parser.add_argument('--learning_rate', default='.01', type=float)
    parser.add_argument('--scale_we', default=-1, type=float)
    _args = parser.parse_args()
    main(_args)


