function stats = partitition( A, dx, w )
%
% dx grid spacing and w is window size

%%
% A = 1 - round( double( imread('test.png') ) ./255);
s = size(A);

%%

windows = arrayfun( @(x) 0 : (x-1), w, 'UniformOutput', false );

nwindow = 0;

%%

for xx = 1 : dx(1) : s(1)
    for yy = 1 : dx(2) : s(2)
        [ wx wy] = deal( windows{1} + xx, windows{2} + yy );
        if all( wx > 0 ) &&  all( wy > 0 ) && ...
                max( wx ) <= s(1) && max( wy ) <= s(2)
            nwindow = nwindow + 1; 
        end
    end
end

totwindow = nwindow
nwindow = 0;

%%

            
for xx = 1 : dx(1) : s(1)
    for yy = 1 : dx(2) : s(2)
        
        [ wx wy] = deal( windows{1} + xx, windows{2} + yy );
        
        if all( wx > 0 ) &&  all( wy > 0 ) && ...
                max( wx ) <= s(1) && max( wy ) <= s(2)
            disp( sprintf( '(%i,%i) / (%i,%i)', xx,yy,s(1),s(2) ) );
            
            nwindow = nwindow + 1;
            
            [fA,vectors] = SpatialStatsFFT( A( wx,wy ), 1- A( wx,wy ) ,...
                                            'display', false ); 
                                        
            if nwindow == 1
                stats = struct( ...
                'feature', zeros( totwindow, numel( fA ) ), ...
                'window', zeros( totwindow, 2 ) );
            end
            
            stats.feature( nwindow,:) = fA(:)';
            stats.window( nwindow,:) = [xx yy];
            stats.vector = vectors;
            
        end
            
        
    end
end

stats.mean = mean( stats.feature, 1 );

% return stats

%%

