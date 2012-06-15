function [Ynorm, Ymean] = normalizeRatings(Y, R)
%   normalizeRatings Preprocess data by subtracting mean rating for every movie
%   [Ynorm, Ymean] = normalizeRatings(Y, R) normalizes the rating database Y, so that each movie
%   has a rating of 0 on average, and returns the mean rating in Ymean.


[m, n] = size(Y);
Ymean = zeros(m, 1);
Ynorm = zeros(size(Y));
for i = 1:m
    Ymean(i) = mean(Y(i, R(i, :)));
    Ynorm(i, R(i, :)) = Y(i, R(i, :)) - Ymean(i);
end

end
