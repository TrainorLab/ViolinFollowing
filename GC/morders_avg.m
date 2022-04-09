four = [];
six = [];
eight = [];
ten = [];
twenty = [];
fifty = [];
hundred = [];

for participanti = 1:numel(D)
        %lab = ['morders_' + string(ds_target)];
    four = [four, D{participanti}.M_4_morder];
    six = [six, D{participanti}.M_6_morder];
    eight = [eight, D{participanti}.M_8_morder];
    ten = [ten, D{participanti}.M_10_morder];
    twenty = [twenty, D{participanti}.M_20_morder];
    fifty = [fifty, D{participanti}.M_50_morder];
    hundred = [hundred, D{participanti}.M_100_morder];
end

mfour = mean(four);
mfive = mean(five);