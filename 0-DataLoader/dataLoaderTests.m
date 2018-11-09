function tests = dataLoaderTests
tests = functiontests(localfunctions);
end

function setup(~)
end

function teardown(~)
end

function testCountMissingPoints(testCase)
ts = [30;40;50;60;80];
expectedOutput = uint32(1);

output = DataLoader.countMissingPoints(ts);
testCase.verifyEqual(output,expectedOutput);

end


function testMissingPoints(testCase)
ts = [30;40;50;60;90];
expectedOutput = [70,80];
output = DataLoader.findMissingPoints(ts);
testCase.verifyEqual(output,expectedOutput);
end
