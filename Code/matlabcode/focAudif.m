function out = focAudif(signal,fs,f_shift,c)
%Implementation of "focused audification"
%INPUT ARGUMENTS:
    %signal: PCM coded input signal vector
    %fs: original sample rate of input signal (in Hz)
    %rate: Playback rate (factor)
    %f_shift: Single-Sideband-Modulation frequency shift (in Hz)
    %c: Pitch/Frequency Modulation factor (in octaves)
    if(size(signal,1) ~= 1)
       signal = transpose(signal);
    end
    N = length(signal);
    t = linspace(0,N/fs,N);
    Hd = designfilt('hilbertfir','FilterOrder',60,'TransitionWidth',...
        0.1,'DesignMethod','equiripple');
    sighilb = filter(Hd,signal);
    G = filtord(Hd)/2;
    sig_delayed = [zeros(1,G),signal(1:end-G)]; %delay compensates hilbertFIR delay
    fmod = cumtrapz(t,(2*pi*f_shift.*2.^(c*sig_delayed)));
    out = sig_delayed.*cos(fmod) - sighilb.*sin(fmod);
end
