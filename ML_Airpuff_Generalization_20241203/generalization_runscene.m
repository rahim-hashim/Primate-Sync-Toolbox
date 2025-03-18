%% Trial Start
% clear dashboard
dashboard(1, ' ')
% check for eye signal
if ~exist('eye_','var'),...
    error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end

% info for camera saving
monkey_name = MLConfig.SubjectName;
trial_num = num2str(TrialRecord.CurrentTrialNumber);

% path to camera control
camera_control_path = 'insert/path/to/camera_control'

%% Hotkeys:
% manual reward
hotkey('r', 'goodmonkey(50, ''eventmarker'', 112, ''nonblocking'', 1);')
% stop task immediately
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);')
% force next condition
hotkey('n', 'next_condition();');
% force next block
hotkey('b', 'next_block();');
hotkey('c', 'idle(0)');
% force neYxt fractal
hotkey('1', 'next_fractal_A();')
hotkey('2', 'next_fractal_B();')
hotkey('3', 'next_fractal_C();')
hotkey('4', 'next_fractal_D();')
hotkey('5', 'next_fractal_E();')

%% Camera

cameras_on = 1; % default = 0

if cameras_on
    % stop the task immediately and stop the cameras
    hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false); system([''python C:\Users\L6_00\Desktop\White_Matter\v2.0.0-win64\Camera_Control\whitematter_stop.py '' monkey_name]);');
    % test for camera save signal to be high
    idle(50);
    if strcmp(trial_num, '1')
        disp('*************WhiteMatter Cameras On*************')
        camera_control_path = horzcat(camera_control_path, 'whitematter.py');
        system(['python ' camera_control_path ' ' monkey_name ' ' trial_num]);
        idle(2000);
    end
elseif strcmp(trial_num, '1')
    disp('*************WhiteMatter Cameras Off*************')
end

%% Remapping Trial Errors/Behavior Codes:
% remap trial error codes
trialerror(1,'No fixation - center',...
           2,'Break fixation - center',...
           3,'Break fixation - center+CS',...
           4,'Break fixation - CS',...
           5,'Not assigned',...
           6,'Not assigned',...
           7,'Not assigned',...
           8,'Not assigned',...
           9,'Not assigned');
       
% remap behavior codes (universal)
bhv_code(   100,'Start Trial',...
            101,'Fixation On',...
            102,'Fixation Success',...
            103,'CS On',...
            104,'Fixation Off',...
            105,'Trace Start',...
            106,'Trace End',...
            107,'Outcome Start',...
            108,'Reward Trigger',...
            109,'Airpuff Trigger',...
            110,'Outcome',...
            111,'Outcome End',...
            112,'Manual Reward',...
            113,'End Trial');  % behavioral codes

%% TrialRecord Variables
condition = TrialRecord.CurrentCondition;
block = TrialRecord.CurrentBlock;
correct_trial_count = sum(TrialRecord.TrialErrors==0);
reinforcement_flag = TrialRecord.User.trial_type.reinforcement_trial(end);
if reinforcement_flag
    trial_type = 'reinforcement'; 
else 
    trial_type = 'choice'; 
end
% reward option parameters
reward_1 = TrialRecord.User.reward_stim_1.reward(end);
reward_1_mag = TrialRecord.User.reward_stim_1.reward_mag(end);
reward_1_prob = TrialRecord.User.reward_stim_1.reward_prob(end);
reward_2 = TrialRecord.User.reward_stim_2.reward(end);
reward_2_mag = TrialRecord.User.reward_stim_2.reward_mag(end);
reward_2_prob = TrialRecord.User.reward_stim_2.reward_prob(end);
% airpuff option parameters
airpuff_1 = TrialRecord.User.airpuff_stim_1.airpuff(end);
airpuff_1_mag = TrialRecord.User.airpuff_stim_1.airpuff_mag(end);
airpuff_1_prob = TrialRecord.User.airpuff_stim_1.airpuff_prob(end);
airpuff_2 = TrialRecord.User.airpuff_stim_2.airpuff(end);
airpuff_2_mag = TrialRecord.User.airpuff_stim_2.airpuff_mag(end);
airpuff_2_prob = TrialRecord.User.airpuff_stim_2.airpuff_prob(end);
% log valence outcome
% TrialRecord.User.valence.valence(end+1) = 


%% End Session
num_blocks = 4;
if block > num_blocks
    if cameras_on
        system(['python C:\Users\L6_00\Desktop\White_Matter\Camera_Control\whitematter_stop.py ' monkey_name])
    end
    escape_screen()
end

%% Change Trials per Block
% trials_per_block_1 = 100;
% % editable('trials_per_block_1');
% trials_per_block_2 = 100;
% % editable('trials_per_block_2');
% TrialRecord.User.trials_per_block_1 = trials_per_block_1;
% TrialRecord.User.trials_per_block_2 = trials_per_block_2;

%% Change Reward Flavor
reward_flavor = 0;
editable('reward_flavor')
TrialRecord.User.flavor = reward_flavor;

%% Stimuli:
fixation_point = 1; % fixation point (fix_white_43pix_10mm)
fractal = 2; % fractal 'fractal-X.png' (200x200)
fractal_2 = 3; % fractal 'fractal-X.png' (200x200)
empty_stim = 4; % empty stimuli (0x0)
start_trial_stim = 5; % black square indicated start of trial
end_trial_stim = 6;   % white square indicated end of trial
stim_1_name = TrialRecord.User.stim_chosen.stimuli(end);
               
%% Time Intervals (in ms):
wait_for_fix = 50000;       % Time to fixate before timeout: 50000 ms
initial_fix = 500;          % Initial central fixation: 500 ms
cs_fix = 200;               % CS presentation central fix: 250 ms
editable('cs_fix');
cs_hold = 100;              % Visual stimulus (CS) on: 350 ms
editable('cs_hold');
cs_hold_choice = 50;        % Time to fixate on choice fractal to "lock it in"
% editable('cs_hold_choice');
trace_interval = 1500;      % Trace interval: 1500ms
trace_interval_choice = 1500;
% editable('trace_interval_choice');
wait_for_choice = 1000;     % Time to wait before choice: 1000 ms
reward_airpuff_time = 2500; % Reward/Airpuff outcome epoch: 2000 ms
reward_small_time = 2000;   % Small reward outcome epoch: 2000 ms
reward_large_time = 4000;   % Large reward outcome epoch: 3000 ms
neutral_time = 50;          % Neutral outcome epoch: 50 ms
airpuff_small_time = 1500;  % Small airpuff outcome epoch: 1500 ms
airpuff_large_time = 4000;  % Large airpuff outcome epoch: 3000 ms
airpuff_interval = 750;
iti_time = 1500;            % ITI: 2000ms
set_iti(iti_time);

%% Error Intervals
error_timeout = 1500; % ITI error: 1500 ms
error_color = [0 0.7 0]; % error background color (green)

%% Fixation Window (in degrees):
fix_radius = 2.5;
editable('fix_radius');
fractal_radius = 3.5;
editable('fractal_radius')
blink_threshold = 10;

%% Reward Parameters:

% large reward
pre_reward_delay = 50;
goodmonkey_num = 12; % default = 8
% editable('goodmonkey_num');
goodmonkey_length = 220; % default = 200
% editable('goodmonkey_length');
goodmonkey_pause = 200; % default = 40
% editable('goodmonkey_pause');

% medium reward
sosomonkey_num = 6; % default = 4
% editable('sosomonkey_num');
sosomonkey_length = 200; % default = 200
% editable('sosomonkey_length');
sosomonkey_pause = 200; % default = 40
% editable('sosomonkey_pause');

% small reward
okmonkey_num = 4; % default = 4
% editable('okmonkey_num');
okmonkey_length = 200; % default = 200
% editable('okmonkey_length');
okmonkey_pause = 200; % default = 40
% editable('okmonkey_pause');

% tiny reward
mehmonkey_num = 2; % default = 4
% editable('mehmonkey_num');
mehmonkey_length = 200; % default = 200
% editable('mehmonkey_length');
mehmonkey_pause = 200; % default = 40
% editable('mehmonkey_pause');

% fix reward
fixreward_num = 1;
editable('fixreward_num');
fixreward_length = 150;
editable('fixreward_length');
fixreward_pause = 150; % default = 40
editable('fixreward_pause');
fix_reward_prob = 0; % default = 0.25
editable('fix_reward_prob');

%% Airpuff Parameters:

% large airpuff
large_airpuff_waveform = [0 0 5 5 5 0 0];
large_airpuff_freq = 10; % default = 5 rate of waveform (samples/sec) 
% small airpuff
small_airpuff_waveform = [0 0 5 5 5 0 0]; % default [0 5 0]
small_airpuff_freq = 10; % default = 15 rate of waveform (samples/sec)
% to ensure no extended airpuff
clear_airpuff_waveform = [0 0 0];
% short airpuff
short_airpuff_waveform = [0 0 0 5 0 0 0];

%% SCENE BUILDING: 

% background: Analog Input Monitor
aim = AnalogInputMonitor(null_);
aim.Channel = 1;                  % General Input 1
aim.Position = [580 20 200 50];   % [left top width height]
aim.YLim = [0 5];
aim.Title = 'Lick';
aim.UpdateInterval = 1;           % redraw every 1 frame

% background: Webcam 1
cam1_flag = false;
cam1 = WebcamMonitor(null_);
cam1.CamNumber = 1;
cam1.Position = [0 0 0.3 0.3]; % [left top width height] in normalized units

% background: Webcam 2
cam2_flag = false;
cam2 = WebcamMonitor(null_);
cam2.CamNumber = 2;
cam2.Position = [0.3 0 0.3 0.3]; % [left top width height] in normalized units

% pulse camera on
% stim = Stimulator(null_);
% stim.Channel = 1;
% stim.Waveform = [0 5 0];
% stim.Frequency = 100;
% stim.WaveformNumber = 1;

%% Scene 0: Clear Airpuff Stim (if applicable)
tc0 = TimeCounter(eye_);
tc0.Duration = 1;
con0 = Concurrent(tc0);
con0.add(aim);
con0.add(cam1);
% con0 = con_cam_add(con0);
clear_stim = Stimulator(eye_);
clear_stim.Channel = [1 2];
clear_stim.Waveform = [clear_airpuff_waveform; clear_airpuff_waveform];
clear_stim.Frequency = small_airpuff_freq;
con0.add(clear_stim);
% scene0 = create_scene(con0, start_trial_stim);
scene0 = create_scene(con0);

% Scene 0 -- Clear Airpuff Stim
run_scene(scene0, 100);        % Clear airpuff stim

%% Scene 1: Central Fixation
fix1 = SingleTarget(eye_);          % We use eye signals (eye_) for tracking. The SingleTarget adapter
fix1.Target = fixation_point;       % checks if the gaze is in the Threshold window around the Target.
fix1.Threshold = fix_radius;        % The Target can be either TaskObject# or [x y] (in degrees).
wth1 = WaitThenHold(fix1);          % The WaitThenHold adapter waits for WaitTime until the fixation
wth1.WaitTime = wait_for_fix;       % is acquired and then checks if the fixation is held for HoldTime.
wth1.HoldTime = initial_fix;        % Since WaitThenHold gets the fixation status from SingleTarget,
con1 = Concurrent(wth1);
con1.add(aim);
% con1 = con_cam_add(con1);
% con1.add(stim);
scene1 = create_scene(con1, fixation_point);  % In this scene, we will present the fixation_point (TaskObject #1)
                                             % and detect the eye movement indicated by the above parameters.

% Scene 1 -- Fixation
tic;
run_scene(scene1,101);    % Fixation on (eventmaker 101)
fix_on = toc;
if ~wth1.Success          % If the WithThenHold failed, (either fixation is not acquired or broken during hold)
    idle(0);              % Clear the screen
    if wth1.Waiting       % Check if we were waiting for fixation.
        error_outcome(1); % If so, fixation was never made and this is the "no fixation (4)" error.
    else
        error_outcome(2);  % If we were not waiting, it means that fixation was acquired but not held,
    end                    % so it is the "break fixation (2)" error.
    return
else
    init_random_num = rand();
    if init_random_num < fix_reward_prob
        init_reward()
    end
    eventmarker(102)       % WaitThenHold Success
end

%% Scene 2a (Fix + CS Presentation)
mul2a = SingleTarget(eye_);
mul2a.Target = fixation_point;
if trial_type == "reinforcement"
    mul2a.Threshold = fractal_radius;
elseif trial_type == "choice"
    mul2a.Threshold = fractal_radius-1;
end
wth2a = WaitThenHold(mul2a);
wth2a.WaitTime = 0;
% wth2a.WaitTime = wait_for_choice;
wth2a.HoldTime = cs_fix;
con2a = Concurrent(wth2a);
con2a.add(aim);
% con2a = con_cam_add(con2a);
if trial_type == "reinforcement"
    scene2a = create_scene(con2a,[fixation_point fractal]);
elseif trial_type == "choice"
    scene2a = create_scene(con2a,[fixation_point fractal fractal_2]);
end

% Scene 2a -- Fix + CS Presentation
tic;
cs_fliptime = run_scene(scene2a,103);      % Fix+CS On
if ~wth2a.Success
    error_outcome(3)
    return
end
fix_cs_on = toc;

%% Scene 2b (CS Choice)
if trial_type == "reinforcement"
    mul2b = SingleTarget(eye_);
    mul2b.Target = fractal;
    mul2b.Threshold = fractal_radius;
    wth2b = WaitThenHold(mul2b);
    wth2b.WaitTime = 0;
%     wth2b.WaitTime = wait_for_choice;
    wth2b.HoldTime = cs_hold;
    con2b = Concurrent(wth2b);
    con2b.add(aim);
%     con2b = con_cam_add(con2b);
    scene2b = create_scene(con2b,[fixation_point fractal]);
elseif trial_type == "choice"
    mul2b = MultiTarget(eye_);
    mul2b.Target = [fractal fractal_2];
    mul2b.Threshold = fractal_radius;
    mul2b.WaitTime = wait_for_choice;
    mul2b.HoldTime = cs_hold_choice;
    con2b = Concurrent(mul2b);
    con2b.add(aim);
%     con2b = con_cam_add(con2b);
    scene2b = create_scene(con2b,[fractal fractal_2]);
end
tic;
cs_fliptime = run_scene(scene2b,104);      % Fixation Off (CS Still On)
cs_on = toc;

% Scene 2b -- CS Presentation
if trial_type == "reinforcement"
    if ~wth2b.Success
        TrialRecord.User.temp.reinforcement(end+1) = 0;
        error_outcome(4)
        return
    end
    TrialRecord.User.temp.reinforcement(end+1) = 1;
    reward_outcome = reward_1;
    reward_mag_outcome = reward_1_mag;
    airpuff_outcome = airpuff_1;
    airpuff_mag_outcome = airpuff_1_mag;
    airpuff_prob_outcome = airpuff_1_prob;
    TrialRecord.User.fractal_chosen.stimuli(end+1) = fractal;
elseif trial_type == "choice"
    % successful fixation
    trace_interval = trace_interval_choice;
    if mul2b.Success
        TrialRecord.User.temp.choice(end+1) = 1;
        chosen_fractal = mul2b.ChosenTarget;
        if chosen_fractal == fractal
            reward_outcome = reward_1;
            reward_mag_outcome = reward_1_mag;
            airpuff_outcome = airpuff_1;
            airpuff_mag_outcome = airpuff_1_mag;
            airpuff_prob_outcome = airpuff_1_prob;
            TrialRecord.User.fractal_chosen.stimuli(end+1) = fractal;
        elseif chosen_fractal == fractal_2
            reward_outcome = reward_2;
            reward_mag_outcome = reward_2_mag;
            airpuff_outcome = airpuff_2;
            airpuff_mag_outcome = airpuff_2_mag;
            airpuff_prob_outcome = airpuff_2_prob;
            TrialRecord.User.fractal_chosen.stimuli(end+1) = fractal_2;
        end
        disp(['Chosen Reward Mag: ' num2str(reward_mag_outcome)])
        disp(['Chosen Airpuff Mag: ' num2str(airpuff_mag_outcome)])
    % failed fixation
    elseif ~mul2b.Success
        TrialRecord.User.temp.choice(end+1) = 0;
        error_outcome(4);
        return
    end
end
% log outcome
TrialRecord.User.fractal_chosen.reward(end+1) = reward_outcome;
TrialRecord.User.fractal_chosen.reward_mag(end+1) = reward_mag_outcome;
TrialRecord.User.fractal_chosen.airpuff(end+1) = airpuff_outcome;
TrialRecord.User.fractal_chosen.airpuff_mag(end+1) = airpuff_mag_outcome;
TrialRecord.User.fractal_chosen.airpuff_freq(end+1) = airpuff_prob_outcome;


%% Scene 3: Trace                                        
tc3 = TimeCounter(eye_);
% if airpuff_mag_outcome > 0
%     trace_interval = 1460;
% end
tc3.Duration = trace_interval;
con3 = Concurrent(tc3);
con3.add(aim);
% con3 = con_cam_add(con3);
scene3 = create_scene(con3);

% Scene 3 -- Trace Interval
tic;
trace_fliptime = run_scene(scene3,105);     % Trace Interval
trace_on = toc;
eventmarker(106);

%% Scene 4
% Scene 4 (Reward)
if reward_outcome
    num_pulses = 0;
    tc4_r = TimeCounter(eye_);
    if reward_mag_outcome == 1
        tc4_r.Duration = reward_large_time;
    else
        tc4_r.Duration = reward_small_time;
    end
    con4_r = Concurrent(tc4_r);
    con4_r.add(aim);
%     con4_r = con_cam_add(con4_r);
    scene4 = create_scene(con4_r);
end

% Scene 4 (Airpuff)
if airpuff_outcome
    airpuff_stim = Stimulator(eye_);
%     Channel 1 = black | left box
%     Channel 2 = green | right box
%     large airpuff 
    if airpuff_mag_outcome == 1
        num_pulses = 2;
        tc4a = TimeCounter(eye_);
        tc4a.Duration = airpuff_interval;
        con4a = Concurrent(tc4a);
        airpuff_stim.Channel = [1 2];
        airpuff_stim.Waveform = [short_airpuff_waveform; short_airpuff_waveform];
        airpuff_stim.Frequency = small_airpuff_freq;
        airpuff_stim.WaveformNumber = 1;            
        con4a.add(airpuff_stim);
        con4a.add(aim);
%         seq4 = Sequential(con4a, 114);
        seq4 = Sequential(con4a);
        % second airpuff
        if num_pulses > 1
            tc4b = TimeCounter(eye_);
            tc4b.Duration = airpuff_interval;
            con4b = Concurrent(tc4b);
            airpuff_stim2 = Stimulator(eye_);
            airpuff_stim2.Channel = [1 2];
            airpuff_stim2.Waveform = [short_airpuff_waveform; short_airpuff_waveform];
            airpuff_stim2.Frequency = small_airpuff_freq;
            airpuff_stim2.WaveformNumber = 1;
            con4b.add(airpuff_stim2);
            con4b.add(aim);
            seq4.add(con4b);
        end
%       third airpuff
        if num_pulses > 2
            tc4c = TimeCounter(eye_);
            tc4c.Duration = airpuff_interval;
            con4c = Concurrent(tc4c);
            airpuff_stim3 = Stimulator(eye_);
            airpuff_stim3.Channel = 1;
            airpuff_stim3.Waveform = small_airpuff_waveform;
            airpuff_stim3.Frequency = small_airpuff_freq;
            airpuff_stim3.WaveformNumber = 1;
            con4c.add(airpuff_stim3);
            con4c.add(aim);
%             con4c = con_cam_add(con4c);
            seq4.add(con4c);
        end
        % break
        tc4d = TimeCounter(eye_);
        tc4d.Duration = airpuff_large_time;
        con4d = Concurrent(tc4d);
        con4d.add(aim);
        seq4.add(con4d);
        scene4 = create_scene(seq4);
    % small airpuff
    else
        tc4 = TimeCounter(eye_);
        tc4.Duration = airpuff_small_time;
        con4 = Concurrent(tc4);
        con4.add(aim);
        airpuff_stim.Channel = 2;
        airpuff_rand_num = rand();
        disp(['  Airpuff Random Number: ' num2str(airpuff_rand_num)])
        if airpuff_rand_num < airpuff_prob_outcome
            num_pulses = 1;
            airpuff_stim.Waveform = small_airpuff_waveform;
        else
            num_pulses = 0;
            airpuff_stim.Waveform = clear_airpuff_waveform;
        end
        airpuff_stim.Frequency = small_airpuff_freq;
        airpuff_stim.WaveformNumber = 1;
        con4.add(airpuff_stim);
        scene4 = create_scene(con4);
    end
end

% Scene 4: (Nothing)
if reward_outcome == 0 && airpuff_outcome == 0
    num_pulses = 0;
    tc4 = TimeCounter(eye_);
    tc4.Duration = neutral_time;
    con4 = Concurrent(tc4);
%     con4 = con_cam_add(con4);
    con4.add(aim);
    airpuff_stim = Stimulator(eye_);
    airpuff_stim.Channel = [1 2]; % both sides
    airpuff_stim.Waveform = [clear_airpuff_waveform; clear_airpuff_waveform];
    airpuff_stim.Frequency = small_airpuff_freq;
    airpuff_stim.WaveformNumber = 1;
%     con4.add(airpuff_stim);
    scene4 = create_scene(con4);
end

% adds left or right for tracking purposes
airpuff_logging();

% Scene 4 -- Outcome Interval
tic;
outcome_fliptime = 0;
if reward_outcome
    send_reward()
elseif airpuff_outcome
    send_airpuff()
else
    send_nothing()
end
outcome_on = toc;

%% Scene 5: Clear Airpuff (if applicable)                                        
tc5 = TimeCounter(eye_);
tc5.Duration = 1;
con5 = Concurrent(tc5);
con5.add(aim);
% con5 = con_cam_add(con5);
clear_stim = Stimulator(eye_);
clear_stim.Channel = [1 2];
clear_stim.Waveform = [clear_airpuff_waveform; clear_airpuff_waveform];
clear_stim.Frequency = small_airpuff_freq;
con5.add(clear_stim);
% scene5 = create_scene(con5, end_trial_stim);
scene5 = create_scene(con5);


% Scene 5 -- Clear Airpuff 
run_scene(scene5);        % Clear airpuff stim
eventmarker(113);

% Print Epoch times
disp('Epoch Times')
disp(['  Fix Success: ' num2str(fix_on)])
disp(['  Fix On + CS On: ' num2str(fix_cs_on)])
disp(['  Fix Off + CS On: ' num2str(cs_on)])
disp(['  Trace: ' num2str(trace_on)])
disp(['  Outcome: ' num2str(outcome_on)])

disp('############################################')

%% CUSTOM FUNCTIONS

function camera_save_test()
    idle(500);
    waiting_for_save_high = 1;
    length_wait = 0;
    disp('Waiting for camera save signal to go high...')
    while waiting_for_save_high ~= 0
        cam_save_signal = get_analog_data('gen3', 500);
        cam_save_high = find(cam_save_signal>1,1,"first");
        waiting_for_save_high = isempty(cam_save_high);
        length_wait = length_wait + 500;
        if length_wait > 2500
            fprintf('Save signal timed out after %s.\n', num2str(length_wait));
            fprintf('Trying to start save again.\n');
            system(['python C:\Users\L6_00\Desktop\White_Matter\Camera_Control\whitematter.py ' monkey_name ' ' trial_num]);
            idle(2000);            
            break
        end
    end
    fprintf('Save signal high after %s. Session intiated.\n', num2str(length_wait));
end

function init_reward()
    goodmonkey(fixreward_length, ...
        'numreward', fixreward_num, ...
        'pausetime', fixreward_pause,...
        'eventmarker', 112,...
        'nonblocking', 1)
end

function send_reward()
    eventmarker(107);
    data_print()
    if reward_mag_outcome == 1
        goodmonkey(goodmonkey_length, ...
            'numreward', goodmonkey_num, ...
            'pausetime', goodmonkey_pause,...
            'eventmarker', 108,...
            'nonblocking', 2)
        TrialRecord.User.reward_stim_1.drops(end+1) = goodmonkey_num;
        TrialRecord.User.reward_stim_1.length(end+1) = goodmonkey_length;
    elseif reward_mag_outcome == 0.75
        goodmonkey(okmonkey_length, ...
        'numreward', sosomonkey_num, ...
        'pausetime', sosomonkey_pause,...
        'eventmarker', 108,...
        'nonblocking', 2)
        TrialRecord.User.reward_stim_1.drops(end+1) = sosomonkey_num;
        TrialRecord.User.reward_stim_1.length(end+1) = sosomonkey_length;
    elseif reward_mag_outcome == 0.5
        goodmonkey(okmonkey_length, ...
        'numreward', okmonkey_num, ...
        'pausetime', okmonkey_pause,...
        'eventmarker', 108,...
        'nonblocking', 2)
        TrialRecord.User.reward_stim_1.drops(end+1) = okmonkey_num;
        TrialRecord.User.reward_stim_1.length(end+1) = okmonkey_length;
    elseif reward_mag_outcome == 0.25
        goodmonkey(mehmonkey_length, ...
        'numreward', mehmonkey_num, ...
        'pausetime', mehmonkey_pause,...
        'eventmarker', 108,...
        'nonblocking', 2)
        TrialRecord.User.reward_stim_1.drops(end+1) = mehmonkey_num;
        TrialRecord.User.reward_stim_1.length(end+1) = mehmonkey_length;
    end
    outcome_fliptime = run_scene(scene4, 110);
    eventmarker(111);
    trialerror(0); % correct
end

function send_airpuff()
    eventmarker(107);
    data_print()
    outcome_fliptime = run_scene(scene4, 109);
    TrialRecord.User.reward_stim_1.drops(end+1) = 0;
    TrialRecord.User.reward_stim_1.length(end+1) = 0;
    eventmarker(111);
    trialerror(0); % correct
end

function send_nothing()
    eventmarker(107);
    data_print()
    outcome_fliptime = run_scene(scene4, 110);
    TrialRecord.User.reward_stim_1.drops(end+1) = 0;
    TrialRecord.User.reward_stim_1.length(end+1) = 0;
    eventmarker(111);
    trialerror(0); % correct
end

function error_outcome(error_code)
    TrialRecord.User.reward_stim_1.drops(end+1) = 0;
    TrialRecord.User.reward_stim_1.length(end+1) = 0;
    TrialRecord.User.fractal_chosen.stimuli(end+1) = 0;
    TrialRecord.User.fractal_chosen.reward(end+1) = 0;
    TrialRecord.User.fractal_chosen.reward_mag(end+1) = 0;
    TrialRecord.User.fractal_chosen.airpuff(end+1) = 0;
    TrialRecord.User.fractal_chosen.airpuff_mag(end+1) = 0;
    idle(error_timeout,error_color);
    trialerror(error_code); % see line 8 (trialerror mapping)
    eventmarker(113);       % mark end of trial
end

function next_condition()
    TrialRecord.User.force_condition_change=1;
    dashboard(4,'Next condition')
end

function next_block()
    TrialRecord.User.force_block_change=1;
    dashboard(4,'Next block')
end

function replay_condition()
    TrialRecord.User.replay_uninstructed=1;
    dashboard(4,'Replay condition as instructed')
end

function next_fractal_A()
    TrialRecord.User.next_fractal=1;
    dashboard(1, 'Next fractal: A')
end

function next_fractal_B()
    TrialRecord.User.next_fractal=2;
    dashboard(1, 'Next fractal: B')
end

function next_fractal_C()
    TrialRecord.User.next_fractal=3;
    dashboard(1, 'Next fractal: C')
end

function next_fractal_D()
    TrialRecord.User.next_fractal=4;
    dashboard(1, 'Next fractal: D')
end

function next_fractal_E()
    TrialRecord.User.next_fractal=5;
    dashboard(1, 'Next fractal: E')
end

% flag to display cam1 and/or cam2
function con = con_cam_add(con)
    if cam1_flag
        con.add(cam1)
    end
    if cam2_flag
        con.add(cam2)
    end
end

% documents airpuff left/right/num_pulses in TrialRecord

function airpuff_logging()
    airpuff_struct =  TrialRecord.User.airpuff_stim_1;
    if airpuff_mag_outcome == 0
        airpuff_struct.L_side(end+1) = 0;
        airpuff_struct.R_side(end+1) = 0;
    else
        if airpuff_stim.Channel == 1 
            airpuff_struct.L_side(end+1) = 1;
            airpuff_struct.R_side(end+1) = 0;
         % right
        elseif airpuff_stim.Channel == 2
            airpuff_struct.L_side(end+1) = 0;
            airpuff_struct.R_side(end+1) = 1;
        % both
        else
            airpuff_struct.L_side(end+1) = 1;
            airpuff_struct.R_side(end+1) = 1;
        end
    end
    TrialRecord.User.airpuff_stim_1.num_pulses(end+1) = num_pulses;
    num_pulses_str = horzcat('Num Pulses: ', num2str(num_pulses));
    disp(num_pulses_str)
    TrialRecord.User.airpuff_stim_1.L_side = airpuff_struct.L_side;
    TrialRecord.User.airpuff_stim_1.R_side = airpuff_struct.R_side;
end

function data_print()
    % prints lick and blink data
    % getting the last <mean_window> elements of lick/blink array
    % before trial outcome (reward, airpuff, nothing)
    mean_window = 1000;
    stim_chosen = TrialRecord.User.stim_chosen.stimuli(end);

    % lick data
    lick_data = get_analog_data('gen1', mean_window);
    lick_data_avg = mean(lick_data);
    lick_data_avg_str = horzcat('Avg Lick: ', num2str(lick_data_avg));
    disp(lick_data_avg_str)
    if stim_chosen == 1
        TrialRecord.User.lick_rate.A(end+1) = lick_data_avg;
    elseif stim_chosen == 2
        TrialRecord.User.lick_rate.B(end+1) = lick_data_avg;
    elseif stim_chosen == 3
        TrialRecord.User.lick_rate.C(end+1) = lick_data_avg;
    elseif stim_chosen == 4
        TrialRecord.User.lick_rate.D(end+1) = lick_data_avg;
    elseif stim_chosen == 5
        TrialRecord.User.lick_rate.E(end+1) = lick_data_avg;
    end
    % eye data
    eye_data = get_analog_data('eye', mean_window);
    eye_data_avg = mean(eye_data);
    DEM_any = any(abs(eye_data(:)) > blink_threshold);
    eye_data_avg_str = horzcat('Avg Eye X: ', num2str(eye_data_avg(1)),...
                                    ' | Y: ', num2str(eye_data_avg(2)));
    disp(eye_data_avg_str)

    % pupil data
    pupil_data = get_analog_data('eyeextra', mean_window);
    blink_data = pupil_data == 0; % blink if pupil == 0
    [n,m] = size(blink_data);
    % when using simulation, size(eyeextra) = [n, 4]
    if (m > 1)
        blink_data_avg = 0;
        blink_any = 0;
    else
        blink_data_avg = mean(blink_data);
        blink_any = any(abs(blink_data(:)) > 0);
    end
    blink_data_str = horzcat('Avg Blink: ', num2str(blink_data_avg));
    disp(blink_data_str)

    stim_chosen = TrialRecord.User.stim_chosen.stimuli(end);
    if stim_chosen == 1
        TrialRecord.User.eye_data_x.A(end+1) = eye_data_avg(1);
        TrialRecord.User.eye_data_y.A(end+1) = eye_data_avg(2);
        TrialRecord.User.blink.A(end+1) = blink_data_avg;
    elseif stim_chosen == 2
        TrialRecord.User.eye_data_x.B(end+1) = eye_data_avg(1);
        TrialRecord.User.eye_data_y.B(end+1) = eye_data_avg(2);
        TrialRecord.User.blink.B(end+1) = blink_data_avg;
    elseif stim_chosen == 3
        TrialRecord.User.eye_data_x.C(end+1) = eye_data_avg(1);
        TrialRecord.User.eye_data_y.C(end+1) = eye_data_avg(2);
        TrialRecord.User.blink.C(end+1) = blink_data_avg;
    elseif stim_chosen == 4
        TrialRecord.User.eye_data_x.D(end+1) = eye_data_avg(1);
        TrialRecord.User.eye_data_y.D(end+1) = eye_data_avg(2);
        TrialRecord.User.blink.D(end+1) = blink_data_avg;
    elseif stim_chosen == 5
        TrialRecord.User.eye_data_x.E(end+1) = eye_data_avg(1);
        TrialRecord.User.eye_data_y.E(end+1) = eye_data_avg(2);
        TrialRecord.User.blink.E(end+1) = blink_data_avg;
    end

    avg_fractal_str_A = horzcat('  Fractal A Avg Lick: ', num2str(mean(TrialRecord.User.lick_rate.A)),... 
                                   '  Eye X: ', num2str(mean(TrialRecord.User.eye_data_x.A)),...
                                    ' | Y: ', num2str(mean(TrialRecord.User.eye_data_y.A)),...
                                    ' blink: ', num2str(mean(TrialRecord.User.blink.A)));
    disp(avg_fractal_str_A)
    avg_fractal_str_B = horzcat('  Fractal B Avg Lick: ', num2str(mean(TrialRecord.User.lick_rate.B)),... 
                                   '  Eye X: ', num2str(mean(TrialRecord.User.eye_data_x.B)),...
                                    ' | Y: ', num2str(mean(TrialRecord.User.eye_data_y.B)),...
                                    ' blink: ', num2str(mean(TrialRecord.User.blink.B)));
    disp(avg_fractal_str_B)
    avg_fractal_str_C = horzcat('  Fractal C Avg Lick: ', num2str(mean(TrialRecord.User.lick_rate.C)),... 
                                   '  Eye X: ', num2str(mean(TrialRecord.User.eye_data_x.C)),...
                                    ' | Y: ', num2str(mean(TrialRecord.User.eye_data_y.C)),...
                                    ' blink: ', num2str(mean(TrialRecord.User.blink.C)));
    disp(avg_fractal_str_C)
    avg_fractal_str_D = horzcat('  Fractal D Avg Lick: ', num2str(mean(TrialRecord.User.lick_rate.D)),... 
                                   '  Eye X: ', num2str(mean(TrialRecord.User.eye_data_x.D)),...
                                    ' | Y: ', num2str(mean(TrialRecord.User.eye_data_y.D)),...
                                    ' blink: ', num2str(mean(TrialRecord.User.blink.D)));
    disp(avg_fractal_str_D)
    avg_fractal_str_E = horzcat('  Fractal E Avg Lick: ', num2str(mean(TrialRecord.User.lick_rate.E)),... 
                                   '  Eye X: ', num2str(mean(TrialRecord.User.eye_data_x.E)),...
                                    ' | Y: ', num2str(mean(TrialRecord.User.eye_data_y.E)),...
                                    ' blink: ', num2str(mean(TrialRecord.User.blink.E)));
    disp(avg_fractal_str_E)

    % Prints success rate on last 5 reinforcement trials
    if length(TrialRecord.User.temp.reinforcement) > 5
        % Get the last 5 values
        lastFiveValues = TrialRecord.User.temp.reinforcement(end-4:end);
        % Calculate the average
        average = mean(lastFiveValues);
        % Print the average
        fprintf('Average (Last 5 Reinforcement): %s\n', num2str(average));
    end

    % Prints success rate on last 5 choice trials
    if length(TrialRecord.User.temp.choice) > 5
        % Get the last 5 values
        lastFiveValues = TrialRecord.User.temp.choice(end-4:end);
        % Calculate the average
        average = mean(lastFiveValues);
        % Print the average
        fprintf('Average (Last 5 Choice): %s\n', num2str(average));
    end

end