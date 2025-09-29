
clear
close all
d = dir('D:\temp\2025.08.30-21h31m04s_noreward_ct\data_set*mat');
dt = 0.001;
sigma = 0.01;
fil = inline('exp( -((x-mu).^2)./(2*sigma^2) )', 'x', 'mu', 'sigma');

for iter = 1:numel(d)
    R = load(fullfile(d(iter).folder,d(iter).name));
    st = R.sim_test{1}.time(1);
    samples = st:dt:R.sim_test{1}.time(end);
    for seq_id = 1:size(R.sim_test,1)
        for trial = 1:size(R.sim_test,2)
            data_field = R.sim_test{seq_id,trial}.Zt;
            cur_peth = zeros( R.net.num_neurons, length(samples) );
            for i = 1:size( data_field, 2 )
                cur_peth(data_field(1,i),:) = cur_peth(data_field(1,i),:) + fil( samples, data_field(2,i), sigma );
            end
            smooth_activity(iter,seq_id,trial,:,:) = cur_peth;
        end
    end
end

avg_spike_data = squeeze(mean(smooth_activity,3));
% { [ 1,2,2,1,4,5,1,6,6,1], ...     %dealy 1, near cue 2, far cue 3, R1 cue 4, reward 5, R2 cue 6, 
% [ 1,3,3,1,4,4,1,6,5,1 ], ...     %far
%                delay cue delay R1 reward delay R2 reward delay
event_start_ind = [1,   51, 151 ,201,      301,  351,      451]; % 4,5 put together
% end_ind = [ 50,  150, 200, 300,      350,  450,      501];
start_ind = 1:5:496;
end_ind = 5:5:501;
for iter = 1:size(smooth_activity,1)
    for seq_id = 1:size(R.sim_test,1)
        for ii=1:numel(start_ind)
        data(iter,seq_id,:,ii) = mean(avg_spike_data(iter,seq_id,:,start_ind(ii):end_ind(ii)),4);
        end
    end
    c(iter,:,:) = corr(squeeze(data(iter,1,:,:)),squeeze(data(iter,2,:,:)));
end
%%
figure
plot_iter = [1,2,3,4,25];
for ii = 1:5
subplot(1,5,ii)
hold on
imagesc(start_ind-0.5,start_ind-0.5,squeeze(c(plot_iter(ii),:,:)))
title(sprintf('%d ms',200*(plot_iter(ii)-1)))
for j = 1:numel(event_start_ind)
plot([event_start_ind(j),event_start_ind(j)],[0,500],'w:')
plot([0,500],[event_start_ind(j),event_start_ind(j)],'w:')
end
caxis([0,1])
colorbar
axis square 
axis([0,500,0,500])
set(gca,'xtick',event_start_ind([2,4,6])+50,'XTickLabel',{'cue','R1','R2'},'ydir','reverse',...
    'ytick',event_start_ind([2,4,6])+50,'YTickLabel',{'cue','R1','R2'})
end