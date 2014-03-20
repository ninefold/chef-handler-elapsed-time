# Chef Handler for logging resource execution time as an ascii
# barchart
#
# Author:: James Casey <jamesc.000@gmail.com>
# Copyright:: Copyright 2012 Opscode, Inc.
# License:: Apache2
#
# Adapted:: Warren Bain @ Ninefold
#

require 'rubygems'
Gem.clear_paths
require 'chef'
require 'chef/log'
require 'chef/handler'

module Ninefold
  module Handler
    class ElapsedTime < ::Chef::Handler

      attr_accessor :max_width

      def initialize(config={})
        @max_width = config[:max_width] || 30
      end

      def report
        Chef::Log.info "%-#{max_resource_length}s  %s"%["Resource", "Elapsed Time"]
        Chef::Log.info "%-#{max_resource_length}s  %s"%["========", "============"]
        all_resources.each do |r|
          char = if r.updated then "+" else "-" end
          bar = char * ( max_width * (r.elapsed_time/max_time))
          Chef::Log.info "%-#{max_resource_length}s  %s"%[full_name(r), bar]
        end
        Chef::Log.info ""
        Chef::Log.info "Slowest Resource : #{full_name(max_resource)} (%.6fs)"%[@max_time]
        Chef::Log.info "Scale            : %.6fs per unit width"%[unit_width]
        Chef::Log.info " * '+' denotes a resource which updated this run"
        Chef::Log.info " * '-' denotes a resource which did not update this run"
      end

      private

      def unit_width
        max_time/max_width
      end

      def max_resource_length
        @max_resource_length ||= full_name(max_resource).length
      end

      def full_name(resource)
        "#{resource.resource_name}[#{resource.name}]"
      end

      def max_time
        @max_time ||= all_resources.max_by{ |r| r.elapsed_time}.elapsed_time
      end

      def max_resource
        @max_resource ||= all_resources.max_by{ |r| full_name(r).length}
      end
    end
  end
end
