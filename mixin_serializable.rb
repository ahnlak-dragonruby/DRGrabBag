# mixin_serializable.rb
#
# A mixin from Ahnlak's DRGrabBag
#
# Copyright (c) 2020 Pete Favelle <dragonruby@ahnlak.com>
#
# This file is distributed under the MIT License. See LICENSE for more details.
#
# Automatically provide serialize / inspect / to_s functions, exposing all
# instance variables in a hopefully readable form
#
# Usage: include as `include Ahnlak::MixinSerializable`
#
# Version 1.0 : 13/10/2020

module Ahnlak

  # A mixin to add simple serialization to a class
  module MixinSerializable

    # The main serialization
    def serialize

      vars = { 'Class' => self.class.name }
      instance_variables.each do |var|
        next if @serializable_excludes && @serializable_excludes.include?(var.to_s) 
        vars[var] = instance_variable_get(var)
      end
      vars

    end

    # inspect and to_s just convert the hash to a string
    def inspect
      serialize.to_s
    end
    def to_s
      serialize.to_s
    end

    # We can also choose to explicitely exclude certain instance variables
    def serializable_without(varname)
      @serializable_excludes ||= []
      @serializable_excludes << varname
    end

  end

end
