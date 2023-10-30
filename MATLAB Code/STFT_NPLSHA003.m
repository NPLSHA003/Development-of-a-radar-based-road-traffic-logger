
function [SpecMatrix, FreqAxis_Hz, t] = STFT_NPLSHA003(y,fs, WL, overlap_factor)
% Input:
% y  is the audio signal
% fs is the sampling frequency
% WL is the window length or samples per frame
% overlap_factor the percentage that the frames overlap

% Output:
% SpecMatrix is a compex spectrogram matrix
% FreqAxis_Hz is the frequency
% t is the time

w = hamming(WL).';                     % Window function
N_overlap = floor(WL*overlap_factor);   % Number of samples that each frame overlaps
N = length(y);                          % Number of samples

y = single(y).';                        % Change data type and convert to row vector;

frames = floor((N - WL) / (WL-N_overlap)) + 1 ;  % Calculate number of frames
count = 1;                                       % 
SpecMatrix = zeros(WL,frames);                   % Allocating space for the spectrogram matric
Idx = 1:WL-N_overlap:N-N_overlap;                % This calculates the index at which each 
for i = 1:frames-1
    StartIdx = Idx(i);                    % The start index of each frame
    StopIdx = Idx(i)+WL-1;                % The stop index of each frame 
    Frame_w = y(StartIdx:StopIdx).*w;     % Multiply each frame by the window functoin
    Frame_fft = fftshift(fft(Frame_w)).'; % Take the fft off each frame and convert the row vector in a column
    SpecMatrix(:,count) = Frame_fft;      % Add the fft of each frame into the spectrogram matric
    count=count+1;
   
end

FreqAxis_Hz = (-WL/2:1:(WL/2-1))*fs/WL;                    % frequency axis 
t = (WL/2:WL-N_overlap:WL/2+(frames-1)*(WL-N_overlap))/fs; % Time axis


