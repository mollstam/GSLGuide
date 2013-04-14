namespace :events do
    $stdout.sync = true

    task :refresh => :environment do
        # Refresh events from series
        Event.refresh_for_series('2013wcs1')

        # Refresh sets from each event
        Event.all.each do |event|
            MatchSet.get_all_from_event(event)
        end
    end
end
