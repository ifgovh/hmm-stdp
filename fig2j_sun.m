
clear
close all
dt = 0.001;
sigma = 0.01;
fil = inline('exp( -((x-mu).^2)./(2*sigma^2) )', 'x', 'mu', 'sigma');
base_path = '/data/guozhang/RESULTS/HMM';
ds = dir(fullfile(base_path,'*_singlestep'));
for setting = 1:numel(ds)
    folders = dir(fullfile(base_path,ds(setting).name,'2025*'));
    [off_diagonal,initial_region, pre_R2,indicator, pre_R1, end_region, R1,  R2]=deal(zeros(numel(folders),20));
    for jj=1:ceil(numel(folders)*1)
        d = dir(fullfile(base_path,ds(setting).name,folders(jj).name, 'data_set*mat'));
        R = load(fullfile(d(1).folder,d(1).name));
        st = R.sim_test{1}.time(1);
        samples = st:dt:R.sim_test{1}.time(end);
        smooth_activity = zeros(numel(d),size(R.sim_test,1),size(R.sim_test,2),R.net.num_neurons, length(samples));
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
        clear data c
        for iter = 1:size(smooth_activity,1)
            for seq_id = 1:size(R.sim_test,1)
                for ii=1:numel(start_ind)
                    data(iter,seq_id,:,ii) = mean(avg_spike_data(iter,seq_id,:,start_ind(ii):end_ind(ii)),4);
                end
            end
            c(iter,:,:) = corr(squeeze(data(iter,1,:,:)),squeeze(data(iter,2,:,:)));
        end
        % c = abs(c);
        plot_iter = 1:size(c,1);
        %                 delay cue delay R1 reward delay R2 reward delay
        % event_start_ind = [1,   51, 151 ,201,      301,  351,      451]; % 4,5 put together
        for ii = 1:numel(plot_iter)
            initial_region(jj,ii) = max(c(plot_iter(ii),1:10,1:10),[],'all');
            indicator(jj,ii) = max(c(plot_iter(ii),11:30,11:30),[],'all');
            pre_R1(jj,ii) = max(c(plot_iter(ii),31:40,31:40),[],'all');
            R1(jj,ii) = max(c(plot_iter(ii),41:60,41:60),[],'all');
            pre_R2(jj,ii) = max(c(plot_iter(ii),61:70,61:70),[],'all');
            R2(jj,ii) = max(c(plot_iter(ii),71:90,71:90),[],'all');
            end_region(jj,ii) = max(c(plot_iter(ii),91:100,91:100),[],'all');
            off_diagonal(jj,ii) = max(c(plot_iter(ii),[1:10,1:10,1:10,31:40,61:70,91:100],[31:40,61:70,91:100,31:40,61:70,91:100]),[],'all');
        end
    end
    save(fullfile(base_path,ds(setting).name,'correlation_sessions.mat'),'c','-v7.3')
    %%
    figure
    hold on
    plot(1:50:size(pre_R1,2)*50,mean(pre_R1,1))
    plot(1:50:size(pre_R2,2)*50,mean(pre_R2,1))
    % plot(mean(off_diagonal,1))
    legend({'pre R1','pre R2'})
    xlabel('Time (ms)')
    ylabel('Correlation coefficient')
    title(ds(setting).name)
    saveas(gcf,fullfile(base_path,ds(setting).name,'pre_R1_R2_max.fig'))
end
% plot_data = {off_diagonal;initial_region; pre_R2;indicator; pre_R1; end_region; R1;  R2;};
% titles = {'Off-diagonal';'Initial region'; 'Pre R2'; 'Indicator'; 'Pre R1'; 'End region'; 'R1'; 'R2';};
% FontSize = 10;
% linewidth = 1;
% MarkerSize = 3;
% ticklength = 0.03;
% capsize = 3;
% fontname = 'Arial';
%
% figure_width = 16;
% total_row = 2;
% total_column = 3;
% EMH = 0.2;
% EMV = 0.5;
% MLR = 0.6;
% MBR = 0.4;
% [ figure_hight, SV, SH, MT,MB,ML,MR ] = get_details_for_subaxis(total_row, total_column, figure_width, EMH, 0.7, EMV, 1,MLR,MBR,2,2);
% figure('NumberTitle','off','name', 'Reproduction', 'units', 'centimeters', ...
%     'color','w', 'position', [0, 0, figure_width, figure_hight], ...
%     'PaperSize', [figure_width, figure_hight]); % this is the trick!
% for ii = 1:numel(plot_data)
% subaxis(total_row,total_column,ii,'SpacingHoriz',SH,...
%     'SpacingVert',SV,'MR',MR,'ML',ML,'MT',MT,'MB',MB);
%     plot(plot_iter,plot_data{ii},'-o','linewidth',linewidth,'MarkerSize',MarkerSize)
%     if ii == 1
%         ylabel('Correlation coefficient','fontsize',FontSize,'fontname',fontname)
%     end
%     if ii ==2
%         xlabel('Training time (x200 ms)','fontsize',FontSize,'fontname',fontname)
%     end
%     ylim([-0.2,1])
%     title(titles{ii},'fontsize',FontSize,'fontname',fontname,'FontWeight','normal')
%     set(gca,'linewidth',linewidth,'FontSize',FontSize,'tickdir','out',...
%     'xminortick','off','yminortick','off','fontname',fontname)
% end
