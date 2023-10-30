function [] = cantenna_dop_v3_yunus(wavFile)
% function [] = cantenna_dop_v3_yunus_new(wavFile)
% 
% Produces a DTI (Doppler x time intensity) image of the
% cantenna recording. Assumes the data is collected with
% the radar in a continuous wave (CW) mode. See inside
% the function for more parameters.
%
%    wavFile = the filename of the .WAV file to process
%    

% Input parameters
CPI = 0.25; % seconds

% Constants
c = 299e6; % (m/s) speed of light
fc = 2590e6; % (Hz) Center frequency (connect VCO Vtune to +5)
maxSpeed_km_hr = 100; % (km/hr) maximum speed to display

% computations
lamda = c/fc;

% use a default filename if none is given
if ~exist('wavFile','var')
    wavFile = 'radar_test2.wav';
end

% read the raw wave data
fprintf('Loading WAV file...\n');
[Y,fs] = audioread(wavFile,'native');
y_test = -Y(:,2); % Received signal at baseband



% Compute the spectrogram 
NumSamplesPerFrame =  2^(nextpow2(round(CPI*fs)));      % Ensure its a power of 2
OverlapFactor = 0.8;                                    % Overlap factor between successive frames 

[S, f, t] = STFT_NPLSHA003(y_test,fs, NumSamplesPerFrame, OverlapFactor);

speed_m_per_sec = f*lamda/2;                                                              % Converting frequency to speed in m/s
speed_km_per_hr = speed_m_per_sec*(60*60/1000);                                           % conversion to km/h

% Filtering out speeds greater than 100 km/h and less than 0 km/h
speed_km_per_hr_Idx = find((speed_km_per_hr <= maxSpeed_km_hr) & (speed_km_per_hr >= 0)); 
SpeedVectorOfInterest = speed_km_per_hr(speed_km_per_hr_Idx);
S_OfInterest = S(speed_km_per_hr_Idx, :);

% Normalizing the data
S_OfInterestToPlot = abs(S_OfInterest)/max(max(abs(S_OfInterest)));

% Perform CA-CFAR detection process on the data to be plotted allowing us
% to remove as much noise as possible. For this we need to set the Refernce
% window, PFA and Gaurd Cells
S_afterCFAR = CA_CFAR(8,10^-12,4,S_OfInterestToPlot);

% Find positions where S is greater than 1
[y_idx,x_idx] = find(S_afterCFAR);

% Retrieving detecting speed at the detected time
DetectedTime = t(x_idx);                       
DetectedSpeeds = SpeedVectorOfInterest(y_idx);


% Plot the spectrogram 
clims = [-50 0];
figure;
subplot(2,1,1)
imagesc(t,SpeedVectorOfInterest,20*log10(S_OfInterestToPlot),clims);
title('Spectrgram with CA-CFAR detection process applied')
xlabel('Time (s)');
ylabel('Speed (km/hr)');
grid on;
colorbar;
colormap('jet');
axis xy;
hold on
% Plotting detection points on the spectrogram
plot(DetectedTime,DetectedSpeeds,'kx','MarkerSize',10) 
legend('Target Detection')
hold off

%% Detecting different cars 
% % This algorithm allows us to differentiate between the cars by using the
% % distance between each detection point. Assuming that the detection points
% % of seperate cars will be further than one standard deviation above the 
% % mean.  
% 
% Distance between each detection point
distance = zeros(1,length(DetectedSpeeds));

for i = 1:length(DetectedSpeeds)-1
    p1 = [DetectedTime(i) DetectedSpeeds(i)];
    p2 = [DetectedTime(i+1) DetectedSpeeds(i+1)];
    distance(i) = norm(p2-p1);
end
% 
STD_dist = (std(distance));         % standard deviation of distance
avg_distance = mean(distance);      % average of distance
thr =  STD_dist+avg_distance+1.5;   % Threshold
% A seperate car will occur at the index when there is a distance greater than the threshold
SC = find(abs((distance))>thr); 



% % % The seperate cars consist of the first detection. My separate car algorithm and the last car
SeparateCars = [1,SC, length(DetectedSpeeds)];
Avg_speed = zeros(1,length(SeparateCars)-1);
Avg_time = zeros(1,length(SeparateCars)-1);

% Calculating the average speed for each car
for i = 1:length(SeparateCars)-1
    idx1 = SeparateCars(i);
    idx2 = SeparateCars(i+1);
    Avg_speed(i) = mean(DetectedSpeeds(idx1:idx2));
    Avg_time(i) = mean(DetectedTime(idx1:idx2));
end


subplot(2,1,2);
plot(Avg_time, Avg_speed,'bx', MarkerSize=10)
title("Road traffic logger")
ylabel("Average Speed of car passing by (km/h)")
xlabel("Time the car passed by (s)")
ylim([0 100])
xlim([0 t(end)])
grid on

