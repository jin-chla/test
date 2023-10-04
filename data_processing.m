% data_processing.m is based on Data-preprocessing.ipynb, posted under the
% GitHub repository: github.com/arijitiiest/UCI-Human-Activity-Recognition
% The code helps you with "preprocessing" raw data for other purposes,
% such as building prediction models.
% The original data can be downloaded from:
% https://archive.ics.uci.edu/dataset/240/human+activity+recognition+using+smartphones
%% Common practice - erase everything before you start
clear all
clc

%% Read the 'features' of the data collected
% check the content of the file - 561 rows, 2 columns
type ../features.txt

% someone is messing with your code! Danger!

% Skip the empty lines when you read a txt file.
% I am adding this argument, because I noticed that the original
% features.txt has a blank row at the end, and ff ends up having
% 562 rows, not 561 rows.
ff = readlines('../features.txt', 'EmptyLineRule', 'skip');
% When you run the line above, ff will be a single column array
% where the number and characters are concatenated.
% We need to separate the two, so 'split' to have a two-column array.
% Also, It seems like the default delimiter of the split function is ' '.
% If you want to be explicit, you can specify by doing this:
% features = split(ff, ' ');
features = split(ff);

disp(['No of features: ', num2str(size(features,1))])

% Duplicate features - add 'n' if repeated once, 'nn' if repeated twice
% This is what the original coder already 'knew'.
seen = [];
uniq_features = [];
for i=1:size(features,1) % equivalent of size(features, 1): height(features)
    if isempty(seen)
        uniq_features = [uniq_features, features(i,2)];
        seen = [seen, features(i,2)];
    elseif ~ismember(features(i,2), seen)
        uniq_features = [uniq_features, features(i,2)];
        seen = [seen, features(i,2)];
    elseif ~ismember(append(features(i,2),'n'), seen)
        uniq_features = [uniq_features, append(features(i,2),'n')];
        seen = [seen, append(features(i,2), 'n')];
    elseif ~ismember(append(features(i,2),'nn'), seen)
        uniq_features = [uniq_features, append(features(i,2),'nn')];
        seen = [seen, append(features(i,2),'nn')];
    end
end

% measurement values of the train dataset (7352 rows, 561 columns)
X_train = readtable('../train/X_train.txt', 'EmptyLineRule', 'skip');
% set column names
% [width] function is similar to [height]
% It returns the number of columns in an array
X_train = renamevars(X_train, 1:width(X_train), uniq_features);

% add subject number to the dataframe
subject = readlines('../train/subject_train.txt', 'EmptyLineRule','skip');
% If you run the line above, you will have a string array.
% It's not a bad idea to treat subject ids as numbers.
% Then you apply a function [str2num] to the entire array by using
% the function [arrayfun].
X_train.subject = arrayfun(@str2num, subject);

% This is the response variable of the train dataset
% Why no 'EmptyLineRule' argument? You don't need it... it was necessary
% for features.txt file only actually...
y_train = readtable('../train/y_train.txt');
% Why 1 instead of 1:width(y_train)? You can go with the latter, but
% y_train has only 1 column - so why bother typing more?
y_train = renamevars(y_train, 1, 'Activity');

% Labels of the activity
% Check that the numbers 1-6 are associated with the corresponding labels.
gg = readtable('../activity_labels.txt');
% Creating a categorical array from integer values: 1 to 6
y_train_labels = categorical(y_train.Activity, 1:6, gg.Var2);

train = X_train;
% This will add the single column array (values of y_train) to train 
train = [train, y_train];
% Adding another column ('ActivityName'). You can do the same with the line
% above by typing:
% train.Activity = y_train.Activity
% A slight different way (train.Activity = y_train) will still work
% without an error, but the new 'train' will be different.
% Can you tell the difference?
train.ActivityName = y_train_labels;
% This is equivalent to train.sample() where train is the pandas DataFrame
train(ceil(rand*size(train, 1)), :)

%%% Obtain the test dataset
X_test = readtable('../test/X_test.txt');
X_test = renamevars(X_test, 1:width(X_test), uniq_features);
X_test.subject = readlines('../test/subject_test.txt', 'EmptyLineRule', 'skip');

y_test = readtable('../test/y_test.txt');
y_test = renamevars(y_test, 1, 'Activity');
y_test_labels = categorical(y_test.Activity, 1:6, gg.Var2);

% put all columns together
test = X_test;
test = [test, y_test];
test.ActivityName = y_test_labels;

% Check for null values.
isempty(train)
isempty(test)

% Remove '()', '-' and ','
newcolnames = train.Properties.VariableNames;
newcolnames = cellfun(@(str)regexprep(str, '[()]', ''), newcolnames, 'UniformOutput', false);
newcolnames = cellfun(@(str)regexprep(str, '[-]', ''), newcolnames, 'UniformOutput', false);
newcolnames = cellfun(@(str)regexprep(str, '[,]', ''), newcolnames, 'UniformOutput', false);

% change the variable names - this is a different way!
train.Properties.VariableNames = newcolnames;
test.Properties.VariableNames = newcolnames;

% save processed output as csv files to "data" folder.
writetable(train, '../data/train.csv')
writetable(test, '../data/test.csv')
