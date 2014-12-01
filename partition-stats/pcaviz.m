function pcaviz( IMG, dx, w, stats, U, S, V );


[ yy, xx ] = hist( U(:), 25 );



co = cbrewer( 'div','RdYlBu', numel( xx ) - 1);
for doi = 1 : 3;
    subplot( 2,2,doi);
    imshow(IMG);
    
    hold on;
    for ii = 1 : ( numel(xx) - 1 );
        b = U(:,doi) >=  xx(ii) & U(:,doi) <=  xx(ii+1);
        plot( ...
              stats.window( b,2) + w(2)/2, ...
              stats.window( b,1) + w(1)/2, ...
              'o', ...
              'MarkerFaceColor', co( ii, : ), ...
              'MarkerEdgeColor', 'none', ....
              'MarkerSize', 12 ...
              );


    end
    hold off;
end
subplot(2,2,4);
imshow(IMG)
figure(gcf)