module Footprint
  class Digest
    attr_reader :time_offset
    attr_accessor :digest
    def initialize(time_offset, digest)
      @time_offset = time_offset
      @digest = digest
    end
  end
end
