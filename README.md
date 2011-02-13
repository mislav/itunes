# Access iTunes with MacRuby through Scripting Bridge

Prerequisites: [MacRuby](http://www.macruby.org/)

Example usage:

    favorites = ITunesManager.find_or_create_playlist 'Favorites'
    
    track = ITunesManager.music.fileTracks.first
    
    # see iTunes.h under "@interface iTunesTrack" for more properties
    track.name
    track.artist
    track.album
    
    favorites << track
    
    favorites.add ITunesManager.music.search('daft punk')
    favorites.add ITunesManager.music.search('pendulum', :artists)
    favorites.add ITunesManager.music.search('easy rider', :albums)
