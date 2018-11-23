function tests = featureExtractionTests
tests = functiontests(localfunctions);
end

function setup(~)
end

function teardown(~)
end

function testKurtosis(testCase)
signal = single([3.4 , 7.1 , 1.5 , 8.6 , 4.9]);
output = myKurtosis(signal);
expected = kurtosis(signal);
testCase.verifyEqual(output,expected);
end

function testSkewness(testCase)
signal = single([3.4 , 7.1 , 1.5 , 8.6 , 4.9]);
expected = single(skewness(signal));
output = mySkewness(signal);
%testCase needs double to use tolerance
verifyEqual(testCase,double(output),double(expected),'AbsTol',1);
end
