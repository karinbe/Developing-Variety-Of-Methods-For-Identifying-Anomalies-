%--------------------------------------------------------------------------
% alfabeto = ['a' - 'z']
% The input mast contain numbers only. Otherwise, the value is converted to
% zero.
%--------------------------------------------------------------------------
function LZarray = LZ(data)

    global NUM_OF_RANGE
    NUM_OF_RANGE = 8;

    % Find out data size:
    [rows, columns] = size(data);
    
    rows = 30; % TODO delete!!!!!
    disp("rows = " + rows);
    
    LZarray = zeros(1, rows+1); % The array that the function return
    LZarrayCounter = zeros(1, rows);
    % Quantization level -
    % Convert our data to string:
%     columnStrTraining = cell(1,columns-1);

    n = 10; % Arbitrary selection of the amount of training data
    found = 1; % Training data - n first healthy
    countMode = 0;
    
     trainingDataArr = zeros(1,n); % Array that
     trainingDataCounter = 1;
    
    % Save in trainingDataArr the n healthy people:
    for i = 1:rows
        if data(i,columns) == 1
            trainingDataArr(trainingDataCounter) = i;
            trainingDataCounter = trainingDataCounter + 1;
            found = found + 1;   
        end
        if found > n
            break;
        end 
    end

    % Convert the training data to string:
    for i = 1:columns-1
        columnStrTraining = '';
        arrRange = cell(1,NUM_OF_RANGE); % range of the different cell's types TODO
        ascii = 97; % the small char 'a', helps to catalog cell's types
        
        trainingDataColumnArr = zeros(1,n); % Coantain 
        for index = 1:n % Each column has its own data
            trainingDataColumnArr(index) = data(trainingDataArr(index), i);
        end
       
        modeVal = mode(trainingDataColumnArr);
        
        if modeVal > min(trainingDataColumnArr) + 1
            countMode = countMode + 1;
            aveSend = mean(trainingDataColumnArr);
            stdevSend = std(trainingDataColumnArr);
            
            disp("aveSend: " + aveSend);
            disp("stdevSend: " + stdevSend);
            
            for r = 1:n
                arrRangeIndex = quantization(trainingDataColumnArr(r), aveSend, stdevSend); % indicator in arrArange
                if isempty(arrRange{arrRangeIndex})
                    arrRange{arrRangeIndex} = ascii;
                    ascii = ascii + 1;
                end
                columnStrTraining = strcat(columnStrTraining,char(arrRange{arrRangeIndex}));
            end
            for x = 1:NUM_OF_RANGE
                if isempty(arrRange{x})
                    arrRange{x} = ascii;
                    ascii = ascii + 1;
                end
            end
            
%             for o = 1:length(arrRange) % TODO
%                 disp(o+" " +char(arrRange{o}));
%             end
            
 
            % Next step - Dictionary

            % Variables for LZ78 Algorithm:
            dict = cell(1,n); % Dictionary
            fatherLocation = zeros(1,n);
            currentString = '';
            currentDictIndex = 1;

            % Build the dictionary:
            for p = 1:n
                currentString = strcat(currentString,columnStrTraining(p));
                index = isFound(currentString, dict, currentDictIndex);
                if index == 0 % If currentString isn't in the dictionary
                    dict(currentDictIndex) = {currentString};
                    currentDictIndex = currentDictIndex + 1;
                    currentString = '';
                else
                    fatherLocation(currentDictIndex) = index;
                end
            end
            
            % Finall dictionary, without empty cells ('dict' contains empty cells for efficiency):
            dictLen = currentDictIndex - 1;
            finallDict = cell(1,dictLen);
            for p = 1:currentDictIndex-1
                finallDict(p) = dict(p);
            end
            
            % Build & draw the tree:
            nodes = zeros(1,dictLen); % Each cell contain the location of str(i) father + 1
            for x = 1:dictLen
                nodes(x+1) = fatherLocation(x) + 1;
            end

            lzTree = {dictLen}; % Contain the finall tree
            for p = 1:dictLen
                loc = 1;
                value = char(finallDict(p));
                for x = 1:dictLen
                    lengthI = length(char(finallDict(p)));
                    lengthJ = length(char(finallDict(x)));
                    if (lengthJ < lengthI) || (lengthJ == lengthI && nodes(x+1) < nodes(p+1)) || (lengthJ == lengthI && nodes(x+1) == nodes(p+1) && x < p)
                        loc = loc + 1;
                    end
                end

                lzTree(loc) = {value};
            end
            
            disp(lzTree);
            
            % Next step - Search:
            j = 1;
            place = 1;
            while j <= rows
%                 disp("j: " + j + ", trainingDataArr(place): " + trainingDataArr(place)+" P" +place);
                if place < n && j == trainingDataArr(place)
                    j = j + 1;
                    place = place + 1;
                
                else
                    arrRangeIndex = quantization(data(j,i), aveSend, stdevSend); % indicator in arrArange
                    stringToSearch = char(arrRange{arrRangeIndex});
                    disp("stringToSearch : " + stringToSearch);
                    if ~ismember(stringToSearch , lzTree)
                        LZarrayCounter(j) = LZarrayCounter(j) + 1;
                        %disp(i + ": '" + stringToSearch + "' is Anomaly.");
                    end
                    
                    j = j + 1;
                end
            end
            
            
            
        end

  
    end
    
    for x = 1:rows
        if LZarrayCounter(x) >= countMode-1
            LZarray(x+1) = 1;
        end
    end
    
%     for x = 1:30
%         disp(LZarrayCounter(x)+ " vs " + LZarray(x));
%     end
    
end

% -------------------------------------------------------------------------
% Function that get a string, array of strings and the size of the array
% and check if the string appears inside the array or not.
% If so, return the index. Otherwise, return zero.
function fatherIndex = isFound(currentString, dict, currentDictIndex)
    for i = 1:currentDictIndex
        if strcmp(currentString,dict(i))
            fatherIndex = i;
            return
        end
    end
    fatherIndex = 0;
end

% -------------------------------------------------------------------------
function index = quantization(number, ave, stdev)
    global NUM_OF_RANGE
    NUM_OF_RANGE = 8;
    range = 2 * stdev / NUM_OF_RANGE;

    if number < ave - stdev
        index = 1;
    elseif number >= ave - stdev && number < ave - stdev + range
        index = 2;
    elseif number >= ave - stdev + range && number < ave - stdev + (2 * range)
        index = 3;
    elseif number >= ave - stdev + (2 * range) && number < ave - stdev + (3 * range)
        index = 4;
    elseif number >= ave - stdev + (3 * range)  && number < ave - stdev + (4 * range)
        index = 5;
    elseif number >= ave - stdev + (4 * range) && number < ave - stdev + (5 * range)
        index = 6;
    elseif number >= ave - stdev + (5 * range)  && number < ave - stdev + (6 * range)
        index = 7;
    else % number >= ave - stdev + (6 * range
        index = 8;
    end
end
