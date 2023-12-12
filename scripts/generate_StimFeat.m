%% Import audio and generate stimulus feature for Vuust audio

datadir = '../audio/';


for trial = 1:9
    StimFeat(trial).stimname = stimfiles{trial};
end

