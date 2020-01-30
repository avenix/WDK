
classdef AchievementsComponent < Algorithm
    
    properties (Access = public)
        achievements;
        observers;
        notifyOnce;
    end
    
    methods (Access = public)
        function obj = AchievementsComponent(achievements)
            obj.name = 'achievementsComponent';
            obj.inputPort = DataType.kAny;
            obj.outputPort = DataType.kAny;
            obj.achievements = achievements;
            obj.notifyOnce = false;
        end
        
        %receives an array of instances of ClassificationResult
        function output = compute(obj,results)
            
            output = [];
            
            for achievementIdx = 1 : length(obj.achievements)
                
                achievement = obj.achievements(achievementIdx);
                
                for resultIdx = 1 : length(results)
                    
                    result = results(resultIdx);
                    
                    obj.testAchievement(achievement,result)
                   
                end
            end
        end
        
        function testAchievement(obj,achievement,result)
            
            if isa(result,'ClassificationResult')
                obj.testAchievementWithResults(achievement,result.predictedClasses);
            else
                obj.testAchievementWithResults(achievement,result.predictedResults);
            end
        end
        
        function testAchievementWithResults(obj,achievement,results)
            for i = 1 : length(results)
                
                predictedClass = results(i);
                
                if (achievement.testAchievement(predictedClass))
                    obj.notifyObservers(achievement);
                    if(obj.notifyOnce)
                            return;
                    end
                end
            end
        end
        
        function addObserver(obj,observer)
            obj.observers{end+1} = observer;
        end
        
    end
    
    methods (Access = private)
        function notifyObservers(obj,achievement)
            
            for i = 1 : length(obj.observers)
                observer = obj.observers{i};
                observer(achievement);
            end
        end
    end
end