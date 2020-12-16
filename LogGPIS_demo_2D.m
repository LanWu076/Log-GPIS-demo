clc;
clear;
close all;

meanWhittle = [];
meanMatern = [];
lambdaCount = [];
for i = 30:5:40
    lambda = i; % lambda = 1/sqrt(t)
    lambdaCount = [lambdaCount,i];
    circleDim = 5;
    v = 3/2;
    noise = 0.001;
    scale = sqrt(2*v);

    % whittle kernel, the special case of matern kernel
    cov1 = @(x1, x2)( pdist2(x1, x2)/(2*lambda).*besselk(1, eps+(pdist2(x1, x2))*lambda) ); 
    % 3/2 matern kernel
    cov2 = @(x1, x2)( (1/(gamma(v)*(2^(v-1))))*((pdist2(x1, x2)*(sqrt(2*v))*(lambda/scale)).^v).*besselk(v,eps+(pdist2(x1, x2))*(sqrt(2*v))*(lambda/scale)) ); 

    % SE kernel for comparison
    % cov = @(x1, x2)( exp(-pdist2(x1, x2).^2/lambda) );

    % observations of a circle
    circle = [0, 0] + circleDim * [cos(-pi:0.01:(pi))', sin(-pi:0.01:(pi))']; 

    % query points
    [X, Y] = meshgrid(-10:0.1:10, -10:0.1:10);
    Qpoint(:,1) = X(:);
    Qpoint(:,2) = Y(:);

    % number of observations
    N_obs = size(circle, 1); 

    % big K 
    K1 = cov1(circle, circle); 
    K2 = cov2(circle, circle); 
    
    % kstar
    k1 = cov1(Qpoint, circle); 
    k2 = cov2(Qpoint, circle); 

    % gp regression 
    y = zeros(size(circle, 1), 1) - 0.05;
    y = exp(-y*lambda) + noise*randn(size(circle, 1), 1);
    mu1 = k1 * ((K1 + noise * eye(N_obs)) \ y); 
    mu2 = k2 * ((K2 + noise * eye(N_obs)) \ y); 

    % recover the mean according to Log-GPIS
    mean1 = -(1 / lambda) * log((mu1)) + 0.05;
    mean2 = -(1 / lambda) * log((mu2)) + 0.05;
    meanWhittle = [meanWhittle,mean1];   
    meanMatern = [meanMatern,mean2]; 
    
    figure;
    hold on;
    % regressed using Log-GPIS whittle kernel
    surf(X, Y, reshape(mean1, size(X)), 'EdgeColor', 'none', 'FaceColor', 'r' ); 
    % ground truth (cos it's a circle)
    surf(X, Y, abs(sqrt(X.^2 + Y.^2) - circleDim), 'EdgeColor', 'none', 'FaceColor', 'g');
    alpha 0.5
    % observations
    plot(circle(:, 1), circle(:, 2), 'ko', 'MarkerFaceColor', 'k'); 
    view(-170,20);
    grid on;
    axis equal;
    axis equal;
    set(gca,'FontSize',15);
    
    figure;
    hold on;
    % regressed using Log-GPIS matern kernel
    surf(X, Y, reshape(mean2, size(X)), 'EdgeColor', 'none', 'FaceColor', 'r' ); 
    % ground truth (cos it's a circle)
    surf(X, Y, abs(sqrt(X.^2 + Y.^2) - circleDim), 'EdgeColor', 'none', 'FaceColor', 'g');
    alpha 0.5
    % observations
    plot(circle(:, 1), circle(:, 2), 'ko', 'MarkerFaceColor', 'k'); 
    view(-170,20);
    grid on;
    axis equal;
    axis equal;
    set(gca,'FontSize',15);
end

for i = 1:1:size(meanWhittle,2)
    dist1 = meanWhittle(:,i)-reshape(abs(sqrt(X.^2 + Y.^2) - circleDim),size(mean1));
    dist2 = meanMatern(:,i)-reshape(abs(sqrt(X.^2 + Y.^2) - circleDim),size(mean2));
    RMSE1(i) = sqrt(mean(dist1.^2));
    RMSE2(i) = sqrt(mean(dist2.^2));
end

% Plot the several test results in terms of RMSE
figure;    
b= bar(lambdaCount,[RMSE1' RMSE2']);   
legend('Whittle', '3/2 Matern');

title('Root Mean Squared Error');
ylabel('RMSE [m]');
xlabel('{\lambda}');
set(gca,'FontSize',15);