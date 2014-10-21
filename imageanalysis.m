%% Finding Precipitate Phases in Al6061 Optical Micrographs

%% Import Some Little Widgets
% Normalize and adjust images.  

if ~exist('normalize','var') | ~exist('adjust','var')
    % GIST raw
    rawurl = 'https://gist.githubusercontent.com/tonyfast/8a2bb4752e0cfc55c99f/raw/f706ad03b824c4e17776d012eefd0ec755d133e5/adjust_normalize.m'
    s = urlread(  rawurl );
    eval( s );
    clear( 'rawurl','s')
end

%%  Load in Data
% Load in two reference images to find the Center of Mass of precipitates
% in Aged Aluminum

files = dir( fullfile( '_data', ...
                       'Al6061*.tif' ) );
    
ct = 0;
A = zeros( [ [2288 2048] 2] );
clear content
for file = files'
    ct = ct + 1;
    A(:,:,ct) = imresize(imread( fullfile( '_data', file.('name') ) ), 1);
    
    % Extact metadata in file name
    s = strsplit( file.('name') , '_');
    content( ct ) =  struct( ...
        'local', fullfile( '_data', file.('name') ), ...
        'material', s{1}, ...
        'processing', s{2}, ...
        'temperature', s{3}, ...
        'time', s{4}, ...
        'direc', s{5}, ...
        'unknown',s{6} );
end

%% Plot raw Data


close all;
for ii = 1 : 2
    ax(ii) = subplot( 1, 2, ii);
    imshow( normalize( A(1:size(A,2),:,ii) ) );
    axis equal; shading flat; axis off;
    axis ij;
    
    tt = sprintf( '%s %s @ %s', content( ii).('material'), ...
                           content( ii).('processing'), ...
                           content( ii).('temperature'));
                       
    title( tt );
end
linkaxes(ax)
colormap gray
figure(gcf);

%%  Smooth the Aged Data
% Resize by a half and resize that by two for smoothing

close all
AA = imresize( imresize( normalize(A(1: size(A,2),:,2)), .5), 2);
imshow( AA );
title( 'Smoothed Data', 'Fontsize', 16 )
figure(gcf)

%%  Gradients should indicate the phases
%
% uses : <<derivative5.m
% http://www.csse.uwa.edu.au/~pk/Research/MatlabFns/Spatial/derivative5.m>>
%
% The compute the magnitude of the gradient around the phases of interest


close all

T = AA;

G = cell(1,3);
% Derivative7 doesnt find large enough because it is using more spatial
% information.
[G{1}, G{2}, G{3} ] =derivative5( T, 'x','y','xy');

GG = sqrt( G{1}.^2 +G{2}.^2 );

imshow( 1-normalize(GG) );
title( 'Zoomed Gradient Magnitude (Dark Values indicate a gradient)', 'FontSize', 16 )
xlim([  295.5309  551.5309])
ylim([ 443 700])


%% Find Locally Minimal Pixels
% Erode the image to find the local minima for the precipiates.
%
% The Gradient identifies the edges of the precipitate.  Erode forces the
% potential center to have the local minima value
E = imerode( T, ones(3));


%% Glue and Scotch Tape
%
% Find Centers of Precipitates
%
% * Invert Original Image ( Precipitates of Interest become bright )
% * Invert Gradient ( Homogenous Regions are Weighted Higher )
% * Multiple Inverted Image with Inverted Gradient
%   * The center of precipitates have no gradient
%   * Centers will emerge as bright spots in the center of a potential
%   precipitate because the gradient lowers the weight of the edges.


% Precondition Image with Gradient

Q = normalize( ( 1 - normalize( GG ) ) ... 
    .* (1 - normalize(T) ) );

%% Find Bright Spots in a Precipitate


P = Find_Peaks( Q, 'neighborhood',5, 'diff', false);


%% Threshold potential centers
% These are the two key parameters to modify to change the segmentation.

threshmult = 1.5;
cutoffpix = [mean(E(:)) - std(E(:)) * threshmult];
%%

B = P & E < cutoffpix;

%%
% Find matrix positions of centers
[pid] = find(B);
[xx,yy] = find(B);


%%
% Plot Segmentation

close all
imshow(T); axis equal; shading flat; 
hold on
plot3(yy,xx,E(pid),'cd')
title( sprintf( '%i precipitates found.', numel( pid )  ) )
hold off
figure(gcf);

snapnow;

xlim([ 280.0309  792.0309])
ylim([ 305.9960  817.9960])
title( sprintf( '%i precipitates found. ZOOMED', numel( pid )  ) )
snapnow;    

%% Export Centers as JSON

% Create export structure
precipitate = struct( 'center', [xx, yy], 'cutoff', cutoffpix, 'file', content(2).('local') );

fo = fopen(fullfile( '_data', 'precipitate_center_600F_2hrs.json'), 'w');
fprintf( fo, '%s\n', savejson( [], precipitate) );
fclose(fo);

return
%%
