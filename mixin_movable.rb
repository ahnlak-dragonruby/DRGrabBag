# mixin_movable.rb
#
# A mixin from Ahnlak's DRGrabBag
#
# Copyright (c) 2020 Pete Favelle <dragonruby@ahnlak.com>
#
# This file is distributed under the MIT License. See LICENSE for more details.
#
# Adds in x/y/w/h/angle attributes, along with functions to set positions and
# dimensions, along with suitable tweening
#
# Usage: include as `include Ahnlak::MixinMovable`
#
# xy values can then be set with movable_location
# wh values can be set with movable_size
# angle values can be set with movable_angle
#
# If the speed parameter is included, ensure to call update every tick to
# slowly transition to the new values
#
# Note that not all parameter apply to all primitives (ie labels don't rotate)
#
# Version 1.0 : 13/10/2020

module Ahnlak

  # A mixin to add flexible xywh attributes to a class
  module MixinMovable

    attr_accessor :x, :y, :w, :h, :angle


    # The main user-facing call to set the location
    def movable_location(column, row, speed = 0)

      # Always set the target co-ordinates
      @movable_target_x = column
      @movable_target_y = row

      # If the speed is zero, warp straight there
      if speed.zero?

        @x = column
        @y = row

      # Otheriwse, calculate the deltas and leave it at that
      else

        @movable_delta_x = (column - @x) / speed
        @movable_delta_y = (row - @y) / speed

      end

    end


    # Takes an array of locations, allowing a path to be followed
    # This can be a sequence (run once) or a cycle (run forever)
    def movable_location_cycle(locations, speed)
      @movable_location_loop = true
      movable_start_location_list(locations, speed)
    end

    def movable_location_sequence(locations, speed)
      @movable_location_loop = false
      movable_start_location_list(locations, speed)
    end

    def movable_start_location_list(locations, speed)
      @movable_location_index = 0
      @movable_location_speed = speed
      @movable_locations = locations
      speed = 0 unless @x && @y
      movable_location(locations[0][0], locations[0][1], speed)
    end


    # Similar work, but for sizes
    def movable_size(width, height, speed = 0)

      # Always set the target size
      @movable_target_w = width
      @movable_target_h = height

      # If the speed is zero, set it direct
      if speed.zero?

        @w = width
        @h = height

      # Otherwise, calculate the deltas
      else

        @movable_delta_w = (width - @w) / speed
        @movable_delta_h = (height - @h) / speed

      end

    end


    # Next up, methods for setting the angle of a Movable. In this context,
    # a positive speed is clockwise and negative, anticlockwise
    def movable_angle(angle, speed = 0)

      # Always set the target angle
      @movable_target_angle = angle

      # If the speed is zero, move straing to it
      if speed.zero?

        @angle = angle

      # Otherwise, work out the deltas, taking on board the direction
      else

        angle += 360 if speed.positive? && angle < @angle
        angle -= 360 if speed.negative? && angle > @angle

        @movable_delta_angle = (angle - @angle) / speed.abs

      end

    end

    def movable_spin(speed)

      # The speed here it the frames for one complete revolution; set the
      # spin flag and work out the right delta
      @movable_spinning = true
      @movable_delta_angle = 360 / speed

    end


    # Method to let us know if we're moving
    def movable_moving?

      @movable_delta_x&.nonzero? || @movable_delta_y&.nonzero?

    end


    # Update should be called every tick, to apply any movements required
    def movable_update

      # Work through the different aspects we update
      movable_location_update
      movable_size_update
      movable_angle_update

    end

    # Location update handler
    def movable_location_update

      # Location first; apply either location delta that is nonzero
      if @movable_delta_x&.nonzero?

        # Apply the delta
        @x += @movable_delta_x

        # And see if we reached the target
        if (@movable_delta_x.positive? && @x >= @movable_target_x) ||
           (@movable_delta_x.negative? && @x <= @movable_target_x)
          @x = @movable_target_x
          @movable_delta_x = 0
        end

      end

      if @movable_delta_y&.nonzero?

        # Apply the delta
        @y += @movable_delta_y

        # And see if we reached the target
        if (@movable_delta_y.positive? && @y >= @movable_target_y) ||
           (@movable_delta_y.negative? && @y <= @movable_target_y)
          @y = @movable_target_y
          @movable_delta_y = 0
        end

      end

      # If we're in motion or lack a path, nothing more to do
      return if movable_moving? || !@movable_locations || @movable_locations.length.zero?

      # Move along the array, cycling to the start if necessary
      @movable_location_index += 1
      @movable_location_index = 0 if @movable_location_loop && @movable_location_index >= @movable_locations.length

      # If we've reached the end of the array, we're done
      return if @movable_location_index >= @movable_locations.length

      # Move to the next one then
      movable_location(
        @movable_locations[@movable_location_index][0],
        @movable_locations[@movable_location_index][1],
        @movable_location_speed
      )

    end

    # Size update handler
    # rubocop:disable Style/GuardClause
    def movable_size_update

      # Apply either size delta that is nonzero
      if @movable_delta_w&.nonzero?

        # Apply the delta
        @w += @movable_delta_w

        # And see if we reached the target
        if (@movable_delta_w.positive? && @w >= @movable_target_w) ||
           (@movable_delta_w.negative? && @w <= @movable_target_w)
          @w = @movable_target_w
          @movable_delta_w = 0
        end

      end

      if @movable_delta_h&.nonzero?

        # Apply the delta
        @h += @movable_delta_h

        # And see if we reached the target
        if (@movable_delta_h.positive? && @h >= @movable_target_h) ||
           (@movable_delta_h.negative? && @h <= @movable_target_h)
          @h = @movable_target_h
          @movable_delta_h = 0
        end

      end

    end
    # rubocop:enable Style/GuardClause

    # Angle update handler
    # rubocop:disable Style/GuardClause
    def movable_angle_update

      # Do we have an angle delta to apply?
      if @movable_delta_angle&.nonzero?

        # Apply the delta, normalised to 360 degrees
        @angle = (@angle + @movable_delta_angle) % 360

        # If we're eternally spinning, that's all we have to worry about
        return if @movable_spinning

      end

    end
    # rubocop:enable Style/GuardClause

  end

end
