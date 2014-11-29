%% Get static link to the img
% This was only done one time for some housekeeping.  Now it is easier to
% access the flickr urls and they can be used within posts.
%
% for ii = 1 : 4
%     
%     set = loadjson( ...
%         fileread( sprintf( './_data/set%i.json',ii) ) ...
%         );
%     
%     for jj = 1 : numel( set.photoset.photo )
%         url = flick_json2static( set.photoset.photo{jj} );
%         set.photoset.photo{jj} = ...
%             setfield( set.photoset.photo{jj}, 'static', url );
%     end
%     
%     s = savejson( set );
%     
%     fo = fopen( sprintf( './_data/set%i.json',ii),'w');
%     fwrite( fo, s );
%     fclose( fo );
%     
% end

%% Loop through images and compute spatial statistics
% Calculate the local spatial statistics within an image

if ~isdir( 'MAT' ) mkdir( 'MAT' ); end


runnm = 'CROSS';

photoct = 0;

for ii = 1 : 4
    
    set = loadjson( ...
        fileread( sprintf( './_data/set%i.json',ii) ) ...
        );
    set = set.set;
    
    for jj = 1 : numel( set.photoset.photo )
        photoct = photoct + 1;
        
        % Photo information
        photo = set.photoset.photo{jj};
        url = flick_json2static( photo );
        
        % Read and process the image
        IMG = imread( url );
%         IMG = imread( 'test.png' );
        % crop image because of the high righter most gradient
        IMG = IMG(:, 1 : size( IMG, 1 ), : );
        % Normalize the image
        IMG(:) = IMG ./ 255;
        % Identify precipitates
        
        IMG = double( IMG < .4 );
        
        s = size( IMG );
        w = s;
        dx = s ;
        
        % Compute spatial statistics
        [stats] = partition( IMG, dx, w );
        [ stats.dx , stats.w ] = deal( dx, w );
        
        % PCA
%         U2 = bsxfun( @minus, stats.feature, stats.mean );
%         [ U S V ] = pca( U2, 10);
        
%         pcaviz( 'test.png', dx, w, stats, U, S, V );
%         pcaviz( 'test.png', dx, w, stats );
        
        % Save the results
        save( fullfile( 'MAT', sprintf('%s_%0.3i.mat', runnm,photoct) ) , ...
            'photo', 'stats','U','S','V' );
    end    
end

%%

runnm = 'CROSS';
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
    src{ii} = photo.static;
end

%% Plot the PCA embedding

% There are zero rows for some reason?
m = mean( F, 1);

[U S V ] = pca( bsxfun( @minus, F, m ) );

co = rand(100,3);

for uu = unique(id)';
    b2 = id == uu;
    plot( U(b2,1), U(b2,2), 'ko', 'Markerfacecolor', co(uu,:), 'MarkerSize', 16 );
    text( U(b2,1), U(b2,2), nm{uu},'Fontsize',16, 'Interpreter', 'none' );
    if uu == 1 hold on; end
    
    figure(gcf)
end
hold off
figure(gcf)

%% Plot statistics of the weights

plot( [ accumarray( id(b), sqrt( sum(U.^2,2) ), [], @max), ...
        accumarray( id(b), sqrt( sum(U.^2,2) ), [], @mean), ...
        accumarray( id(b), sqrt( sum(U.^2,2) ), [], @median), ...
        accumarray( id(b), sqrt( sum(U.^2,2) ), [], @range), ...
        accumarray( id(b), sqrt( sum(U.^2,2) ), [], @std), ...
        accumarray( id(b), sqrt( sum(U.^2,2) ), [], @min)] )
    hold on
    for ii = 1 : numel( nm )
        text( ii, 0.05, nm{ii},'FontSize',16,'Rotation',90,'Interpreter','none');
    end
    hold off
    figure(gcf)
    
%% Convert to JSON for d3 browsing
description = ...
    horzcat( ...
    'PCA embedding of the cross correlations of the images following', ...
    ' a segmentation found in the code-base.'  );

jsonstr = savejson( '', struct( 'embed', struct( 'C', id, ...
                                           'src', char( src ) , ...
                                           'name',char( nm ), ...
                                           'X', U(:,1), ...
                                           'Y', U(:,2) , ...
                                           'description', description ) ), ....
                           'ArrayIndent',0);
                                       
fo = fopen( 'assets/cross-correlation-embed.json', 'w' );
fwrite( fo, jsonstr );
fclose( fo );
