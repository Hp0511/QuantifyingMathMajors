%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE ALL MINIMAL REQUIRED COURSE SETS FROM BUCKETS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function minimalRequirementSets = getMinimalRequiredCourseSets(allBucketCombinations)
%     % Initialize output with an empty starting set
%     minimalRequirementSets = {{}};
% 
%     % Iterate over each bucket
%     for bucketIndex = 1:length(allBucketCombinations)
%         bucketCombinations = allBucketCombinations{bucketIndex};
%         newSets = {}; % Temporary storage for new minimal requirement sets
% 
%         % Expand the minimal requirement sets with all choices from the current bucket
%         for existingSetIdx = 1:length(minimalRequirementSets)
%             existingSet = minimalRequirementSets{existingSetIdx};
% 
%             % Append each valid course combination from the bucket
%             for combIdx = 1:length(bucketCombinations)
%                 newSet = [existingSet, bucketCombinations{combIdx}];
%                 newSets{end+1} = unique(newSet); %#ok<AGROW>
%             end
%         end
% 
%         % Update minimalRequirementSets with the expanded combinations
%         minimalRequirementSets = newSets;
%     end
% end
% 
function minimalRequirementMap = getMinimalRequiredCourseSets(allBucketCombinations)
% Generate a hash map for fast lookup of all valid minimal required course sets.

    % Initialize map with an empty set as a starting point
    minimalRequirementMap = containers.Map('KeyType','char','ValueType','logical');
    minimalRequirementMap('') = true;

    for bucketIndex = 1:length(allBucketCombinations)
        bucketCombinations = allBucketCombinations{bucketIndex};
        currentKeys = keys(minimalRequirementMap);
        newMap = containers.Map('KeyType','char','ValueType','logical');

        % Combine each existing key with each combination in this bucket
        for i = 1:length(currentKeys)
            existingKey = currentKeys{i};
            if isempty(existingKey)
                existingCourses = {};
            else
                existingCourses = strsplit(existingKey, ',');
            end

            for combIdx = 1:length(bucketCombinations)
                newSet = [existingCourses, bucketCombinations{combIdx}];
                newSet = unique(newSet);  % Ensure no duplicates
                newKey = strjoin(sort(newSet), ',');
                disp("here is new key");
                disp(newKey);
                newMap(newKey) = true;
            end
        end

        % Update the global map with combinations from this bucket
        minimalRequirementMap = newMap;
    end
end


