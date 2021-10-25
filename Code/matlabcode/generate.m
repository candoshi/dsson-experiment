%script for generating audio files

% due to high number of loop passes in pearsonNoise.m the samples were
% generated once per cutoff frequency, then the clear all command should be
% removed to use the generated samples again with varying sonification
% parameters. Afterwards insert the clear all command again and choose the
% next cutoff frequency and repeat the task for this one.

clear all;
close all;
clc;

%general parameters
fs = 44100;
%Pearson noise parameters
%fc should be only a 1x1 matrix
fc = [500];
%fc = [10 20 40 80 160 320 640 1280 2560 5120 10240 20480];
fade = 500; %milliseconds
duration = 5; %seconds
my_mean = 0;
my_variance = 1;
my_skewness = 0;
my_kurtosis = [3 3.25 3.5 4 5 6 7 8 9 12 15 20];
%my_kurtosis = [4 4.33 4.67 5.33 6.67 8 9.33 10.67 12 16 20 26.67];
numel_kurtosis = numel(my_kurtosis);
%focAudif parameters
f_shift = 1000;
c = 2;
%DSSon paramters
kappa = 1;
dilation = 1;
alpha = 0;
beta = 1;
PHI_ring = 1;
f_ref_pos = 600;
f_ref_neg = 600;

pur_dirname = strcat('pure audification');
foc_dirname = strcat('focused audification_','f_shift',num2str(f_shift),'c',num2str(c));
dss_dirname = strcat('direct segmented sonification_','kappa',num2str(kappa),'dilation',num2str(dilation),'alpha',num2str(alpha),'beta',num2str(beta),'phi',num2str(PHI_ring),'f_pos',num2str(f_ref_pos),'f_neg',num2str(f_ref_neg));
a_setname = 'a';
b_setname = 'b';
c_setname = 'c';

%column vector to store loudness of different files and normalize to the minimum
rms_vector = zeros(3*numel_kurtosis,1);
%length is used for dsson
length_vector = zeros(3*numel_kurtosis,1);

%make some noise and sonifications
%loop over multiple values for fc doesn't work anymore
for i = 1:numel(fc)
    
    % for the dsson all the noise data is stored in a column because the length is not known before -> length of each
    % file gets stored
    ds_son_data = [];
    
    subdirname = strcat('fc',num2str(fc(i)));
    
    mkdir(strcat(pur_dirname,'/',subdirname), a_setname);
    mkdir(strcat(pur_dirname,'/',subdirname), b_setname);
    mkdir(strcat(pur_dirname,'/',subdirname), c_setname);
    
    mkdir(strcat(foc_dirname,'/',subdirname), a_setname);
    mkdir(strcat(foc_dirname,'/',subdirname), b_setname);
    mkdir(strcat(foc_dirname,'/',subdirname), c_setname);
    
    mkdir(strcat(dss_dirname,'/',subdirname), a_setname);
    mkdir(strcat(dss_dirname,'/',subdirname), b_setname);
    mkdir(strcat(dss_dirname,'/',subdirname), c_setname);
    
    
    if ~exist('noise_vector')
        % the different noise data will be stored in rows
        noise_vector = zeros(3*numel_kurtosis,duration*fs);
        % for resulting values after pearson noise function
        result_mean = zeros(3*numel_kurtosis,1);
        result_variance = zeros(3*numel_kurtosis,1);
        result_skewness = zeros(3*numel_kurtosis,1);
        result_kurtosis = zeros(3*numel_kurtosis,1);
        
        for j = 1:numel_kurtosis
        
            %pure audification
            [noise, res_mean, res_variance, res_skewness, res_kurtosis] = pearsonNoise(duration,fs,fc(i),fade,my_mean,my_variance,my_skewness,my_kurtosis(j));
            rms_vector(j) = rms(noise);
            result_mean(j) = res_mean;
            result_variance(j) = res_variance;
            result_skewness(j) = res_skewness;
            result_kurtosis(j) = res_kurtosis;
            noise_vector(j,1:length(noise)) = noise;
        
            [noise, res_mean, res_variance, res_skewness, res_kurtosis] = pearsonNoise(duration,fs,fc(i),fade,my_mean,my_variance,my_skewness,my_kurtosis(j));
            rms_vector(j+numel_kurtosis) = rms(noise);
            result_mean(j+numel_kurtosis) = res_mean;
            result_variance(j+numel_kurtosis) = res_variance;
            result_skewness(j+numel_kurtosis) = res_skewness;
            result_kurtosis(j+numel_kurtosis) = res_kurtosis;
            noise_vector(j+numel_kurtosis,1:length(noise)) = noise;
        
            [noise, res_mean, res_variance, res_skewness, res_kurtosis] = pearsonNoise(duration,fs,fc(i),fade,my_mean,my_variance,my_skewness,my_kurtosis(j));
            rms_vector(j+2*numel_kurtosis) = rms(noise);
            result_mean(j+2*numel_kurtosis) = res_mean;
            result_variance(j+2*numel_kurtosis) = res_variance;
            result_skewness(j+2*numel_kurtosis) = res_skewness;
            result_kurtosis(j+2*numel_kurtosis) = res_kurtosis;
            noise_vector(j+2*numel_kurtosis,1:length(noise)) = noise;
        end
    
        ref_rms = min(rms_vector);
    
        %normalize to reference loudness (maximum loudness without clipping)
        gain = ref_rms./rms_vector;
        norm_noise_vector = diag(gain)*noise_vector;
    
        for j = 1:numel_kurtosis
        
            noisefilename = strcat(pur_dirname,'/',subdirname,'/',a_setname,'/fs',num2str(fs),'fc',num2str(fc(i)),'sollwerte_','me',num2str(my_mean),'var',num2str(my_variance),'ske',num2str(my_skewness),'kur',num2str(my_kurtosis(j)),'istwerte_','me',num2str(result_mean(j)),'var',num2str(result_variance(j)),'ske',num2str(result_skewness(j)),'kur',num2str(result_kurtosis(j)),'.wav')
            audiowrite(noisefilename,norm_noise_vector(j,:),fs);
        
            noisefilename = strcat(pur_dirname,'/',subdirname,'/',b_setname,'/fs',num2str(fs),'fc',num2str(fc(i)),'sollwerte_','me',num2str(my_mean),'var',num2str(my_variance),'ske',num2str(my_skewness),'kur',num2str(my_kurtosis(j)),'istwerte_','me',num2str(result_mean(j+numel_kurtosis)),'var',num2str(result_variance(j+numel_kurtosis)),'ske',num2str(result_skewness(j+numel_kurtosis)),'kur',num2str(result_kurtosis(j+numel_kurtosis)),'.wav')
            audiowrite(noisefilename,norm_noise_vector(j+numel_kurtosis,:),fs);
        
            noisefilename = strcat(pur_dirname,'/',subdirname,'/',c_setname,'/fs',num2str(fs),'fc',num2str(fc(i)),'sollwerte_','me',num2str(my_mean),'var',num2str(my_variance),'ske',num2str(my_skewness),'kur',num2str(my_kurtosis(j)),'istwerte_','me',num2str(result_mean(j+2*numel_kurtosis)),'var',num2str(result_variance(j+2*numel_kurtosis)),'ske',num2str(result_skewness(j+2*numel_kurtosis)),'kur',num2str(result_kurtosis(j+2*numel_kurtosis)),'.wav')
            audiowrite(noisefilename,norm_noise_vector(j+2*numel_kurtosis,:),fs);
        end
    end
    
    for j = 1:numel_kurtosis
        
        %focused audification
%         foc_audif = focAudif(norm_noise_vector(j,:),fs,f_shift,c);
%         noisefilename = strcat(foc_dirname,'/',subdirname,'/dur',num2str(duration),'fs',num2str(fs),'fc',num2str(fc(i)),'fad',num2str(fade),'me',num2str(my_mean),'var',num2str(my_variance),'ske',num2str(my_skewness),'kur',num2str(my_kurtosis(j)),'f_shift',num2str(f_shift),'c',num2str(c),'.wav');
%         audiowrite(noisefilename,foc_audif,fs);
        
        %direct segmented sonification
        ds_sonif = DSSon(noise_vector(j,:),fs,kappa,dilation,alpha,beta,PHI_ring,f_ref_pos,f_ref_neg);
        length_vector(j) = length(ds_sonif);
        rms_vector(j) = rms(ds_sonif);
        ds_son_data = [ds_son_data;ds_sonif];
        
        ds_sonif = DSSon(noise_vector(j+numel_kurtosis,:),fs,kappa,dilation,alpha,beta,PHI_ring,f_ref_pos,f_ref_neg);
        length_vector(j+numel_kurtosis) = length(ds_sonif);
        rms_vector(j+numel_kurtosis) = rms(ds_sonif);
        ds_son_data = [ds_son_data;ds_sonif];
        
        ds_sonif = DSSon(noise_vector(j+2*numel_kurtosis,:),fs,kappa,dilation,alpha,beta,PHI_ring,f_ref_pos,f_ref_neg);
        length_vector(j+2*numel_kurtosis) = length(ds_sonif);
        rms_vector(j+2*numel_kurtosis) = rms(ds_sonif);
        ds_son_data = [ds_son_data;ds_sonif];
    end
    
    
    ref_rms = min(rms_vector);
    start_index = 0;
    
    for j = 1:numel_kurtosis
        
        data = ds_son_data(start_index+1:start_index+length_vector(j));
        norm_data = data*(ref_rms/rms_vector(j));
        rms(norm_data)
        noisefilename = strcat(dss_dirname,'/',subdirname,'/',a_setname,'/fs',num2str(fs),'fc',num2str(fc(i)),'sollwerte_','me',num2str(my_mean),'var',num2str(my_variance),'ske',num2str(my_skewness),'kur',num2str(my_kurtosis(j)),'istwerte_','me',num2str(result_mean(j)),'var',num2str(result_variance(j)),'ske',num2str(result_skewness(j)),'kur',num2str(result_kurtosis(j)),'.wav')
        audiowrite(noisefilename,norm_data,fs);
        
        start_index = start_index+length_vector(j);
        
        data = ds_son_data(start_index+1:start_index+length_vector(j+numel_kurtosis));
        norm_data = data*(ref_rms/rms_vector(j+numel_kurtosis));
        rms(norm_data)
        noisefilename = strcat(dss_dirname,'/',subdirname,'/',b_setname,'/fs',num2str(fs),'fc',num2str(fc(i)),'sollwerte_','me',num2str(my_mean),'var',num2str(my_variance),'ske',num2str(my_skewness),'kur',num2str(my_kurtosis(j)),'istwerte_','me',num2str(result_mean(j+numel_kurtosis)),'var',num2str(result_variance(j+numel_kurtosis)),'ske',num2str(result_skewness(j+numel_kurtosis)),'kur',num2str(result_kurtosis(j+numel_kurtosis)),'.wav')
        audiowrite(noisefilename,norm_data,fs);
        
        start_index = start_index+length_vector(j+numel_kurtosis);
        
        data = ds_son_data(start_index+1:start_index+length_vector(j+2*numel_kurtosis));
        norm_data = data*(ref_rms/rms_vector(j+2*numel_kurtosis));
        rms(norm_data)
        noisefilename = strcat(dss_dirname,'/',subdirname,'/',c_setname,'/fs',num2str(fs),'fc',num2str(fc(i)),'sollwerte_','me',num2str(my_mean),'var',num2str(my_variance),'ske',num2str(my_skewness),'kur',num2str(my_kurtosis(j)),'istwerte_','me',num2str(result_mean(j+2*numel_kurtosis)),'var',num2str(result_variance(j+2*numel_kurtosis)),'ske',num2str(result_skewness(j+2*numel_kurtosis)),'kur',num2str(result_kurtosis(j+2*numel_kurtosis)),'.wav')
        audiowrite(noisefilename,norm_data,fs);
        
        start_index = start_index+length_vector(j+2*numel_kurtosis);
    end
end




