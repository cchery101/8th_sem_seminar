% recommender systems using collaborative filtering


fprintf('\n\nLoading movie ratings dataset...');
%  Load data
load ('ex8_movies.mat');
fprintf('\n\nSuccessfully loaded movie ratings database...\n\n');
%  Y is a 1682x943 matrix, containing ratings (1-5) of 1682 movies on 
%  943 users. you are not one among these users.
%
%  R is a 1682x943 matrix, where R(i,j) = 1 if and only if user j gave a
%  rating to movie i
fprintf('\n\nProgram paused. Press enter to continue.\n');
pause;


movieList = loadMovieList();


while 1

fprintf('\n\n1: See current average movie ratings \n2: Run collaborative filtering \n3: Exit program \n\n');
choice = input('Enter your choice:  ');

if choice==1

%  compute average rating
fprintf('\n\n');
num = input('Enter the id of the movie whose average rating you wish to see:  ');
fprintf('Average rating for movie %d (%s) : %f / 5\n\n', num, movieList{num}, mean(Y(num, R(num, :))));

%end	% end of if choice==1

fprintf('\nProgram paused. Press enter to continue.\n');
pause;


elseif choice == 2
fprintf('\n\nBefore we begin to train the collaborative filtering model, please enter the movie ratings for the new user(optional)...\n\n');
%% ============== Entering ratings for a new user ===============
%  Before we train the collaborative filtering model, we will first
%  add ratings that correspond to a new user

movieList = loadMovieList();	% movieList{} is a cell array which contains names of all movies

%  Initialize my ratings to all zeroes
my_ratings = zeros(1682, 1);


while 1
	% the new user need not rate any movies at all
	more = input('Want to rate some movies ? [Y/N] :  ','s');
	if upper(more)=='N'
		break;
	end
	fprintf('\n\n');
	n = input('Enter the id of the movie you wish to rate:  ');
	fprintf('\n\nEnter your rating for movie %d (%s) on a scale of 1-5 : ', n, movieList{n});
	r = input(' ');
	if r<0 || r>5
		fprintf('\n\nERROR : The rating should be on the scale of 1-5 only\n\n');
		continue;
	end
	my_ratings(n)= r;
end	% end of while 1

% Print the ratings that were just entered by the new user
fprintf('\n\nNew user ratings:\n');
for i = 1:length(my_ratings)
    if my_ratings(i) > 0 
        fprintf('Rated %d for %s\n', my_ratings(i), movieList{i});
    end
end


fprintf('\nProgram paused. Press enter to continue.\n');
pause;


%% ================== Learning Movie Ratings ====================
%  Training the collaborative filtering model on a movie rating 
%  dataset of 1682 movies and 943 users

fprintf('\nTraining collaborative filtering model...\n');

%  Load data
load('ex8_movies.mat');

%  Y is a 1682x943 matrix, containing ratings (1-5) of 1682 movies by 
%  943 users
%
%  R is a 1682x943 matrix, where R(i,j) = 1 if and only if user j gave a
%  rating to movie i

%  Add movie ratings by new user to the data matrix
Y = [my_ratings Y];
R = [(my_ratings ~= 0) R];

%  Normalize Ratings
[Ynorm, Ymean] = normalizeRatings(Y, R);

%  initialize useful Values
num_users = size(Y, 2);
num_movies = size(Y, 1);
num_features = 10;

% Set Initial Parameters (Theta, X) -- random initialization
X = randn(num_movies, num_features);
Theta = randn(num_users, num_features);
initial_parameters = [X(:); Theta(:)];

% Set options for fmincg(built-in optimization function)
options = optimset('GradObj', 'on', 'MaxIter', 150);

% Set Regularization parameter lambda
lambda = 10;
theta = fmincg (@(t)(cofiCostFunc(t, Y, R, num_users, num_movies, num_features, lambda)), initial_parameters, options);

% Unfold the returned theta back into U and W
X = reshape(theta(1:num_movies*num_features), num_movies, num_features);
Theta = reshape(theta(num_movies*num_features+1:end), num_users, num_features);

fprintf('Recommender system learning completed...\n');


fprintf('\nProgram paused. Press enter to continue.\n');
pause;


%% ================== Recommendation for new user ====================
%  After training the model, make recommendations by computing
%  the predictions matrix

p = X * Theta';

% The ratings database was normalized earlier by subtracting the mean. 
% So, now add back the mean to make it non-normalized
my_predictions = p(:,1) + Ymean;

movieList = loadMovieList();

[r, ix] = sort(my_predictions, 'descend');
fprintf('\n\nTop 10 movie recommendations for you:\n\n');
for i=1:10
    j = ix(i);
    fprintf('Predicting rating %.1f for movie %s\n', my_predictions(j), movieList{j});
end

fprintf('\n\nOriginal ratings provided:\n');
for i = 1:length(my_ratings)
    if my_ratings(i) > 0 
        fprintf('Rated %d for %s\n', my_ratings(i), movieList{i});
    end
end


%end	% end of if choice==2


elseif choice==3
	quit;
	
else
	fprintf('\n\nInvalid choice. Please try again...\n\n');	
end	% end of if stmt

end	% end of while 1
