clc;
clear;
close all;

lambda = 100; % lambda = 1/sqrt(t)
v = 3/2;
noise = 0.05;
scale = sqrt(2*v);

% whittle kernel, the special case for matern kernel
% cov = @(x1, x2)( pdist2(x1, x2)/(2*lambda).*besselk(1, eps + (pdist2(x1, x2))*lambda) ); 
% 3/2 matern kernel
cov = @(x1, x2)( (1/(gamma(v)*(2^(v-1))))*((pdist2(x1, x2)*(sqrt(2*v))*(lambda/scale)).^v) .* besselk(v, eps + (pdist2(x1, x2))*(sqrt(2*v))*(lambda/scale)) ); 
% SE kernel for comparison
% cov = @(x1, x2)( exp(-pdist2(x1, x2).^2 / lambda) );

% observations as a sphere
[xa,yb,zc] = sphere(60);
sphere(:,1) = 3*xa(:);
sphere(:,2) = 3*yb(:); 
sphere(:,3) = 3*zc(:);

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
y = zeros(size(sphere, 1), 1) - 0.05;
y = exp(-y*lambda) + noise*randn(size(sphere, 1), 1);
mu = k * ((K + noise * eye(N_obs)) \ y); 

% recover the mean according to Log-GPIS
mean = -(1/lambda) * log((mu)) + 0.05;   

figure;
hold on;
scatter3(querySlice(:,1),querySlice(:,2),querySlice(:,3),[],mean,'*'); hold on; % querySlice in colour
colormap(hsv);
colorbar;
scatter3(sphere(:,1),sphere(:,2),sphere(:,3), 'k', 'MarkerFaceColor', 'k'); hold on; % obvervations of sphere
axis equal;

xg = reshape(querySlice(:,1),size(xg));
yg = reshape(querySlice(:,2),size(xg));
surf(xg, yg, reshape(mean,size(xg)), 'EdgeColor', 'None', 'FaceColor', 'r'); hold on; % visual distance in 3D
surf(xg, yg, abs(sqrt(xg.^2 + yg.^2) - 3), 'EdgeColor', 'none', 'FaceColor', 'g'); hold on; % visual ground truth of distance

shading interp;
camlight; 
lighting phong;
axis equal;