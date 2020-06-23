#!/usr/bin/env ruby
Bundler.require

AUTHORITIES = {
  newcastle: {
    url: "https://ncc-test-web.t1cloud.com/T1PRDefault/WebAppServices/ATDIS/atdis/1.0/applications.json"
  }
}

exceptions = []
AUTHORITIES.each do |authority_label, params|
  puts "\nCollecting ATDIS feed data for #{authority_label}..."

  begin
    # All the authorities are in NSW (for ATDIS) so they all have
    # the Sydney timezone
    ATDISPlanningAlertsFeed.fetch(params[:url], "Sydney") do |record|
      record[:authority_label] = authority_label.to_s
      puts "Storing #{record[:council_reference]} - #{record[:address]}"
      ScraperWikiMorph.save_sqlite([:authority_label, :council_reference], record)
    end
  rescue StandardError => e
    STDERR.puts "#{authority_label}: ERROR: #{e}"
    STDERR.puts e.backtrace
    exceptions << e
  end
end

unless exceptions.empty?
  raise "There were earlier errors. See output for details"
end
