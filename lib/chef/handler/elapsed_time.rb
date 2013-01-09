# Chef Handler for logging resource execution time as an ascii
# barchart
#
# Author:: James Casey <jamesc.000@gmail.com>
# Copyright:: Copyright 2012 Opscode, Inc.
# License:: Apache2
#


class Chef
  class Handler
    class ElapsedTime < Chef::Handler

      def initialize(config={})
        @config = config
        @config[:max_width] ||= 30
        @config[:max_name] ||= 120 - @config[:max_width]
        @config
      end

      def report
        @max_time = all_resources.max_by{ |r| r.elapsed_time }.elapsed_time
        Chef::Log.info "%-#{@config[:max_width]}s %-#{@config[:max_name]}s"%["Elapsed Time", "Resource"]
        Chef::Log.info "%-#{@config[:max_width]}s %-#{@config[:max_name]}s"%["============", "========"]
        all_resources.sort_by{ |r| r.elapsed_time }.each do |r|
          char = if r.updated then "+" else "-" end
          bar = char * ( @config[:max_width] * (r.elapsed_time/@max_time)).ceil
          Chef::Log.info "%.3fs %s %-#{@config[:max_name]}s"%[r.elapsed_time, bar, full_name(r)]
        end
        Chef::Log.info ""
        Chef::Log.info "Scale : %.3fs per unit width"%[unit_width]
        Chef::Log.info " * '+' denotes a resource which updated this run"
        Chef::Log.info " * '-' denotes a resource which did not update this run"
      end

    end

    def unit_width
      @max_time/@config[:max_width]
    end

    def full_name(resource)
      "#{resource.resource_name}[#{resource.name}]"
    end
  end
end
