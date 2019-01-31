% Copyright (c) 2010, Zhiqiang Zhang
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

classdef Stack < handle
% CStack define a stack data strcuture
% 
% It likes java.util.Stack, however, it could use CStack.content() to
% return all the data (in cells) of the Stack, and it is a litter faster
% than java's Stack.
% 
%   s = CStack(c);  c is a cells, and could be omitted
%   s.size() return the numble of element
%   s.isempty() return true when the stack is empty
%   s.empty() delete the content of the stack
%   s.push(el) push el to the top of stack
%   s.pop() pop out the top of the stack, and return the element
%   s.top() return the top element of the stack
%   s.remove() remove all the elements in the stack
%   s.content() return all the data of the stack (in the form of a
%   cells with size [s.size(), 1]
%   
% See also CList, CQueue
%
% Copyright: zhang@zhiqiang.org, 2010.
% url: http://zhiqiang.org/blog/it/matlab-data-structures.html

    properties (Access = private)
        buffer 
        cur
        capacity 
    end
    
    methods
        function obj = Stack(c)
            if nargin >= 1 && iscell(c)
                obj.buffer = c(:);
                obj.cur = numel(c);
                obj.capacity = obj.cur;
            elseif nargin >= 1
                obj.buffer = cell(100, 1);
                obj.cur = 1;
                obj.capacity =100;
                obj.buffer{1} = c;
            else
                obj.buffer = cell(100, 1);
                obj.capacity = 100;
                obj.cur = 0;
            end
        end
        
        function s = size(obj)
            s = obj.cur;
        end
        
        function remove(obj)
            obj.cur = 0;
        end
        
        function b = empty(obj)
            b = obj.cur;
            obj.cur = 0;
        end
        
        function b = isempty(obj)            
            b = ~logical(obj.cur);
        end

        function push(obj, el)
            if obj.cur >= obj.capacity
                obj.buffer(obj.capacity+1:2*obj.capacity) = cell(obj.capacity, 1);
                obj.capacity = 2*obj.capacity;
            end
            obj.cur = obj.cur + 1;
            obj.buffer{obj.cur} = el;
        end
        
        function el = top(obj)
            if obj.cur == 0
                el = [];
                warning('CStack:No_Data', 'trying to get top element of an emtpy stack');
            else
                el = obj.buffer{obj.cur};
            end
        end
        
        function el = pop(obj)
            if obj.cur == 0
                el = [];
                warning('CStack:No_Data', 'trying to pop element of an emtpy stack');
            else
                el = obj.buffer{obj.cur};
                obj.cur = obj.cur - 1;
            end        
        end
        
        function c = content(obj)
            c = obj.buffer(1:obj.cur);
        end
    end
end