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
        @config
      end

      def report
        @max_time = all_resources.max_by{ |r| r.elapsed_time }.elapsed_time
        @max_length = full_name(all_resources.max_by{ |r| full_name(r).length }).length
        Chef::Log.info "%-#{@max_length}s %s"%["Resource", "Elapsed Time"]
        Chef::Log.info "%-#{@max_length}s %s"%["========", "============"]
        all_resources.sort_by{ |r| r.elapsed_time }.each do |r|
          char = if r.updated then "+" else "-" end
          bar = char * ( @config[:max_width] * (r.elapsed_time/@max_time)).ceil
          Chef::Log.info "%-#{@max_length}s %.3fs %s"%[full_name(r), r.elapsed_time, bar]
        end
        Chef::Log.info ""
        Chef::Log.info "Scale            : %.3fs per unit width"%[unit_width]
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
