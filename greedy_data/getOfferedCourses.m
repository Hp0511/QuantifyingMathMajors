%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get offerered Courses through our whole course schedules
% starting from the start term
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function totalCourseSet = getOfferedCourses(courseSchedules, startTerm)
    % Extract term names (excluding the first column)
    alltermNames = courseSchedules.Properties.VariableNames(2:end); % Skip the first column

    % Find the index of the start term
    startTermIndex = find(strcmp(alltermNames, startTerm), 1); % Find the column index of startTerm
    % for example S2021 would be 8 here
    if isempty(startTermIndex)
        error('Start term not found in course schedules.');
    end
    
    % Initialize an empty cell array for the total set of courses
    totalCourseSet = {};
    
    % Outer loop: Iterate over columns (startTermIndex to the last term)
    for col = startTermIndex+1:-1:2
        % Initialize an empty cell array for the current semester set
        semSet = {};
        
        % Inner loop: Iterate row-wise through the current column
        for row = 1:height(courseSchedules)
            % Check if the cell value is 1
            if courseSchedules{row, col} == 1
                % Get the course name from the first column
                courseName = courseSchedules{row, 1};
                semSet{end+1} = courseName; % Append to the semester set
            end
        end
        
        % Add the current semester set to the total set
        totalCourseSet{end+1} = semSet;
    end
end
