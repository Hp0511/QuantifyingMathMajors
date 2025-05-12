%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph building
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD COMBINATION GRAPH - REUSED NODES FOR SAME COMBO+TERM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [graph, nodeTable, roots] = buildCombinationGraph(courses, termNames, totalOfferedCourseSet, maxCourses, year)
    graph = digraph();
    nodeTable = table([], {}, {}, 'VariableNames', {'ID', 'ClassCombination', 'Term'}); 
    nodeMap = containers.Map('KeyType', 'char', 'ValueType', 'char');
    prevNodes = {}; 
    roots = {}; 
    nodeCounter = 1; 

    firstTermCombinations = getFirstTermCourses(courses, totalOfferedCourseSet, maxCourses);
    disp(firstTermCombinations);
    for i = 1:length(firstTermCombinations)
        combination = firstTermCombinations{i};
        term = termNames{1};
        classCombination = strjoin(sort(combination), '-');
        nodeKey = strcat(classCombination, '-', term);

        if isKey(nodeMap, nodeKey)
            nodeId = nodeMap(nodeKey);
        else
            nodeId = num2str(nodeCounter);
            graph = addnode(graph, nodeId);
            newNode = table({nodeId}, {classCombination}, {term}, 'VariableNames', {'ID', 'ClassCombination', 'Term'});
            nodeTable = [nodeTable; newNode];
            nodeMap(nodeKey) = nodeId;
            nodeCounter = nodeCounter + 1;
        end 

        prevNodes{end+1} = struct('id', nodeId, 'courses', combination, 'term', term);
        roots{end+1} = nodeId;
    end

    for termIndex = 2:min(year * 2, numel(termNames))
        newNodes = {}; 
        term = termNames{termIndex}; 

        for i = 1:length(prevNodes)
            takenCourses = prevNodes{i}.courses; 
            nextCombinations = getNextTermCourses(courses, totalOfferedCourseSet, termIndex, takenCourses, maxCourses);
            for j = 1:length(nextCombinations)
                nextCombination = setdiff(nextCombinations{j}, takenCourses);
                if isempty(nextCombination)
                    continue;
                end
                classCombination = strjoin(sort(nextCombination), '-');
                nodeKey = strcat(classCombination, '-', term);

                if isKey(nodeMap, nodeKey)
                    nodeId = nodeMap(nodeKey);
                else
                    nodeId = num2str(nodeCounter);
                    graph = addnode(graph, nodeId);
                    newNode = table({nodeId}, {classCombination}, {term}, 'VariableNames', {'ID', 'ClassCombination', 'Term'});
                    nodeTable = [nodeTable; newNode];
                    nodeMap(nodeKey) = nodeId;
                    nodeCounter = nodeCounter + 1;
                end

                if ~ismember(nodeId, successors(graph, prevNodes{i}.id))
                    graph = addedge(graph, prevNodes{i}.id, nodeId);
                end

                newCourses = unique([takenCourses(:)', nextCombination(:)']);
                newNodes{end+1} = struct('id', nodeId, 'courses', newCourses, 'term', term);
            end
        end

        prevNodes = newNodes;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE COURSE COMBINATIONS FOR FIRST TERM
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function courseCombinations = getFirstTermCourses(courses, totalOfferedCourseSet, maxCourses)
%     noPrereqs = string(courses.Nodes.Name(outdegree(courses) == 0));
%     % Courses offered in the first semester
%     offeredCoursesFirstTerm = string(totalOfferedCourseSet{1});
%     % Filter courses with no prerequisites that are also offered in the first term
%     validCoursesFirstTerm = intersect(noPrereqs, offeredCoursesFirstTerm);
% 
%     % Generate all possible subsets of valid courses (up to maxCourses)
%     courseCombinations = {};
%     for numCourses = 1:min(maxCourses, length(validCoursesFirstTerm))
%         combos = nchoosek(validCoursesFirstTerm, numCourses); % Generate subsets
%         for i = 1:size(combos, 1)
%             courseCombinations{end + 1} = combos(i, :);
%         end
%     end
%     disp(courseCombinations);
% end

%Take the most course in the first semester as possible
function courseCombinations = getFirstTermCourses(courses, totalOfferedCourseSet, maxCourses)
    % Find courses with no prerequisites
    noPrereqs = string(courses.Nodes.Name(outdegree(courses) == 0));

    % Courses offered in the first semester
    offeredCoursesFirstTerm = string(totalOfferedCourseSet{1});

    % Valid courses: no prerequisites + offered in this term
    validCoursesFirstTerm = intersect(noPrereqs, offeredCoursesFirstTerm);

    % Limit to maximum allowed per term
    maxToTake = min(maxCourses, length(validCoursesFirstTerm));

    % Greedy: take the biggest possible combination but output as a cell of course arrays
    if maxToTake > 0
        courseCombinations = {validCoursesFirstTerm(1:maxToTake)}; % keep in { ... } format
    else
        courseCombinations = {};  % No valid courses
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE COURSE COMBINATIONS FOR SUBSEQUENT TERMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nextTermCourseCombinations = getNextTermCourses(courses, totalOfferedCourseSet, TermIndex, allTakenCourses, maxCourses)
    offeredCoursesNextTerm = string(totalOfferedCourseSet{TermIndex});
    validCoursesNextTerm = [];

    % Validate each course offered in the next term
    for i = 1:length(offeredCoursesNextTerm)
        course = offeredCoursesNextTerm(i);
        courseID = findnode(courses, course);
        prereqIDs = successors(courses, courseID); % Prerequisites
        prereqNames = string(courses.Nodes.Name(prereqIDs));

        % If all prerequisites satisfied, mark course as valid
        if all(ismember(prereqNames, allTakenCourses))
            validCoursesNextTerm = [validCoursesNextTerm; course];
        end
    end

    % Remove courses already taken
    validCoursesNextTerm = setdiff(validCoursesNextTerm, allTakenCourses);
    % Initialize output
    nextTermCourseCombinations = {};

    % If there are valid courses to take
    if ~isempty(validCoursesNextTerm)
        maxToTake = min(maxCourses, length(validCoursesNextTerm));

        if length(validCoursesNextTerm) > maxToTake
            % Only consider combinations at the maximum course load
            combos = nchoosek(validCoursesNextTerm, maxToTake);
            for i = 1:size(combos, 1)
                nextTermCourseCombinations{end + 1} = combos(i, :);
            end
        else
            nextTermCourseCombinations = {validCoursesNextTerm(:)'}; 
        end
    end
end
