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

      attr_accessor :max_width, :max_length

      def initialize(config={})
        @max_width = config[:max_width] || 30
        @max_length  = config[:max_length] || 120 - @max_width
      end

      def report
        Chef::Log.info "%-#{max_width}s %6s %-#{max_resource_length}s"%["Elapsed Time", '', "Resource"]
        Chef::Log.info "%-#{max_width}s %6s %-#{max_resource_length}s"%["============", '', "========"]
        all_resources.sort_by{ |r| r.elapsed_time }.each do |r|
          char = if r.updated then "+" else "-" end
          bar = char * ( max_width * (r.elapsed_time/max_time)).ceil
          Chef::Log.info "%05.2fs %-#{max_width}s %-#{max_resource_length}s"%[r.elasped_time, bar, full_name(r)]
        end
        Chef::Log.info ""
        Chef::Log.info "Scale : %.3fs per unit width"%[unit_width]
        Chef::Log.info " * '+' denotes a resource which updated this run"
        Chef::Log.info " * '-' denotes a resource which did not update this run"
      end

      private

      def unit_width
        max_time/max_width
      end

      def full_name(resource)
        "#{resource.resource_name}[#{resource.name}]"
      end

      def max_resource_length
        @max_resource_length ||= [ full_name(max_resource).length, max_length ].min
      end

      def full_name(resource)
        "#{resource.resource_name}[#{resource.name}]"
      end

      def max_resource_time
        @max_resource_time ||= max_resource.elapsed_time
      end

      def max_resource
        @max_resource ||= all_resources.max_by{ |r| r.elapsed_time}
      end

      def full_name(resource)
        "#{resource.resource_name}[#{resource.name}]"
      end
    end
  end
end
