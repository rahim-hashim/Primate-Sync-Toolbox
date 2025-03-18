function [C,timingfile,userdefined_trialholder] = generalization_userloop(MLConfig,TrialRecord)
% choice_userloop provides information for the next trial rather than
% relying on the conditions file, providing the stimuli and timing files

% Args:
%  - MLConfig: stores the current settings of ML (i.e. screen size)
%  - TrialRecord: stores the variables related to the current trial and 
%    the performance history.Note that the numbers in TrialRecord are 
%    not updated for the next trial until the userloop is finished. 
%    - Example: while in the userloop, TrialRecord.CurrentTrialNumber 
%      is 0 although the trial that we are about to execute is Trial 1.
%
% Returns:
%   - C: taskobjects
%   - timingfile: the timing file name
%   - userdefined_trialholder: the user-defined trialholder name.
    
%% Initializing Task

% default return value
C = [];
timingfile = 'generalization_runscene.m';
userdefined_trialholder = '';
% path assignment for video files
exp_dir = append(MLConfig.MLPath.ExperimentDirectory,...
                 '/', MLConfig.FormattedName, '/');
monkey_name = MLConfig.SubjectName;
fix_list = {'_fix.png'};
% image_list = {'_fractal_A', '_fractal_B', '_fractal_C', '_fractal_D', '_fractal_E'};
image_list = {'_fractal_A', '_fractal_B', '_fractal_C', '_fractal_D', 'novel_fractal'};
reward_flavor = 0; % 0 = grape, 1 = orange, 2 = cherry

% The userloop is called twice before Trial 1 starts: 
%   - once before the pause menu shows up (MonkeyLogic does that, 
%     to retrieve the timingfile name(s))
%   - once immediately before Trial 1

% The very first call to this function is just to retrieve the timing
% filename before the task begins and we don't want to waste our preset
% values for this, so we just return if it is the first call.
persistent timing_filename_returned novel_stim_count ...
           novel_fractal_path novel_fractal_list
if isempty(timing_filename_returned)
    fprintf('Monkey: %s\n', monkey_name)
    timing_filename_returned = true;
    % assign new TrialRecord field for stim_list 
    TrialRecord.User.stim_list = struct('stim_list', image_list);
    % assign new TrialRecord field for 'n' hotkey
    TrialRecord.User.force_condition_change = 0;
    % assign new TrialRecord field for 'b' hotkey
    TrialRecord.User.force_block_change = 0;
    % assign new TrialRecord field for 1, 2, ... hotkeys
    TrialRecord.User.force_condition_1 = 0;
    TrialRecord.User.force_condition_2 = 0;
    % assign new TrialRecord field for replaying incorrect uninstructed
    TrialRecord.User.replay_uninstructed = 0;
    % assign new TrialRecord field for forcing next outcome
    TrialRecord.User.next_fractal = 0;
    % assign number of trials per block
    TrialRecord.User.trials_per_block_1 = 125;
    TrialRecord.User.trials_per_block_2 = 125;
    TrialRecord.User.trials_per_block_3 = 125;
    % assign number of trials with fractal at (0,0) before 
    % switching to (+/- 5, 0)
    TrialRecord.User.trials_fix_zero = 550;
    TrialRecord.User.fix_offset = 0;
    TrialRecord.User.choice_trial_frequency = 0.15;  % default = 0.2
    % assign new TrialRecord field for trial type 
    TrialRecord.User.trial_type = struct('reinforcement_trial', [],...
                                         'choice_trial', []);
    % assign new TrialRecord field for stimuli selected
    TrialRecord.User.stim_chosen = struct('stimuli', []);
    TrialRecord.User.stim_2_chosen = struct('stimuli', []);
    % assign new TrialRecord field for choice fractals
    TrialRecord.User.fractal_chosen = struct('stimuli', [],...
                                             'reward', [],...
                                             'reward_mag', [],...
                                             'airpuff', [],...
                                             'airpuff_mag', [],...
                                             'airpuff_freq', []);
    % assign new TrialRecord field for valence selected
    TrialRecord.User.valence = struct('valence', [],...
                                      'HR', [],...
                                      'LR', [],...
                                      'LA', [],...
                                      'HA', []);
    % assign new TrialRecord field for reward contingency
    TrialRecord.User.flavor = 0; % 0 = grape, 1 = orange
    TrialRecord.User.reward_stim_1 = struct('reward_prob', [],...
                                     'reward_mag', [],...
                                     'reward', [],...
                                     'drops', [],...
                                     'length', [],...
                                     'random_num', [],...
                                     'flavor', []);
    TrialRecord.User.reward_stim_2 = struct('reward_prob', [],...
                                     'reward_mag', [],...
                                     'reward', [],...
                                     'drops', [],...
                                     'length', [],...
                                     'random_num', [],...
                                     'flavor', []);
    TrialRecord.User.airpuff_stim_1 = struct('airpuff_prob', [],...
                                     'airpuff_mag', [],...
                                     'airpuff', [],...
                                     'L_side', [],...
                                     'R_side', [],...
                                     'num_pulses', [],...
                                     'random_num', []);
    TrialRecord.User.airpuff_stim_2 = struct('airpuff_prob', [],...
                                     'airpuff_mag', [],...
                                     'airpuff', [],...
                                     'L_side', [],...
                                     'R_side', [],...
                                     'num_pulses', [],...
                                     'random_num', []);
    % assign new TrialRecord field for lick rate
    TrialRecord.User.lick_rate = struct('A', [],...
                                        'B', [],...
                                        'C', [],...
                                        'D', [],...
                                        'E', []);
    % assign new TrialRecord field for eye x/y
    TrialRecord.User.eye_data_x = struct('A', [],...
                                         'B', [],...
                                         'C', [],...
                                         'D', [],...
                                         'E', []);
    TrialRecord.User.eye_data_y = struct('A', [],...
                                         'B', [],...
                                         'C', [],...
                                         'D', [],...
                                         'E', []);
    % assign new TrialRecord field for blink
    TrialRecord.User.blink = struct('A', [],...
                                    'B', [],...
                                    'C', [],...
                                    'D', [],...
                                    'E', []);
    TrialRecord.User.temp = struct('choice', [],...
                                    'reinforcement', []); 
    novel_fractal_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), 'novel', '*png');
    novel_fractal_list = {dir(novel_fractal_path).name};
    novel_stim_count = 1;
    return
else
    % trigger camera start
end

%% Task

% block and trial
block = TrialRecord.CurrentBlock;
condition = TrialRecord.CurrentCondition;
% change number of trials per block (editable variable)
% if TrialRecord.User.trials_per_block_initial ~= TrialRecord.User.trials_per_block 
%     disp(horzcat('Trials per block changed from ', num2str(TrialRecord.User.trials_per_block_initial),...
%                 ' to ', num2str(TrialRecord.User.trials_per_block)))
%     TrialRecord.User.trials_per_block_initial = trials_per_block;
% end
trials_per_block = 125;
trials_per_block_1 = TrialRecord.User.trials_per_block_1;
trials_per_block_2 = TrialRecord.User.trials_per_block_2;
trials_per_block_3 = TrialRecord.User.trials_per_block_3;

num_blocks = 4;

% number of fractal presentations with neutral outcomes
neutral_trial_count = 8;

% number of fractal presentations with replay from previous day
replay_count = 0;

% number of correct reinforcement trials before a choice trial
choice_trial_frequency = TrialRecord.User.choice_trial_frequency;

% If you want to limit the number of consecutive rewards/airpuffs
%   set blockwise_trials == true
blockwise_trials = true;

persistent trial_type reinforcement_flag choice_flag correct_trial_count

%% Block Change Parameters
if isempty(TrialRecord.TrialErrors)... % first trial
        || TrialRecord.TrialErrors(end)==0 ... % last trial correct
        || TrialRecord.User.force_condition_change==1 % hot key ('n') changes to the next condition

    % override random selection and select condition
    if TrialRecord.User.force_condition_change == 1 && condition == 1
        condition = 2;
        TrialRecord.User.force_condition_change=0;
    end
    if TrialRecord.User.force_condition_1==1, condition=1; end 
    TrialRecord.User.force_condition_1=0;
    if TrialRecord.User.force_condition_2==1, condition=2; end
    TrialRecord.User.force_condition_2=0;
    
    % Increase the block number after trials_per_block correct trials
    correct_trial_count = sum(TrialRecord.TrialErrors==0);
%     block = mod(floor(correct_trial_count/trials_per_block),num_blocks)+1;
    if replay_count > 0
        block_add = 1;
    else
        block_add = 0;
    end
    if correct_trial_count < replay_count
        block = 1;
        choice_trial_frequency = 0;
    elseif correct_trial_count >= replay_count && correct_trial_count < trials_per_block_1
        block = 1 + block_add;
    elseif (correct_trial_count >= trials_per_block_1) &&...
           (correct_trial_count < (trials_per_block_1 + trials_per_block_2))
        block = 2 + block_add;
    elseif (correct_trial_count >= trials_per_block_1 + trials_per_block_2) &&...
            (correct_trial_count < (trials_per_block_1 + trials_per_block_2 + trials_per_block_3))
        block = 3 + block_add;
    else
        block = 4;
    end
    if TrialRecord.User.force_block_change==1
        if block + 1 > num_blocks
            block = block + 1;
        end
        TrialRecord.User.force_block_change = 0;
    end

    % Trial type selection criterion
    % set frequency (every 5 trials)
%     if correct_trial_count > 0 && mod(correct_trial_count, choice_trial_frequency) == 0
    % random frequency
    choice_trial_randn = rand();
    choice_trial_str = 'Choice Trial Random Number: %4.2f (<%4.2f for choice trial)\n';
    % first 4 presentations of each fractal has no outcome
    if correct_trial_count < neutral_trial_count
        trial_type = "reinforcement";
        reinforcement_flag = 1;
        choice_flag = 0;
    elseif correct_trial_count > 0 && choice_trial_randn < choice_trial_frequency
        trial_type = "choice";
        reinforcement_flag = 0;
        choice_flag = 1;
    else
        trial_type = "reinforcement";
        reinforcement_flag = 1;
        choice_flag = 0;
    end
    fprintf(choice_trial_str,choice_trial_randn, choice_trial_frequency)
end

%% Fractal Selection Parameters

% unchanging frequency of conditions
condition_mod = mod(block, 2);
if monkey_name == "Bear"
     if correct_trial_count < neutral_trial_count
        prob_fractal_reinforcement = [2 2 2 2 0];
        prob_fractal_choice_1 = [0 0 0 0 0];
        prob_fractal_choice_2 = [0 0 0 0 0];
        valence_mapping = [0 0 0 0 0];
        reward_mapping = [0 0 0 0 0];
        reward_prob_mapping = [0 0 0 0 0];
        reward_mag_mapping = [0 0 0 0 0];
        airpuff_mapping = [0 0 0 0 0];
        airpuff_prob_mapping = [0 0 0 0 0];
        airpuff_mag_mapping = [0 0 0 0 0];
    else
%         prob_fractal_reinforcement = [3 3 3 3 3];
        if block == 1
            condition = 1;
            prob_fractal_reinforcement = [2 2 2 2 0];
            prob_fractal_choice_1 = [4 4 1 1 0];
            prob_fractal_choice_2 = [1 1 4 4 0];
            valence_mapping = [1 0.5 -0.5  -1 0];
            reward_mapping = [1 1 0 0 0];
            reward_prob_mapping = [1 1 0 0 0];
            reward_mag_mapping = [1 0.5 0 0 0];
            airpuff_mapping = [0 0 1 1 0];
            airpuff_prob_mapping = [0 0 0.5 1 0];
            airpuff_mag_mapping = [0 0 0.5 0.5 0];
%             valence_mapping = [1 0.75 0.25 0 0];
%             reward_mapping = [1 1 1 1 0];
%             reward_prob_mapping = [1 1 1 1 0];
%             reward_mag_mapping = [1 0.5 0.25 0 0];
%             airpuff_mapping = [0 0 0 0 0];
%             airpuff_prob_mapping = [0 0 0 0 0];
%             airpuff_mag_mapping = [0 0 0 0 0];
        elseif block == 2
            condition = 2;
            prob_fractal_reinforcement = [2 2 2 2 0];
            prob_fractal_choice_1 = [3 1 1 3 0];
            prob_fractal_choice_2 = [1 3 3 1 0];
            valence_mapping = [-1 1 0.5 -0.5 0];
            reward_mapping = [0 1 1 0 0];
            reward_prob_mapping = [0 1 1 0 0];
            reward_mag_mapping = [0 1 0.5 0 0];
            airpuff_mapping = [1 0 0 1 0];
            airpuff_prob_mapping = [1 0 0 0.5 0];
            airpuff_mag_mapping = [-0.5 0 0 -0.5 0];
%             prob_fractal_reinforcement = [3 3 3 3 3];
%             prob_fractal_reinforcement = [3 3 3 3 0];
%             valence_mapping = [0.25 0 0.75 1 0];
%             reward_mapping = [1 1 1 1 0];
%             reward_prob_mapping = [1 1 1 1 0];
%             reward_mag_mapping = [0.25 0 0.75 1 0];
%             airpuff_mapping = [0 0 0 0 0];
%             airpuff_prob_mapping = [0 0 0 0 0];
%             airpuff_mag_mapping = [0 0 0 0 0];
        else
            condition = 3;
            prob_fractal_reinforcement = [2 2 2 2 0];
            prob_fractal_choice_1 = [4 4 1 1 0];
            prob_fractal_choice_2 = [1 1 4 4 0];
            valence_mapping = [0.5 1 -1 -0.5 0];
            reward_mapping = [1 1 0 0 0];
            reward_prob_mapping = [1 1 0 0 0];
            reward_mag_mapping = [0.5 1 0 0 0];
            airpuff_mapping = [0 0 1 1 0];
            airpuff_prob_mapping = [0 0 1 0.5 0];
            airpuff_mag_mapping = [0 0 0.5 0.5 0];
%             prob_fractal_reinforcement = [3 3 3 3 3];
%             prob_fractal_reinforcement = [3 3 3 3 0];
%             valence_mapping = [0 0.75 1 0.25 0];
%             reward_mapping = [1 1 1 1 0];
%             reward_prob_mapping = [1 1 1 1 0];
%             reward_mag_mapping = [0 0.75 1 0.25 0];
%             airpuff_mapping = [0 0 0 0 0];
%             airpuff_prob_mapping = [0 0 0 0 0];
%             airpuff_mag_mapping = [0 0 0 0 0];
        end
    end

elseif monkey_name == "Aragorn"
    if correct_trial_count < neutral_trial_count
        prob_fractal_reinforcement = [2 2 2 2 0];
        prob_fractal_choice_1 = [0 0 0 0 0];
        prob_fractal_choice_2 = [0 0 0 0 0];
        valence_mapping = [0 0 0 0 0];
        reward_mapping = [0 0 0 0 0];
        reward_prob_mapping = [0 0 0 0 0];
        reward_mag_mapping = [0 0 0 0 0];
        airpuff_mapping = [0 0 0 0 0];
        airpuff_prob_mapping = [0 0 0 0 0];
        airpuff_mag_mapping = [0 0 0 0 0];
    elseif correct_trial_count < replay_count
        condition = 1;
        prob_fractal_reinforcement = [2 2 2 2 0];
        valence_mapping = [0.5 -0.5 -1 1 0];
        reward_mapping = [1 0 0 1 0];
        reward_prob_mapping = [1 0 0 1 0];
        reward_mag_mapping = [0.5 0 0 1 0];
        airpuff_mapping = [0 1 1 0 0];
        airpuff_prob_mapping = [0 1 1 0 0];penfield
        airpuff_mag_mapping = [0 0.5 1 0 0];
    else
        if block == 1
            condition = 1;
            prob_fractal_reinforcement = [2 2 2 2 0];
            prob_fractal_choice_1 = [3 3 1 1 0];
            prob_fractal_choice_2 = [1 1 3 3 0];
            valence_mapping = [1 0.5 -0.5 -1 0];
            reward_mapping = [1 1 0 0 0];
            reward_prob_mapping = [1 1 0 0 0];
            reward_mag_mapping = [1 0.5 0 0 0];
            airpuff_mapping = [0 0 1 1 0];
            airpuff_prob_mapping = [0 0 1 1 0];
            airpuff_mag_mapping = [0 0 0.5 1 0];
        elseif block == 2
            condition = 2;
            prob_fractal_reinforcement = [2 2 2 2 0];
            prob_fractal_choice_1 = [3 1 1 3 0];
            prob_fractal_choice_2 = [1 3 3 1 0];
            valence_mapping = [0.5 -0.5 -1 1 0];
            reward_mapping = [1 0 0 1 0];
            reward_prob_mapping = [1 0 0 1 0];
            reward_mag_mapping = [0.5 0 0 1 0];
            airpuff_mapping = [0 1 1 0 0];
            airpuff_prob_mapping = [0 1 1 0 0];
            airpuff_mag_mapping = [0 0.5 1 0 0];
        elseif block == 3
            condition = 3;
            prob_fractal_reinforcement = [2 2 2 2 0];
            prob_fractal_choice_1 = [3 3 1 1 0];
            prob_fractal_choice_2 = [1 1 3 3 0];
            valence_mapping = [-0.5 -1 1 0.5 0];
            reward_mapping = [0 0 1 1 0];
            reward_prob_mapping = [0 0 1 1 0];
            reward_mag_mapping = [0 0 1 0.5 0];
            airpuff_mapping = [1 1 0 0 0];
            airpuff_prob_mapping = [1 1 0 0 0];
            airpuff_mag_mapping = [0.5 1 0 0 0];
        else
            condition = 4;
            prob_fractal_reinforcement = [2 2 2 2 0];
            prob_fractal_choice_1 = [3 1 1 3 0];
            prob_fractal_choice_2 = [1 3 3 1 0];
            valence_mapping = [-1 1 0.5 -0.5 0];
            reward_mapping = [0 1 1 0 0];
            reward_prob_mapping = [0 1 1 0 0];
            reward_mag_mapping = [0 1 0.5 0 0];
            airpuff_mapping = [1 0 0 1 0];
            airpuff_prob_mapping = [1 0 0 1 0];
            airpuff_mag_mapping = [1 0 0 0.5 0];
        end
    end

% Test (i.e. not Bear/Aragorn)
else
    % Probability of each fractal: [A B C D E]
    % 50-50 probability of getting set 1 or set 2
    prob_fractal_choice_1 = [1 1 1 1 1];
    prob_fractal_choice_2 = [1 1 1 1 1];
    if condition_mod == 1
        condition = 1;
        prob_fractal_reinforcement = [2 2 2 2 1];
        valence_mapping = [1 0.5 -0.5 -1 0];
        reward_mapping = [1 1 0 0 0];
        reward_prob_mapping = [1 1 0 0 0];
        reward_mag_mapping = [1 0.5 0 0 0];
        airpuff_mapping = [0 0 1 1 0];
        airpuff_prob_mapping = [0 0 1 1 0];
        airpuff_mag_mapping = [0 0 0.5 1 0];
    else
        condition = 2;
        prob_fractal_reinforcement = [2 2 2 2 1];
        valence_mapping = [-0.5 -1 1 0.5 0];
        reward_mapping = [0 0 1 1 0];
        reward_prob_mapping = [0 0 1 1 0];
        reward_mag_mapping = [0 0 1 0.5 0];
        airpuff_mapping = [1 1 0 0 0];
        airpuff_prob_mapping = [1 1 0 0 0];
        airpuff_mag_mapping = [0.5 1 0 0 0];
    end
end

% Randomly select reward
random_num = rand();

% Set a new condition
persistent index_chosen_1 ratio_randomized_1 ...
           index_chosen_2 ratio_randomized_2...
           ratio_randomized ratio_stimuli

%% Set Stimuli
fix = fix_list{1};

disp('Ratio of Stimuli:')
disp(ratio_stimuli)

% reinforcement only
if trial_type == "reinforcement"

    % blockwise_trials set above
    if blockwise_trials == true
        if isempty(TrialRecord.TrialErrors) % first trial
            ratio_stimuli = prob_fractal_reinforcement;
            condition = 1;
        elseif mod(correct_trial_count, trials_per_block) == 0 % reset at every block switch
            ratio_stimuli = prob_fractal_reinforcement;
        else
            if  TrialRecord.TrialErrors(end)==0 && TrialRecord.User.trial_type.reinforcement_trial(end)==1
                last_trial_stim = TrialRecord.User.stim_chosen.stimuli(end);
                if ratio_stimuli(last_trial_stim) > 0
                    ratio_stimuli(last_trial_stim) = ratio_stimuli(last_trial_stim) - 1;
                end
            end
        end
    % fractal selected randomly from prob_fractal distribution
    else
        ratio_stimuli = prob_fractal_reinforcement;
    end
    
    if isequal(ratio_stimuli, zeros(1, length(prob_fractal_reinforcement)))
        ratio_stimuli = prob_fractal_reinforcement;
    end
    
    % Randomly select fractal to present
    ratio_sequence = [];
    for i=1:numel(ratio_stimuli)
        sequence_copy = ratio_sequence;
        add_vector = ones(1, ratio_stimuli(i))*i;
        ratio_sequence = [sequence_copy add_vector];
    end
    % stim 1
    % Randomly select fractal to present
    ratio_sequence = [];
    for i=1:numel(prob_fractal_reinforcement)
        sequence_copy = ratio_sequence;
        add_vector = ones(1, ratio_stimuli(i))*i;
        ratio_sequence = [sequence_copy add_vector];
    end
    if correct_trial_count < TrialRecord.User.trials_fix_zero
        [x1, y1] = deal(0,0);
        [x2, y2] = deal(0,0);
        TrialRecord.User.fix_offset = 0;
    else
        TrialRecord.User.fix_offset = 1;
        if random_num < 0.5
            [x1, y1] = deal(-1*fractal_offset_pos,0);
            [x2, y2] = deal(fractal_offset_pos,0);
        else
            [x1, y1] = deal(fractal_offset_pos,0);
            [x2, y2] = deal(-1*fractal_offset_pos,0);
        end
    end
    [w1, l1] = deal(500,500);
    ratio_randomized = ratio_sequence(randperm(length(ratio_sequence)));
    index_chosen_1 = ratio_randomized(1);
    % force next valence
    if TrialRecord.User.next_fractal ~= 0
        next_fractal = TrialRecord.User.next_fractal;
        index_chosen_1 = next_fractal;
        fprintf('Forced Next Fractal: %s\n', image_list{index_chosen_1})
        TrialRecord.User.next_fractal = 0;
    end
    stim = image_list{index_chosen_1};
    % familiar fractal
    if strcmp(stim,'novel_fractal') == 0
        stim_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), stim);
    % novel fractal
    else
        stim = sprintf('_fractal_%d.png', novel_stim_count);
        stim_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), 'novel', stim);
        novel_stim_count = novel_stim_count + 1;
    end
    stim_1_valence = valence_mapping(index_chosen_1);
    stim_1_reward = reward_mapping(index_chosen_1);
    stim_1_reward_prob = reward_prob_mapping(index_chosen_1);
    stim_1_reward_mag = reward_mag_mapping(index_chosen_1);
    stim_1_airpuff = airpuff_mapping(index_chosen_1);
    stim_1_airpuff_prob = airpuff_prob_mapping(index_chosen_1);
    stim_1_airpuff_mag = airpuff_mag_mapping(index_chosen_1);
    % stim 2 (hidden)
    [w2, l2] = deal(0,0);
    index_chosen_2 = 0;
    stim_2_path = stim_path;    % same path as stim_1
    stim_2_valence = 0;
    stim_2_reward = 0;
    stim_2_reward_prob = 0;
    stim_2_reward_mag = 0;
    stim_2_airpuff = 0;
    stim_2_airpuff_prob = 0;
    stim_2_airpuff_mag = 0;

% choice and reinforcement
elseif trial_type == "choice"
    fractal_offset_pos = 8;
    % only change after correct trials
    if TrialRecord.TrialErrors(end)==0
        ratio_sequence = [];
        % weigh comparisons between large/small more
        choice_flip = rand();
        if choice_flip < 0.5
            prob_fractal_choice = prob_fractal_choice_1;
        else
            prob_fractal_choice = prob_fractal_choice_2;
        end
        disp(horzcat('Choice Fractal Probability: ', num2str(prob_fractal_choice)))
        for i=1:numel(prob_fractal_choice)
            sequence_copy = ratio_sequence;
            add_vector = ones(1, prob_fractal_choice(i))*i;     % select randomly from prob_fractal
            ratio_sequence = [sequence_copy add_vector]; % rather than ratio_fractal
        end
        disp(horzcat('  Choice Fractal 1: ', num2str(ratio_sequence)))
        ratio_randomized_1 = ratio_sequence(randperm(length(ratio_sequence)));
        index_chosen_1 = ratio_randomized_1(1);
        stim = image_list{index_chosen_1};
        % familiar fractal
        if strcmp(stim,'novel_fractal') == 0
            stim_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), stim);
        % novel fractal
        else
            stim = sprintf('_fractal_%d.png', novel_stim_count);
            stim_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), 'novel', stim);
            novel_stim_count = novel_stim_count + 1;
        end
        ratio_sequence = ratio_sequence(ratio_sequence~=index_chosen_1); % unique comparisons only
        % stim 2
        disp(horzcat('  Choice Fractal 2: ', num2str(ratio_sequence)))
        ratio_randomized_2 = ratio_sequence(randperm(length(ratio_sequence)));
        index_chosen_2 = ratio_randomized_2(1);
%         if index_chosen_2 ~= 5
%             stim_2 = image_list{index_chosen_2};
%             stim_2_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), stim_2);
%          % novel fractal
%         else
%             stim_2 = sprintf('_fractal_%d.png', novel_stim_count);
%             stim_2_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), 'novel', stim_2);
%             novel_stim_count = novel_stim_count + 1;
%         
%         end
        stim_2 = image_list{index_chosen_2};
        if strcmp(stim_2,'novel_fractal') == 0
            stim_2_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), stim_2);
        % novel fractal
        else
            stim_2 = sprintf('_fractal_%d.png', novel_stim_count);
            stim_2_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), 'novel', stim_2);
            novel_stim_count = novel_stim_count + 1;
        end
    else
        fractal_order = rand();
        % if error on previous choice, randomly flip side
        if fractal_order > 0.5
            disp('  flip sides')
            temp = index_chosen_1;
            index_chosen_1 = index_chosen_2;
            index_chosen_2 = temp;
        end
        stim = image_list{index_chosen_1};
        % familiar fractal
        if strcmp(stim,'novel_fractal') == 0
            stim_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), stim);
        % novel fractal
        else
            stim = sprintf('_fractal_%d.png', novel_stim_count);
            stim_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), 'novel', stim);
        end
        stim_2 = image_list{index_chosen_2};
        if strcmp(stim_2,'novel_fractal') == 0
            stim_2_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), stim_2);
         % novel fractal
        else
            stim_2 = sprintf('_fractal_%d.png', novel_stim_count);
            stim_2_path = fullfile('_fractals', datestr(date, 'yyyymmdd'), 'novel', stim_2);        
        end
    end
    % set stim 1
%     [x1, y1] = deal(-7, 0);
    rand_position_left_up = rand();
    if rand_position_left_up < 0.5
        [x1, y1] = deal(-1*fractal_offset_pos, 0);
    else
        [x1, y1] = deal(0, fractal_offset_pos);
    end
    [w1, l1] = deal(500,500);
    stim_1_valence = valence_mapping(index_chosen_1);
    stim_1_reward = reward_mapping(index_chosen_1);
    stim_1_reward_prob = reward_prob_mapping(index_chosen_1);
    stim_1_reward_mag = reward_mag_mapping(index_chosen_1);
    stim_1_airpuff = airpuff_mapping(index_chosen_1);
    stim_1_airpuff_prob = airpuff_prob_mapping(index_chosen_1);
    stim_1_airpuff_mag = airpuff_mag_mapping(index_chosen_1);
    % set stim 2

    rand_position_right_down = rand();
    if rand_position_right_down < 0.5
        [x2, y2] = deal(fractal_offset_pos, 0);
    else
        [x2, y2] = deal(0, -1*fractal_offset_pos);
    end
%     [x2, y2] = deal(0, 7);
    [w2, l2] = deal(500,500);
    stim_2_valence = valence_mapping(index_chosen_2);
    stim_2_reward = reward_mapping(index_chosen_2);
    stim_2_reward_prob = reward_prob_mapping(index_chosen_2);
    stim_2_reward_mag = reward_mag_mapping(index_chosen_2);
    stim_2_airpuff = airpuff_mapping(index_chosen_2);
    stim_2_airpuff_prob = airpuff_prob_mapping(index_chosen_2);
    stim_2_airpuff_mag = airpuff_mag_mapping(index_chosen_2);

end
C = {sprintf('pic(%s,0,0)',fix), ...
    sprintf('pic(%s,%d,%d,%d,%d)',stim_path,x1,y1,w1,l1), ...
    sprintf('pic(%s,%d,%d,%d,%d)',stim_2_path,x2,y2,w2,l2), ...
    sprintf('crc(0.001,[0 0 0],0,0,0)'), ...
    sprintf('sqr(2,[1 1 1],1,-25,-3)'), ...
    sprintf('sqr(2,[0 0 0],1,-25,-3)'),
    };

% %% Displaying Trial Parameters
fprintf('Trial Type: %s\n', trial_type)
fprintf('  Fractal 1: %s\n', stim);
fprintf('    Reward: %d\n', stim_1_reward);
fprintf('    Airpuff: %d\n', stim_1_airpuff);
if trial_type == "choice"
    fprintf('  Fractal 2: %s\n', stim_2);
    fprintf('    Reward: %d\n', stim_2_reward);
    fprintf('    Airpuff: %d\n', stim_2_airpuff);
end

%% Add to TrialRecord
% trial type
trial_type_container = TrialRecord.User.trial_type;
trial_type_container.reinforcement_trial(end+1) = reinforcement_flag;
trial_type_container.choice_trial(end+1) = choice_flag;
TrialRecord.User.trial_type = trial_type_container;

% stim container
stim_container = TrialRecord.User.stim_chosen;
stim_container.stimuli(end+1) = index_chosen_1;
TrialRecord.User.stim_chosen = stim_container;

stim_2_container = TrialRecord.User.stim_2_chosen;
stim_2_container.stimuli(end+1) = index_chosen_2;
TrialRecord.User.stim_2_chosen = stim_2_container;

% reward_cond container for stim 1
reward_container = TrialRecord.User.reward_stim_1;
reward_container.reward(end+1) = stim_1_reward;
reward_container.reward_prob(end+1) = stim_1_reward_prob;
reward_container.reward_mag(end+1) = stim_1_reward_mag;
reward_container.flavor(end+1) = reward_flavor;
TrialRecord.User.reward_stim_1 = reward_container;

% reward_cond container for stim 2
reward_container_2 = TrialRecord.User.reward_stim_2;
reward_container_2.reward(end+1) = stim_2_reward;
reward_container_2.reward_prob(end+1) = stim_2_reward_prob;
reward_container_2.reward_mag(end+1) = stim_2_reward_mag;
reward_container_2.flavor(end+1) = reward_flavor;
TrialRecord.User.reward_stim_2 = reward_container_2;

% airpuff_cond container for stim 1
airpuff_container = TrialRecord.User.airpuff_stim_1;
airpuff_container.airpuff(end+1) = stim_1_airpuff;
airpuff_container.airpuff_prob(end+1) = stim_1_airpuff_prob;
airpuff_container.airpuff_mag(end+1) = stim_1_airpuff_mag;
TrialRecord.User.airpuff_stim_1 = airpuff_container;

% airpuff_cond container for stim 2
airpuff_container_2 = TrialRecord.User.airpuff_stim_2;
airpuff_container_2.airpuff(end+1) = stim_2_airpuff;
airpuff_container_2.airpuff_prob(end+1) = stim_2_airpuff_prob;
airpuff_container_2.airpuff_mag(end+1) = stim_2_airpuff_mag;
TrialRecord.User.airpuff_stim_2 = airpuff_container_2;

%%
% Set the block number and the condition number of the next trial. Since
% this userloop function provides the list of TaskObjects and timingfile
% names, ML does not need the block/condition number. They are just for
% your reference.
% However, if TrialRecord.NextBlock is -1, the task ends immediately
% without running the next trial.
TrialRecord.NextBlock = block;
TrialRecord.NextCondition = condition;
