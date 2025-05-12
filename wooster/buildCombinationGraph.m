% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Graph building
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % function [graph, nodeTable, roots] = buildCombinationGraph(courses, termNames, totalOfferedCourseSet, maxCourses, year)
% %     % Create a directed graph (only stores node IDs and edges)
% %     graph = digraph();
% % 
% %     % Initialize table for storing node attributes
% %     nodeTable = table([], {}, {}, 'VariableNames', {'ID', 'ClassCombination', 'Term'}); 
% % 
% %     % Map to track unique nodes 
% %     nodeMap = containers.Map('KeyType', 'char', 'ValueType', 'char');
% % 
% %     prevNodes = {}; % Nodes from the previous term
% %     roots = {}; % Store root nodes explicitly
% %     nodeCounter = 1; % Unique node ID counter
% % 
% %     % Generate root nodes (combinations for the first term)
% %     firstTermCombinations = getFirstTermCourses(courses, totalOfferedCourseSet, maxCourses);
% %     % Add first-term nodes to the graph
% %     for i = 1:length(firstTermCombinations)
% %         combination = firstTermCombinations{i};
% %         term = termNames{1};
% %         classCombination = strjoin(combination, '-');
% %         nodeKey = strcat(classCombination, '-', term); % Unique key for the node
% % 
% %         % Check if node already exists
% %         if isKey(nodeMap, nodeKey)
% %             nodeId = nodeMap(nodeKey); % Use existing node ID
% %         else
% %             nodeId = num2str(nodeCounter); % Generate new node ID
% %             graph = addnode(graph, nodeId); % Add node to graph
% % 
% %             % Store node properties
% %             newNode = table({nodeId}, {classCombination}, {term}, ...
% %                             'VariableNames', {'ID', 'ClassCombination', 'Term'});
% %             nodeTable = [nodeTable; newNode];
% % 
% %             % Store in nodeMap to prevent duplicates
% %             nodeMap(nodeKey) = nodeId;
% %             nodeCounter = nodeCounter + 1;
% %         end
% % 
% %         prevNodes{end+1} = struct('id', nodeId, 'courses', combination, 'term', term);
% %         roots{end+1} = nodeId;
% %     end
% % 
% %     % Iteratively add nodes for subsequent terms
% %     for termIndex = 2:min(year * 2, numel(termNames))
% %         newNodes = {}; % Nodes for the current term
% %         term = termNames{termIndex}; % Get term name
% % 
% %         % Generate combinations for the current term based on prevNodes
% %         for i = 1:length(prevNodes)
% %             takenCourses = prevNodes{i}.courses; % Courses already taken
% %             nextCombinations = getNextTermCourses(courses, totalOfferedCourseSet, termIndex, takenCourses, maxCourses);
% % 
% %             for j = 1:length(nextCombinations)
% %                 nextCombination = nextCombinations{j};
% %                 disp("Here is next Combination");
% %                 disp(nextCombination);
% %                 disp("Here are taken Courses");
% %                 disp(takenCourses);
% % 
% %                 nextCombination = setdiff(nextCombination,takenCourses);
% %                 disp("difference");
% %                 disp(nextCombination);
% %                 overlappingCourses = intersect(nextCombination, takenCourses);
% %                 if ~isempty(overlappingCourses)
% %                     disp("Overlapping Courses Detected:");
% %                     disp(overlappingCourses);
% %                     break;
% %                 end
% %                 classCombination = strjoin(nextCombination, '-');
% %                 nodeKey = strcat(classCombination, '-', term); % Unique key for the node
% % 
% %                 % Check if node already exists
% %                 if isKey(nodeMap, nodeKey)
% %                     nodeId = nodeMap(nodeKey); % Use existing node ID
% %                 else
% %                     nodeId = num2str(nodeCounter);
% %                     graph = addnode(graph, nodeId);
% % 
% %                     % Store node properties
% %                     newNode = table({nodeId}, {classCombination}, {term}, ...
% %                                     'VariableNames', {'ID', 'ClassCombination', 'Term'});
% %                     nodeTable = [nodeTable; newNode];
% % 
% %                     % Store in nodeMap to prevent duplicates
% %                     nodeMap(nodeKey) = nodeId;
% %                     nodeCounter = nodeCounter + 1;
% %                 end
% %                 nodeId = num2str(nodeCounter);
% %                 graph = addnode(graph, nodeId);
% % 
% %                 % Store node properties
% %                 newNode = table({nodeId}, {classCombination}, {term}, ...
% %                                 'VariableNames', {'ID', 'ClassCombination', 'Term'});
% %                 nodeTable = [nodeTable; newNode];
% % 
% %                 % Store in nodeMap to prevent duplicates
% %                 nodeMap(nodeKey) = nodeId;
% %                 nodeCounter = nodeCounter + 1;
% %                 % Add edge from previous node to the current node (only if it does not exist)
% %                 if ~ismember(nodeId, successors(graph, prevNodes{i}.id))
% %                     graph = addedge(graph, prevNodes{i}.id, nodeId);
% %                 end
% % 
% %                 % Track the node for the next iteration
% %                 % Inside buildCombinationGraph where newNodes are tracked
% %                 newCourses = unique([takenCourses, nextCombination]); % Prevent duplicate courses
% %                 % Store new node
% %                 newNodes{end+1} = struct('id', nodeId, 'courses', newCourses, 'term', term);
% %                 disp(newNodes{i});
% %             end
% %         end
% % 
% %         % Update previous nodes for the next term
% %         prevNodes = newNodes;
% %     end
% % end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % BUILD COMBINATION GRAPH - REUSED NODES FOR SAME COMBO+TERM
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [graph, nodeTable, roots] = buildCombinationGraph(courses, termNames, totalOfferedCourseSet, maxCourses, year)
%     graph = digraph();
%     nodeTable = table([], {}, {}, 'VariableNames', {'ID', 'ClassCombination', 'Term'}); 
%     nodeMap = containers.Map('KeyType', 'char', 'ValueType', 'char');
%     prevNodes = {}; 
%     roots = {}; 
%     nodeCounter = 1; 
% 
%     firstTermCombinations = getFirstTermCourses(courses, totalOfferedCourseSet, maxCourses);
%     for i = 1:length(firstTermCombinations)
%         combination = firstTermCombinations{i};
%         term = termNames{1};
%         classCombination = strjoin(sort(combination), '-');
%         nodeKey = strcat(classCombination, '-', term);
% 
%         % if isKey(nodeMap, nodeKey)
%         %     nodeId = nodeMap(nodeKey);
%         % else
%         %     nodeId = num2str(nodeCounter);
%         %     graph = addnode(graph, nodeId);
%         %     newNode = table({nodeId}, {classCombination}, {term}, 'VariableNames', {'ID', 'ClassCombination', 'Term'});
%         %     nodeTable = [nodeTable; newNode];
%         %     nodeMap(nodeKey) = nodeId;
%         %     nodeCounter = nodeCounter + 1;
%         % end
%         nodeId = num2str(nodeCounter);
%         graph = addnode(graph, nodeId);
%         newNode = table({nodeId}, {classCombination}, {term}, 'VariableNames', {'ID', 'ClassCombination', 'Term'});
%         nodeTable = [nodeTable; newNode];
%         nodeMap(nodeKey) = nodeId;
%         nodeCounter = nodeCounter + 1;
% 
%         prevNodes{end+1} = struct('id', nodeId, 'courses', combination, 'term', term);
%         roots{end+1} = nodeId;
%     end
% 
%     for termIndex = 2:min(year * 2, numel(termNames))
%         newNodes = {}; 
%         term = termNames{termIndex}; 
% 
%         for i = 1:length(prevNodes)
%             takenCourses = prevNodes{i}.courses; 
%             nextCombinations = getNextTermCourses(courses, totalOfferedCourseSet, termIndex, takenCourses, maxCourses);
% 
%             for j = 1:length(nextCombinations)
%                 nextCombination = setdiff(nextCombinations{j}, takenCourses);
%                 if isempty(nextCombination)
%                     continue;
%                 end
%                 classCombination = strjoin(sort(nextCombination), '-');
%                 nodeKey = strcat(classCombination, '-', term);
% 
%                 if isKey(nodeMap, nodeKey)
%                     nodeId = nodeMap(nodeKey);
%                 else
%                     nodeId = num2str(nodeCounter);
%                     graph = addnode(graph, nodeId);
%                     newNode = table({nodeId}, {classCombination}, {term}, 'VariableNames', {'ID', 'ClassCombination', 'Term'});
%                     nodeTable = [nodeTable; newNode];
%                     nodeMap(nodeKey) = nodeId;
%                     nodeCounter = nodeCounter + 1;
%                 end
% 
%                 if ~ismember(nodeId, successors(graph, prevNodes{i}.id))
%                     graph = addedge(graph, prevNodes{i}.id, nodeId);
%                 end
% 
%                 newCourses = unique([takenCourses, nextCombination]);
%                 newNodes{end+1} = struct('id', nodeId, 'courses', newCourses, 'term', term);
%             end
%         end
% 
%         prevNodes = newNodes;
%     end
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % GENERATE COURSE COMBINATIONS FOR FIRST TERM
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
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % GENERATE COURSE COMBINATIONS FOR SUBSEQUENT TERMS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function nextTermCourseCombinations = getNextTermCourses(courses, totalOfferedCourseSet, TermIndex, allTakenCourses, maxCourses)
%     offeredCoursesNextTerm = string(totalOfferedCourseSet{TermIndex});
%     % Initialize the list of valid courses
%     validCoursesNextTerm = [];
% 
%     % Check each course offered in the next term
%     for i = 1:length(offeredCoursesNextTerm)
%         course = offeredCoursesNextTerm(i); % Current course to validate
%         % Map the course name to its numeric index
%         courseID = findnode(courses, course);
%         % Find the prerequisites of this course (successors in the graph) 
%         % Only work in nodeID
%         prereqIDs = successors(courses, courseID);
%         % Convert prerequisite IDs to names
%         prereqNames = string(courses.Nodes.Name(prereqIDs)); %courses.Node.Name is a cell array
%         % Check if all prerequisites are in the taken courses
%         if all(ismember(prereqNames, allTakenCourses))
%             validCoursesNextTerm = [validCoursesNextTerm; course]; % Add to valid courses
%         end
% 
%     end
% 
%     validCoursesNextTerm = setdiff(validCoursesNextTerm, allTakenCourses);
%     % Generate all possible subsets of valid courses (up to maxCourses)
%     nextTermCourseCombinations = {};
%     for numCourses = 1:min(maxCourses, length(validCoursesNextTerm))
%         combos = nchoosek(validCoursesNextTerm, numCourses); % Generate subsets
%         for i = 1:size(combos, 1)
%             nextTermCourseCombinations{end + 1} = combos(i, :); % Add each combination
%         end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph building
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [graph, nodeTable, roots] = buildCombinationGraph(courses, termNames, totalOfferedCourseSet, maxCourses, year)
%     % Create a directed graph (only stores node IDs and edges)
%     graph = digraph();
% 
%     % Initialize table for storing node attributes
%     nodeTable = table([], {}, {}, 'VariableNames', {'ID', 'ClassCombination', 'Term'}); 
% 
%     % Map to track unique nodes 
%     nodeMap = containers.Map('KeyType', 'char', 'ValueType', 'char');
% 
%     prevNodes = {}; % Nodes from the previous term
%     roots = {}; % Store root nodes explicitly
%     nodeCounter = 1; % Unique node ID counter
% 
%     % Generate root nodes (combinations for the first term)
%     firstTermCombinations = getFirstTermCourses(courses, totalOfferedCourseSet, maxCourses);
%     % Add first-term nodes to the graph
%     for i = 1:length(firstTermCombinations)
%         combination = firstTermCombinations{i};
%         term = termNames{1};
%         classCombination = strjoin(combination, '-');
%         nodeKey = strcat(classCombination, '-', term); % Unique key for the node
% 
%         % Check if node already exists
%         if isKey(nodeMap, nodeKey)
%             nodeId = nodeMap(nodeKey); % Use existing node ID
%         else
%             nodeId = num2str(nodeCounter); % Generate new node ID
%             graph = addnode(graph, nodeId); % Add node to graph
% 
%             % Store node properties
%             newNode = table({nodeId}, {classCombination}, {term}, ...
%                             'VariableNames', {'ID', 'ClassCombination', 'Term'});
%             nodeTable = [nodeTable; newNode];
% 
%             % Store in nodeMap to prevent duplicates
%             nodeMap(nodeKey) = nodeId;
%             nodeCounter = nodeCounter + 1;
%         end
% 
%         prevNodes{end+1} = struct('id', nodeId, 'courses', combination, 'term', term);
%         roots{end+1} = nodeId;
%     end
% 
%     % Iteratively add nodes for subsequent terms
%     for termIndex = 2:min(year * 2, numel(termNames))
%         newNodes = {}; % Nodes for the current term
%         term = termNames{termIndex}; % Get term name
% 
%         % Generate combinations for the current term based on prevNodes
%         for i = 1:length(prevNodes)
%             takenCourses = prevNodes{i}.courses; % Courses already taken
%             nextCombinations = getNextTermCourses(courses, totalOfferedCourseSet, termIndex, takenCourses, maxCourses);
% 
%             for j = 1:length(nextCombinations)
%                 nextCombination = nextCombinations{j};
%                 disp("Here is next Combination");
%                 disp(nextCombination);
%                 disp("Here are taken Courses");
%                 disp(takenCourses);
% 
%                 nextCombination = setdiff(nextCombination,takenCourses);
%                 disp("difference");
%                 disp(nextCombination);
%                 overlappingCourses = intersect(nextCombination, takenCourses);
%                 if ~isempty(overlappingCourses)
%                     disp("Overlapping Courses Detected:");
%                     disp(overlappingCourses);
%                     break;
%                 end
%                 classCombination = strjoin(nextCombination, '-');
%                 nodeKey = strcat(classCombination, '-', term); % Unique key for the node
% 
%                 % Check if node already exists
%                 if isKey(nodeMap, nodeKey)
%                     nodeId = nodeMap(nodeKey); % Use existing node ID
%                 else
%                     nodeId = num2str(nodeCounter);
%                     graph = addnode(graph, nodeId);
% 
%                     % Store node properties
%                     newNode = table({nodeId}, {classCombination}, {term}, ...
%                                     'VariableNames', {'ID', 'ClassCombination', 'Term'});
%                     nodeTable = [nodeTable; newNode];
% 
%                     % Store in nodeMap to prevent duplicates
%                     nodeMap(nodeKey) = nodeId;
%                     nodeCounter = nodeCounter + 1;
%                 end
%                 nodeId = num2str(nodeCounter);
%                 graph = addnode(graph, nodeId);
% 
%                 % Store node properties
%                 newNode = table({nodeId}, {classCombination}, {term}, ...
%                                 'VariableNames', {'ID', 'ClassCombination', 'Term'});
%                 nodeTable = [nodeTable; newNode];
% 
%                 % Store in nodeMap to prevent duplicates
%                 nodeMap(nodeKey) = nodeId;
%                 nodeCounter = nodeCounter + 1;
%                 % Add edge from previous node to the current node (only if it does not exist)
%                 if ~ismember(nodeId, successors(graph, prevNodes{i}.id))
%                     graph = addedge(graph, prevNodes{i}.id, nodeId);
%                 end
% 
%                 % Track the node for the next iteration
%                 % Inside buildCombinationGraph where newNodes are tracked
%                 newCourses = unique([takenCourses, nextCombination]); % Prevent duplicate courses
%                 % Store new node
%                 newNodes{end+1} = struct('id', nodeId, 'courses', newCourses, 'term', term);
%                 disp(newNodes{i});
%             end
%         end
% 
%         % Update previous nodes for the next term
%         prevNodes = newNodes;
%     end
% end
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
% function nextTermCourseCombinations = getNextTermCourses(courses, totalOfferedCourseSet, TermIndex, allTakenCourses, maxCourses)
%     offeredCoursesNextTerm = string(totalOfferedCourseSet{TermIndex});
%     % Initialize the list of valid courses
%     validCoursesNextTerm = [];
% 
%     % Check each course offered in the next term
%     for i = 1:length(offeredCoursesNextTerm)
%         course = offeredCoursesNextTerm(i); % Current course to validate
%         % Map the course name to its numeric index
%         courseID = findnode(courses, course);
%         % Find the prerequisites of this course (successors in the graph) 
%         % Only work in nodeID
%         prereqIDs = successors(courses, courseID);
%         % Convert prerequisite IDs to names
%         prereqNames = string(courses.Nodes.Name(prereqIDs)); %courses.Node.Name is a cell array
%         % Check if all prerequisites are in the taken courses
%         if all(ismember(prereqNames, allTakenCourses))
%             validCoursesNextTerm = [validCoursesNextTerm; course]; % Add to valid courses
%         end
% 
%     end
% 
%     validCoursesNextTerm = setdiff(validCoursesNextTerm, allTakenCourses);
%     % Generate all possible subsets of valid courses (up to maxCourses)
%     nextTermCourseCombinations = {};
%     for numCourses = 1:min(maxCourses, length(validCoursesNextTerm))
%         combos = nchoosek(validCoursesNextTerm, numCourses); % Generate subsets
%         for i = 1:size(combos, 1)
%             nextTermCourseCombinations{end + 1} = combos(i, :); % Add each combination
%         end
%     end
% end

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
