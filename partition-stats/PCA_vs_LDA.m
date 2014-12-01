%%

co = rand(100,3);
%%
runnm = 'CROSS_w200_dx_125';
matdir = @(x)fullfile( 'MAT', sprintf('%s_%s.mat', runnm , x) )
files = dir( matdir('*')  );
F = [];
id = [];
for ii = 1 : numel( files )
    file = matdir( sprintf( '%0.3i', ii ) );
    load( file );
    F = vertcat( F, stats.feature );
    id = vertcat( id, ones(size(stats.feature,1),1)*ii );
    nm{ii} = photo.title;
   
end

FL = F;
idL = id;

cutoff =  stats.w ./2 ;

%%




%%

runnm = 'CROSS';
matdir = @(x)fullfile( 'MAT', sprintf('%s_%s.mat', runnm , x) )

F = [];
id = [];
for ii = 1 : 40
    file = matdir( sprintf( '%0.3i', ii ) );
    load( file );
    F = vertcat( F, stats.feature );
    id = vertcat( id, ones(size(stats.feature,1),1)*ii );
    nm{ii} = photo.title; 
end


[ Vx Vy ] = meshgrid( stats.vector{1}, stats.vector{2});
b = all( ...
        bsxfun( @le, abs( [Vx(:), Vy(:)] ), cutoff ), ...
       2);
   
 
 FA = F(:, b);
idA = id;

   

%% PCA on the expected cross correlation
subplot(2,3,1)
[ U S V ] = pca( FA, 40 );
centroids = zeros( numel( unique( idA ) ), size( U,2) );
for ii = 1 : size( U, 2)
    centroids( :,ii ) = accumarray( idA, U(:,ii), [], @mean );
end

for uu = unique(id)';
    b2 = idA == uu;
    plot3( centroids(uu,1), centroids(uu,2), centroids(uu,3), 'ko', 'Markerfacecolor', co(uu,:), 'MarkerSize', 16 );
    text( centroids(uu,1), centroids(uu,2), centroids(uu,3), ...
        nm{uu}( strfind( nm{uu}, 'F_') - [3:-1:1]), ...
        'Fontsize',16, 'Interpreter', 'none', 'BackgroundColor','w' );
    if uu == 1 hold on; end
    
    
end
hold off
grid on
figure(gcf)

subplot(2,3,4)
d = pdist( centroids( :, 1:2) );
Z = linkage( d );
dendrogram( Z )
figure(gcf)

description = ...
    sprintf('Basic PCA embedding of the expected values of the spatial statistics for a window size of %i x %i pixels', w(1), w(1));
outfile = 'pca_cross_correlation_200.json';

ids = idA;
convertjson;
%%  LDA on the subvolumes
subplot(2,3,2)
[ U S V ] = pca( FL, 40 );
[ U, mapping ] = lda( U, idL, 4 );

centroids = zeros( numel( unique( idL ) ), size( U,2) );
for ii = 1 : size( U, 2)
    centroids( :,ii ) = accumarray( idL, U(:,ii), [], @mean );
end

for uu = unique(id)';
    b2 = idL == uu;
%     plot( U(b2,1), U(b2,2), 'k.', 'Markerfacecolor', co(uu,:), 'MarkerSize', 6 );
    plot3( centroids(uu,1), centroids(uu,2), centroids(uu,3), 'ko', 'Markerfacecolor', co(uu,:), 'MarkerSize', 16 );
    text( centroids(uu,1), centroids(uu,2), centroids(uu,3), ...
        nm{uu}( strfind( nm{uu}, 'F_') - [3:-1:1]), ...
        'Fontsize',16, 'Interpreter', 'none', 'BackgroundColor','w' );
    if uu == 1 hold on; end
    
    
end
hold off
grid on
figure(gcf)

subplot(2,3,5)
d = pdist( centroids(:,1:2) );
Z = linkage( d );
dendrogram( Z )
figure(gcf)

description = ...
    sprintf('LDA supervised classification SVE windows %i x %i pixels', w(1), w(1) );
outfile = 'pca_cross_lda_200.json';

ids = idL;
convertjson;
%% PCA on individual subvolumes

subplot(2,3,3)
[ U S V ] = pca( FL, 40 );
% [ U, mapping ] = lda( U, idL, 4 );

centroids = zeros( numel( unique( idL ) ), size( U,2) );
for ii = 1 : size( U, 2)
    centroids( :,ii ) = accumarray( idL, U(:,ii), [], @mean );
end

for uu = 37%unique(id)';
    b2 = idL == uu;
    plot( U(b2,1), U(b2,2), '.', 'Markeredgecolor', co(uu,:), 'MarkerSize', 6 );
    if ( true || uu == 1 ) hold on; end
    plot3( centroids(uu,1), centroids(uu,2), centroids(uu,3), 'ko', 'Markerfacecolor', co(uu,:), 'MarkerSize', 16 );
    text( centroids(uu,1), centroids(uu,2), centroids(uu,3), ...
        nm{uu}( strfind( nm{uu}, 'F_') - [3:-1:1]), ...
        'Fontsize',16, 'Interpreter', 'none', 'BackgroundColor','w' );
    
    
    
end
hold off
grid on
figure(gcf)
% 
subplot(2,3,6)
d = pdist( centroids(:,1:2) );
Z = linkage( d );
dendrogram( Z )
figure(gcf)

description = ...
    sprintf('Unsupervised PCA  on all of the SVE windows %i x %i pixels', w(1), w(1) );
outfile = 'pca_cross_pca_200.json';

convertjson;