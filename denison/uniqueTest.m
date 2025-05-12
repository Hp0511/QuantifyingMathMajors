function isUnique = areAllRowsUnique(nestedCellArray)
    % Check if each 1x6 cell row in a 84x1 cell array is unique
    % Input: nestedCellArray - 84x1 cell array, each with a 1x6 cell
    % Output: isUnique - true if all rows are unique, false otherwise

    if ~iscell(nestedCellArray) || length(nestedCellArray) ~= 84
        error('Input must be an 84x1 cell array.');
    end

    keys = strings(84, 1);

    for i = 1:84
        row = nestedCellArray{i};
        if ~iscell(row) || length(row) ~= 6
            error('Each row must be a 1x6 cell array.');
        end

        keys(i) = strjoin(string(row), '|');  % Flatten to a string key
    end

    uniqueKeys = unique(keys);
    isUnique = length(uniqueKeys) == length(keys);
end



isUnique = areAllRowsUnique(shortestPaths);