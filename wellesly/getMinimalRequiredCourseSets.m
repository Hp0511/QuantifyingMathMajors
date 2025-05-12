%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE ALL MINIMAL REQUIRED COURSE SETS FROM BUCKETS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minimalRequirementSets = getMinimalRequiredCourseSets(allBucketCombinations)
    % Initialize output with an empty starting set
    minimalRequirementSets = {{}};

    % Iterate over each bucket
    for bucketIndex = 1:length(allBucketCombinations)
        bucketCombinations = allBucketCombinations{bucketIndex};
        newSets = {}; % Temporary storage for new minimal requirement sets
        
        % Expand the minimal requirement sets with all choices from the current bucket
        for existingSetIdx = 1:length(minimalRequirementSets)
            existingSet = minimalRequirementSets{existingSetIdx};
            
            % Append each valid course combination from the bucket
            for combIdx = 1:length(bucketCombinations)
                newSet = [existingSet, bucketCombinations{combIdx}];
                newSets{end+1} = unique(newSet); 
            end
        end
        
        % Update minimalRequirementSets with the expanded combinations
        minimalRequirementSets = newSets;
    end
end



