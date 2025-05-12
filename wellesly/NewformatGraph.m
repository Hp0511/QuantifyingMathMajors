%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create structures - Setup for algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Import data
importCoursePrereqs;  % coursePrereqs: Prerequisite structure
importCourseSchedules;      % courseSchedules: Schedule availability
importCollegeStructure;
importBuckets;        % bucketStruct: Bucket requirements

% Parse prerequisite structure into a directed graphz
course_prereq_pairs = [course_prereqs(:,1), course_prereqs(:,2)];
for ii = 3:length(course_prereqs(1,:))
    % Add extra prerequisites to the graph
    course_prereq_pairs = [course_prereq_pairs; ...
                           course_prereqs(:,1), course_prereqs(:,ii)];
end
clear ii;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial Processing With
% BUCKETS
% COURSE PREREQS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create graph for courses
courses = digraph(course_prereq_pairs(:,1), course_prereq_pairs(:,2));
courses = rmnode(courses, "");  % Remove empty string nodes
% plot(courses);

% Parse bucket structure
bucketStruct = parseBuckets(buckets);
%Getting all possible combination to satisfy the bucketStruct
allBucketCombinations = processBigBucket(bucketStruct);
minimalRequirementSet = getMinimalRequiredCourseSets(allBucketCombinations);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 1: pick start term (start with rightmost column of schedule structure)
startTerm = "F2021";
maxCourseperTerm = 4;
year = 4;

% Step 2: Get all possible course combinations for each term
dfsRoots = {};
totalOfferedCourseSet = getOfferedCourses(courseSchedules,startTerm);

% Step 3: Build a graph of all possible combinations
%get all the term names
termNames = flip(courseSchedules.Properties.VariableNames(2:end)); % Skip the first column F2021 F2024
disp(termNames);
[graph, nodetable, dfsRoots] = buildCombinationGraph(courses,termNames, totalOfferedCourseSet, maxCourseperTerm, year);
% plot(graph);
% Step 4: Perform DFS to find valid paths that satisfy all buckets
[legit,validPaths] = dfsFindValidPaths(graph, dfsRoots, nodetable, minimalRequirementSet);

%Step 5: Display valid Courses for checking
% [validCourses, allUnique] = extractValidCoursesBySemester(validPaths, nodetable);
validCourses = extractValidCoursesBySemester(validPaths, nodetable);
shortestPaths = findAllShortestValidCoursePaths(validCourses);

%Step6: Save results to a csv file
% Flatten shortestPaths into a uniform cell array of rows
results = cellfun(@(row) row(:)', shortestPaths, 'UniformOutput', false);  % Ensure row-wise formatting
results = vertcat(results{:});  % Convert to a 2D cell array (rows = paths, columns = semesters)

% Write to CSV
writecell(results, "results.csv");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DFS TO FIND ALL VALID PATHS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [legit,validPaths] = dfsFindValidPaths(graph, roots, nodeTable, minimalRequirementSets)
%     % Initialize variables
%     validPaths = {}; % Store valid paths that satisfy all bucket requirements
%     legit = {};
% 
%     % Perform DFS from each root
%     for i = 1:length(roots)
%         % Reset `visited` for each root to allow independent exploration
%         visited = containers.Map('KeyType', 'char', 'ValueType', 'logical');
% 
%         % Initialize a stack for DFS traversal (store node IDs as numeric values)
%         stack = {struct('node', str2double(roots{i}), 'path', {str2double(roots(i))})}; 
% 
%         % Perform iterative DFS
%         while ~isempty(stack)
%             % Pop the current state from the stack
%             currentState = stack{end};
%             stack(end) = [];
%             currentNode = currentState.node;
%             currentPath = currentState.path;
% 
%             % Mark the current node as visited
%             if isKey(visited, num2str(currentNode)) && visited(num2str(currentNode))
%                 continue;
%             end
%             visited(num2str(currentNode)) = true;
% 
%             % Extract the courses taken so far in the path
%             coursesTaken = extractCoursesFromPath(currentPath, nodeTable);
%             % **Early Bucket Check**: If the current path satisfies a minimal requirement, store it and stop exploring further
%             if checkMinimalRequirement(coursesTaken, minimalRequirementSets)
%                 validPaths{end+1} = currentPath;
%                 legit{end+1} = coursesTaken;
%                 continue; % Stop further exploration of this path
%             end
% 
%             % Get successors and continue DFS
%             neighbors = successors(graph, num2str(currentNode));
%             for j = 1:length(neighbors)
%                 stack{end+1} = struct('node', str2double(neighbors{j}), 'path', [currentPath, str2double(neighbors{j})]); 
%             end
%         end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DFS TO FIND ALL VALID PATHS WITH STATE-AWARE VISIT CHECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [legit, validPaths] = dfsFindValidPaths(graph, roots, nodeTable, minimalRequirementSets)
    validPaths = {}; 
    legit = {};

    for i = 1:length(roots)
        visited = containers.Map('KeyType', 'char', 'ValueType', 'logical');
        stack = {struct('node', str2double(roots{i}), 'path', {str2double(roots(i))})}; 

        while ~isempty(stack)
            currentState = stack{end};
            stack(end) = [];
            currentNode = currentState.node;
            currentPath = currentState.path;

            coursesTaken = extractCoursesFromPath(currentPath, nodeTable);
            sortedCourses = sort(coursesTaken);
            stateKey = sprintf('%s|%s', num2str(currentNode), strjoin(sortedCourses, ','));

            if isKey(visited, stateKey)
                continue;
            end
            visited(stateKey) = true;

            if checkMinimalRequirement(coursesTaken, minimalRequirementSets)
                validPaths{end+1} = currentPath;
                legit{end+1} = coursesTaken;
                continue;
            end

            neighbors = successors(graph, num2str(currentNode));
            for j = 1:length(neighbors)
                stack{end+1} = struct('node', str2double(neighbors{j}), 'path', [currentPath, str2double(neighbors{j})]); 
            end
        end
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK IF A PATH SATISFIES ANY MINIMAL REQUIREMENT SET
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isSatisfied = checkMinimalRequirement(coursesTaken, minimalRequirementSets)
    isSatisfied = any(cellfun(@(reqSet) isequal(sort(coursesTaken), sort(reqSet)), minimalRequirementSets));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRACT COURSES TAKEN FROM A PATH USING `nodeTable`
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function coursesTaken = extractCoursesFromPath(path, nodeTable)
    nodeIDs = string(nodeTable.ID);  % Convert table column to string array
    path = string(path);  % Ensure `path` elements are also strings
    coursesTaken = {};  % Initialize course storage

    for i = 1:length(path)
        nodeIdx = find(nodeIDs == path(i), 1);  % Find row in nodeTable
        if ~isempty(nodeIdx)
            courseList = strsplit(string(nodeTable.ClassCombination(nodeIdx)), '-');
            coursesTaken = unique([coursesTaken, courseList]); % Remove duplicates
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION TO EXTRACT VALID COURSES FROM VALID PATHS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function validCourses = extractValidCoursesBySemester(validPaths, nodeTable)
    numPaths = length(validPaths); % Total number of valid paths
    validCourses = cell(numPaths, 1); % Preallocate cell array for output

    for i = 1:numPaths
        path = validPaths{i}; % Get current path (sequence of node IDs)
        semesterCourses = cell(1, length(path)); % Initialize for each semester

        for j = 1:length(path)
            % Find the corresponding course combination in nodeTable
            nodeIdx = find(string(nodeTable.ID) == string(path(j)), 1);

            if ~isempty(nodeIdx)
                semesterCourses{j} = string(nodeTable.ClassCombination(nodeIdx)); % Store course combination
            else
                semesterCourses{j} = "UNKNOWN"; % Handle missing IDs
            end
        end

        % Store the semester-wise course sequence row-wise
        validCourses{i} = semesterCourses;
    end
end
% function [validCourses, allUnique] = extractValidCoursesBySemester(validPaths, nodeTable)
%     numPaths = length(validPaths); % Total number of valid paths
%     validCourses = cell(numPaths, 1); % Preallocate cell array for output
% 
%     for i = 1:numPaths
%         path = validPaths{i}; % Get current path (sequence of node IDs)
%         semesterCourses = cell(1, length(path)); % Initialize for each semester
% 
%         for j = 1:length(path)
%             % Find the corresponding course combination in nodeTable
%             nodeIdx = find(string(nodeTable.ID) == string(path(j)), 1);
% 
%             if ~isempty(nodeIdx)
%                 semesterCourses{j} = string(nodeTable.ClassCombination(nodeIdx)); % Store course combination
%             else
%                 semesterCourses{j} = "UNKNOWN"; % Handle missing IDs
%             end
%         end
% 
%         % Store the semester-wise course sequence row-wise
%         validCourses{i} = semesterCourses;
%     end
% 
%     % Convert validCourses to a format that allows uniqueness checking
%     % Flatten validCourses and convert to string format for comparison
%     validCoursesStr = cellfun(@(x) strjoin(x, ','), validCourses, 'UniformOutput', false);
% 
%     % Check if all elements are unique
%     allUnique = numel(validCoursesStr) == numel(unique(validCoursesStr));
% 
%     % Display a warning if duplicates are found
%     if ~allUnique
%         warning("Duplicate valid courses detected in the extracted schedules.");
%     end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION TO FIND ALL SHORTEST VALID COURSE PATHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function shortestPaths = findAllShortestValidCoursePaths(validCourses)
%     if isempty(validCourses)
%         shortestPaths = {}; % Return empty if no valid paths exist
%         return;
%     end
% 
%     % Calculate the number of semesters for each path
%     pathLengths = cellfun(@length, validCourses);
% 
%     % Find the minimum path length
%     minLength = min(pathLengths);
% 
%     % Extract all paths that have this minimum length
%     shortestPaths = validCourses(pathLengths == minLength);
% end
function shortestPaths = findAllShortestValidCoursePaths(validCourses)
    if isempty(validCourses)
        shortestPaths = {}; % Return empty if no valid paths exist
        return;
    end

    % Calculate the number of semesters for each path
    pathLengths = cellfun(@length, validCourses);

    % Find the minimum path length
    minLength = min(pathLengths);

    % Filter only the shortest paths
    candidatePaths = validCourses(pathLengths == minLength);
    shortestPaths = {}; % Initialize result

    for i = 1:length(candidatePaths)
        path = candidatePaths{i};  % A path is a 1 x N cell array, each element = 'CS100-Math130' format
        allCourses = [];

        for j = 1:length(path)
            semesterCourses = strsplit(path{j}, '-');
            allCourses = [allCourses, semesterCourses]; %#ok<AGROW>
        end

        % Remove whitespace and duplicates
        allCourses = strtrim(allCourses);
        if numel(allCourses) == numel(unique(allCourses))
            shortestPaths{end+1} = path; %#ok<AGROW> % Only add path if all courses are unique
        end
    end
end
