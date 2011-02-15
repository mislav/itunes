#!/usr/local/bin/macruby
framework 'Foundation'
framework 'ScriptingBridge'

module ITunesManager
  def self.app
    @app ||= SBApplication.applicationWithBundleIdentifier('com.apple.itunes').tap do
      # $ sdef /Applications/iTunes.app | sdp -fh --basename iTunes
      # $ gen_bridge_metadata -c '-I.' iTunes.h > iTunes.bridgesupport
      load_bridge_support_file 'iTunes.bridgesupport'
    end
  end

  # trigger loading bridge support file
  self.app
  
  def self.library
    @library ||= app.sources['Library']
  end
  
  def self.music
    library.userPlaylists['Music']
  end

  PlayerStates = {
    ITunesEPlSStopped => :stopped,
  	ITunesEPlSPlaying => :playing,
  	ITunesEPlSPaused => :paused,
  	ITunesEPlSFastForwarding => :fast_forwarding,
  	ITunesEPlSRewinding => :rewinding
  }
  
  def self.player_state
    PlayerStates[app.playerState]
  end
  
  def self.current_track
    ensure_found app.currentTrack
  end
  
  def self.find_folder(name)
    ensure_found library.playlists[name]
  end
  
  def self.find_or_create_folder(name)
    folder = find_folder name
    
    if folder
      raise %(iTunes item "#{folder.name}" exists but is not a folder) unless folder.folder?
      folder
    else
      folder = ITunesFolderPlaylist.alloc.initWithProperties(name: name)
      library.playlists.addObject(folder)
      library.playlists[name]
    end
  end
  
  def self.find_playlist(name)
    ensure_found library.userPlaylists[name]
  end
  
  def self.find_or_create_playlist(name, folder = nil)
    playlist = find_playlist name
    
    unless playlist
      playlist = ITunesUserPlaylist.alloc.initWithProperties(name: name)
      library.userPlaylists.addObject(playlist)
      playlist = library.userPlaylists[name]
    end
    
    if folder
      folder = find_or_create_folder(folder) if String === folder
      playlist.moveTo(folder) unless folder == playlist.parent
    end
    
    playlist
  end
  
  class << self
    private
    def ensure_found(item)
      # work around the fact that iTunesItem lookups will often
      # return an object regardless of whether it actually exists
      item.id == 0 ? nil : item
    end
  end
end

class SBElementArray
  def [](value)
    self.objectWithName(value)
  end
end

class ITunesPlaylist
  SearchFilters = {
    albums: ITunesESrAAlbums,
    all: ITunesESrAAll,
    artists: ITunesESrAArtists,
    composers: ITunesESrAComposers,
    visible: ITunesESrADisplayed, # visible text fields
    songs: ITunesESrASongs
  }

  def search(query, filter = :visible)
    searchFor(query, only:SearchFilters[filter])
  end
  
  def folder?
    self.specialKind == ITunesESpKFolder
  end
end

class ITunesUserPlaylist
  def inspect
    %(#<#{self.class.name}:#{self.name}>)
  end
  
  def <<(track)
    track.duplicateTo(self)
    self
  end
  
  def add(tracks)
    Array(tracks).each { |t| self << t }
    self
  end
end

class ITunesFileTrack
  def to_s
    by = artist || albumArtist || '(unknown artist)'
    "#{by} - #{name}"
  end
  
  def inspect
    %(#<#{self.class.name}:#{self}>)
  end
end

class NSURL
  def inspect
    if scheme == "file"
      %(#<#{self.class.name}:#{self.path}>)
    else
      super
    end
  end
end
