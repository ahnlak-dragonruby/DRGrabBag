# class_audio.rb
#
# A class from Ahnlak's DRGrabBag
#
# A class to wrap music and audio playing. This wraps up functionality to turn
# just music, and all audio, on and off easily. It also protects against some
# rather tedious bugs in HTML builds (as at DR 1.25)
#
# Usage: create an instance of Ahnlak::ClassAudio
#
# Public boolen properties: music, audio
# Public methods: play, pause, resume, stop
#
# The update method should also be called on every tick, in case we have queued
# actions to be done

module Ahnlak

  # A class to wrap music and audio playing
  class ClassAudio

    attr_reader :music, :audio

    # Initialiser just sets some defaults
    def initialize

      # On startup, assume music and audio are enabled, and nothing is playing
      @music = true
      @audio = true
      @track_queued = false
      @music_playing = false
      @active_track = ''

    end


    # Music and audio properties, which control what is active
    def music=(flag)

      # Save the flag
      @music = flag

      # If we've turned music on, resume any music that's paused
      if @music
        resume
      # Otherwise, pause which will stop anything that's currently playing
      else
        pause
      end

    end

    def audio=(flag)

      # Save the flag
      @audio = flag

      # If we turned audio on, use the music setter to check the music side
      if @audio
        self.music = @music
      # Otherwise, pause any current music
      else
        pause
      end

    end


    # Music control methods
    def play(sound)

      # wav files are simple, play-once sounds that are fire-and-forget,
      # as long as audio is enabled
      if sound.end_with?('.wav') && @audio
        $gtk.args.outputs.sounds << sound
        return
      end

      # It better be an ogg file then, or we can't handle it
      return unless sound.end_with?('.ogg')

      # Excellent. So, stop anything currently playing, and queue the new track
      stop
      @track_queued = true
      @active_track = sound

    end

    def pause

      # Stop playing any music
      $gtk.stop_music

      # Record that this is where we are
      @music_playing = false

    end

    def resume

      # Sanity check, can't resume if we're already playing
      return if @music_playing

      # Can't resume unless we have an active track
      return unless @active_track

      # Then we simply play that track; we can't (currently) remember track position
      play(@active_track)

    end

    def stop

      # Pause the music
      pause

      # And then clear the active track
      @active_track = ''

    end


    # Update method; called every tick, to see if there is a track queues
    def update

      # Can't do anything if the music isn't turned on, with a track queued
      return unless @active_track && @track_queued && @music && @audio

      # Also, if music is already playing we don't have to do anything.
      # This shouldn't be possible, but worth guarding against anyway
      return if @music_playing

      # So, start the music playing
      $gtk.args.outputs.sounds << @active_track

      # And set the flags right
      @track_queued = false
      @music_playing = true

    end

  end

end
