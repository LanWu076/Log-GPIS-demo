% Log-GPIS - Faithful Euclidean Distance Field from Log-Gaussian Process Implicit Surfaces
% https://github.com/LanWu076/Log-GPIS-demo
% https://arxiv.org/pdf/2010.11487.pdf
%
% This 3D demo demonstrates that Log-GPIS allows for 3D prediction as a sphere. 
% To see how it goes, just run LogGPIS_demo_3D.m. 
% The result is a black sphere showing the measurements, and the coloured 
% shape or slice is the distance values of the query points.
%
% This program is free software. You can redistribute it and/or modify it, 
% but WITHOUT ANY WARRANTY, without even the implied warranty of any FITNESS 
% FOR A PARTICULAR PURPOSE.

clc;
clear;
close all;
fprintf('Starting the 3D demo of Log-GPIS!\n\n');

lambda = 100; % lambda = 1/sqrt(t)
sphereRadius = 3;
v = 3/2;
noise = 0.05;
scale = sqrt(2*v);
fprintf('(lambda, sphere radius) = (%.0f, %.0f)\n', ...
        lambda, sphereRadius);

% whittle kernel, the special case for matern kernel
% cov = @(x1, x2)( pdist2(x1, x2)/(2*lambda).*besselk(1, eps + (pdist2(x1, x2))*lambda) ); 
% 3/2 matern kernel
cov = @(x1, x2)( (1/(gamma(v)*(2^(v-1))))*((pdist2(x1, x2)*(sqrt(2*v))*(lambda/scale)).^v) .* besselk(v, eps + (pdist2(x1, x2))*(sqrt(2*v))*(lambda/scale)) ); 
% SE kernel for comparison
% cov = @(x1, x2)( exp(-pdist2(x1, x2).^2 / lambda) );

% observations as a sphere
[xa,yb,zc] = sphere(60);
sphere(:,1) = sphereRadius*xa(:);
sphere(:,2) = sphereRadius*yb(:); 
sphere(:,3) = sphereRadius*zc(:);

% query points
[xg, yg] = meshgrid(-5:0.1:5, -5:0.1:5);
querySlice = [xg(:)'; yg(:)'; 0*ones(1,numel(xg))]';

% number of observations.
N_obs = size(sphere, 1); 

% big K 
K = cov(sphere, sphere); 

% kstar
k = cov(querySlice, sphere); 

% gp regression 
fprintf('Start Log-GPIS inference!\n');
y = zeros(size(sphere, 1), 1);
% y = zeros(size(sphere, 1), 1) - 0.05;
y = exp(-y*lambda) + noise*randn(size(sphere, 1), 1);
mu = k * ((K + noise * eye(N_obs)) \ y); 

% recover the mean according to Log-GPIS
mean = -(1/lambda) * log(abs(mu)); 
% mean = -(1/lambda) * log((mu)) + 0.05;
fprintf('Finished Log-GPIS inference!\n\n');

figure;
hold on;
% querySlice in colour
scatter3(querySlice(:,1),querySlice(:,2),querySlice(:,3),[],mean,'*'); hold on; 
colormap(hsv);
colorbar;
% obvervations of sphere
scatter3(sphere(:,1),sphere(:,2),sphere(:,3), 'k', 'MarkerFaceColor', 'k'); hold on; 
axis equal;

xg = reshape(querySlice(:,1),size(xg));
yg = reshape(querySlice(:,2),size(xg));
% visual a slice of the predicted distance field in 3D
surf(xg, yg, reshape(mean,size(xg)), 'EdgeColor', 'None', 'FaceColor', 'r'); hold on; 
% visual a slice of the ground truth distance field in 3D
surf(xg, yg, abs(sqrt(xg.^2 + yg.^2) - 3), 'EdgeColor', 'none', 'FaceColor', 'g'); hold on; 

shading interp;
camlight; 
lighting phong;
axis equal;
title('Log-GPIS 3D result');
disp('Finished the 3D demo of Log-GPIS!');