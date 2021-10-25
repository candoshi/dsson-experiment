function out = DSSon(signal,fs,kappa,dilation,alpha,beta,PHI_ring,f_ref_pos,f_ref_neg)
%This function implements the "Direct Segmented Sonification" method
%by P.Vickers and R.Höldrich
%Function implementation based on DSSon_Basic_Model.m
%Input Arguments:
    %signal:       The data to be sonificated
    %kappa:        Time compression factor for entire signal
    %dilation:     dilation factor, for each segment. If dilation < kappa, 
    %              segments will overlap!
    %(alpha:)      Pitch scaling factor for trend-signal (low-freq parts)
    %beta:         Pitch scaling factor for AC part
    %seg_crossing: defines the segmentation cutting points. When the signal
    %              crosses seg_crossing, a cutting point will be set.
    %PHI_ring:     power law distortion factor (>=1)
    %f_ref_pos:    Pitch modulator reference frequency for positive segments
    %f_ref_neg:    Pitch modulator reference frequency for negative segments

    [a,b]=rat(1/kappa);
    signal = resample(signal,a,b);
    %% SEGMENTATION
    if(size(signal,2) ~= 1)
           signal = transpose(signal);
    end
    int_points = find(signal(1:end-1).*signal(2:end)<0);
    int_points = [0;int_points;length(signal)];
    l_seg = length(int_points)-1;
    if signal(1) > 0
        n_pos = floor((l_seg+1)/2);
        n_neg = l_seg-n_pos;
        pos_segments = zeros(n_pos,2);
        for ii = 1:n_pos
            pos_segments(ii,1) = int_points(ii*2-1)+1;
            pos_segments(ii,2) = int_points(ii*2);
        end
        neg_segments = zeros(n_neg,2);
        for ii = 1:n_neg
            neg_segments(ii,1) = int_points(2*ii)+1;
            neg_segments(ii,2) = int_points(2*ii+1);
        end
    else
        n_neg = floor((l_seg+1)/2);
        n_pos = l_seg-n_neg;
        neg_segments = zeros(n_neg,2);
        for ii = 1:n_neg
            neg_segments(ii,1) = int_points(ii*2-1)+1;
            neg_segments(ii,2) = int_points(ii*2);
        end
        pos_segments = zeros(n_pos,2);
        for ii = 1:n_pos
            pos_segments(ii,1) = int_points(2*ii)+1;
            pos_segments(ii,2) = int_points(2*ii+1);
        end
    end 
    %% SONIFICATION
    
    % create array for output
    len_signal = length(signal);
    segments = [pos_segments; neg_segments];
    len_segments = segments(:,2)-segments(:,1)+1;
    array_extension = max((len_segments*kappa/dilation)-(len_signal-segments(:,1)+1));
    
    if kappa <= dilation
        out = zeros(len_signal,1);
    else
        out = zeros(len_signal+ceil(array_extension),1);
    end
    
    [a,b]=rat(kappa/dilation);
    
    for ii = 1:n_pos
        x = resample(signal(pos_segments(ii,1):pos_segments(ii,2)),a,b);
        if pos_segments(ii,1) == pos_segments(ii,2)
            x = x';
        end
        f_i = f_ref_pos*2.^(beta*x);
        cum_phi = cumsum(2*pi*f_i/fs);
        x_sound = abs(x).^PHI_ring.*sin(cum_phi);
        out(pos_segments(ii,1):pos_segments(ii,1)+length(x_sound)-1) = out(pos_segments(ii,1):pos_segments(ii,1)+length(x_sound)-1)+x_sound;
    end
    for ii = 1:n_neg
        x = resample(signal(neg_segments(ii,1):neg_segments(ii,2)),a,b);
        if neg_segments(ii,1) == neg_segments(ii,2)
            x = x';
        end
        f_i = f_ref_neg*2.^(beta*x);
        cum_phi = cumsum(2*pi*f_i/fs);
        x_sound = abs(x).^PHI_ring.*sin(cum_phi);
        out(neg_segments(ii,1):neg_segments(ii,1)+length(x_sound)-1) = out(neg_segments(ii,1):neg_segments(ii,1)+length(x_sound)-1)+x_sound;
    end
    
    out = out/max(abs(out(:)));
end

