%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALL BUCKET COMBINATION BUILDING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function bigBucketCombinations = processBigBucket(bigBucket)
%     % Initialize the output with the same structure as the big bucket
%     bigBucketCombinations = cell(1, length(bigBucket));
% 
%     % Iterate over each sub-bucket in the big bucket
%     for i = 1:length(bigBucket)
%         subBucket = bigBucket{i}; % Get the sub-bucket
%         % Process the sub-bucket
%         subBucketCombinations = processSubBucket(subBucket);
%         % Store the combinations for this sub-bucket in the corresponding row
%         bigBucketCombinations{i} = subBucketCombinations;
%     end
% end
% 
% 
% function subBucketCombinations = processSubBucket(subBucket)
%     % Initialize the output
%     subBucketCombinations = {};
% 
%     % Extract the number of required courses (k)
%     k = str2double(subBucket{1}); % First element gives the required number
% 
%     % Initialize a list of available courses
%     availableCourses = {};
% 
%     % Collect courses from rows 2:end
%     for i = 2:length(subBucket)
%         currentElement = subBucket{i};
%         if iscell(currentElement) && size(currentElement, 1) > 1 % Check for nested sub-bucket
%             % Recursively process the nested sub-bucket
%             nestedCombinations = processSubBucket(currentElement);
%             availableCourses = [availableCourses; nestedCombinations]; % Add nested combinations
%         else
%             % Add the course to the available list
%             availableCourses{end+1} = currentElement;
%         end
%     end
% 
%     % Generate combinations of k courses
%     if length(availableCourses) >= k
%         combos = nchoosek(availableCourses, k); % Generate k-combinations
%         for c = 1:size(combos, 1)
%             subBucketCombinations{end+1} = combos(c, :); 
%         end
%     end
% end
function bigBucketCombinations = processBigBucket(bigBucket)
    % Initialize the output with the same structure as the big bucket
    bigBucketCombinations = cell(1, length(bigBucket));
    
    % Iterate over each sub-bucket in the big bucket
    for i = 1:length(bigBucket)
        subBucket = bigBucket{i}; % Get the sub-bucket
        % Process the sub-bucket
        subBucketCombinations = processSubBucket(subBucket);
        % Store the combinations for this sub-bucket in the corresponding row
        bigBucketCombinations{i} = subBucketCombinations;
    end
end

function subBucketCombinations = processSubBucket(subBucket)
    % Initialize the output
    subBucketCombinations = {};
    
    % Extract the number of required courses (k)
    k = str2double(subBucket{1}); % First element gives the required number
    
    % Initialize a list of available courses
    availableCourses = {};
    
    % Collect courses from rows 2:end
    for i = 2:length(subBucket)
        currentElement = subBucket{i};
        if iscell(currentElement) && size(currentElement, 1) > 1 % Check for nested sub-bucket
            % Recursively process the nested sub-bucket
            nestedCombinations = processSubBucket(currentElement);
            % availableCourses = [availableCourses; nestedCombinations]; 
            for j = 1:length(nestedCombinations)
                subBucketCombinations{end+1} = nestedCombinations{j};
            end
        else
            % Add the course to the available list
            availableCourses{end+1} = currentElement;
        end
    end
    
    % Generate combinations of k courses
    if length(availableCourses) >= k
        combos = nchoosek(availableCourses, k); % Generate k-combinations
        for c = 1:size(combos, 1)
            subBucketCombinations{end+1} = combos(c, :); 
        end
    end
end
