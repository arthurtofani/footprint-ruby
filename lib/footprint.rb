require "footprint/version"
require 'active_support'
require 'active_support/core_ext/object'
require 'footprint/callback_events'
require 'footprint/callback_events/event'
require 'footprint/callback_events/file_added_event'
require 'footprint/callback_events/multiple_files_added_event'
require 'footprint/callback_events/start_event'
require 'footprint/callback_events/query_performed_event'
require 'footprint/callback_events/digest_hashed_event'
require 'footprint/observer'
require 'footprint/observable'
require 'footprint/system'
require 'footprint/client'
require 'footprint/config'
require 'footprint/cli'
require 'footprint/event'
require 'footprint/event_list'
require 'footprint/digest'
require 'footprint/digest_list'

module Footprint
  module Reports
  end
end
