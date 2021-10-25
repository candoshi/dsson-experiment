function [out, res_mean, res_variance, res_skewness, res_kurtosis] = pearsonNoise(duration,fs,fc,t_fade,my_mean,my_variance,my_skewness,my_kurtosis)
    %PEARSONNOISE
    %   This function creates a low-passed pearson distributed noise
    %Input Arguments:
        %duration: Duration of the output file in seconds
        %fs: Sampling rate
        %fc: cutoff frequency for the low pass filter
        %mean: the mean of the pearson distribution
        %variance: the variance of the pearson distribution
        %kurtosis: the kurtosis of the pearson distribution
        %t_fade: length of fade in and fade out in milliseconds

    N = 2*fc*duration;
    inter_faktor = 2*fc/fs;
    diff=10;
    for ii = 1:40000      
        x = pearsrnd(my_mean,my_variance,my_skewness,my_kurtosis,N,1);
        N_interp = 1:inter_faktor:N;
        x_interp = interp1(x,N_interp,'pchip');
        x_interp_moments(ii,:) = [mean(x_interp) std(x_interp) skewness(x_interp) kurtosis(x_interp)];
        my_norm_moments = (x_interp_moments(ii,:)-[0,my_variance,my_skewness,my_kurtosis])./[1,1,1,2];
        if norm(my_norm_moments) < diff
            diff = norm(my_norm_moments);
            noise = x_interp;
        end
    end
    
    res_mean = mean(noise);
    res_variance = var(noise);
    res_skewness = skewness(noise);
    res_kurtosis = kurtosis(noise);
    
    disp("--WANTED VALUES---")
    disp(sprintf("MEAN: %.5f",my_mean))
    disp(sprintf("VARIANCE: %.5f",my_variance))
    disp(sprintf("SKEWNESS: %.5f",my_skewness))
    disp(sprintf("KURTOSIS: %.5f",my_kurtosis))
    disp("---FOUND VALUES---")
    disp(sprintf("MEAN: %.5f",mean(noise)))
    disp(sprintf("VARIANCE: %.5f",var(noise)))
    disp(sprintf("SKEWNESS: %.5f",skewness(noise)))
    disp(sprintf("KURTOSIS: %.5f",kurtosis(noise)))
    fade = floor(t_fade*fs/1000);
    infade = (1:fade)/fade;
    noise(1:fade) = noise(1:fade).*infade;
    noise(end-fade+1:end) = noise(end-fade+1:end).*(flipud(infade'))';
    
    out = 0.05*noise/rms(abs(noise(:)));
end

