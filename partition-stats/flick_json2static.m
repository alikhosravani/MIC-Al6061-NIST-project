function url = flick_json2static( response )
% Convert flickr json app response into a static image url.
% Go to flickr's app garden and generate a jsonified list of a photosets
% contents.
%
% https://www.flickr.com/services/api/explore/flickr.photosets.getPhotos
%
% The id for the photoset can be found the url for the set.
%
% response is the contents of set.photoset.photo{%i}

sz = 'z';
url = sprintf( 'https://farm%i.staticflickr.com/%s/%s_%s_%s.jpg', ...
    response.farm, response.server, response.id, response.secret, sz ) ;

