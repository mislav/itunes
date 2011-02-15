# Access iTunes with MacRuby through Scripting Bridge

Prerequisites: [MacRuby](http://www.macruby.org/)

Example usage:

    ITunesManager.app.run

    # start playing at the beginning
    ITunesManager.music.playOnce(false)
    
    ITunesManager.player_state  #=> :playing
    
    ITunesManager.app.playpause
    ITunesManager.player_state  #=> :paused
    
    track = ITunesManager.current_track
    
    # for more properties, see iTunes.h under "@interface iTunesTrack"
    track.name
    track.artist
    track.album

    # playlist management
    favorites = ITunesManager.find_or_create_playlist 'Favorites'
    
    track = ITunesManager.music.fileTracks.first
    favorites << track
    
    favorites.add ITunesManager.music.search('daft punk')
    favorites.add ITunesManager.music.search('pendulum', :artists)
    favorites.add ITunesManager.music.search('easy rider', :albums)
