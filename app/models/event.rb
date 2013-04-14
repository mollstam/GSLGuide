class Event < ActiveRecord::Base

    has_many :match_sets

    # attr_accessible :name, :series, :uri

    def self.refresh_for_series(series)
        require 'open-uri'

        # Get event from series
        page = 1
        events = []
        print "Fetching events for #{series}"
        begin
            print '.'
            doc = Nokogiri::HTML(open("http://www.gomtv.net/#{series}/vod/?stype=1&ltype=0&keyfield=&keyvalue=&order=1&page=#{page}"))
            events_this_page = 0
            doc.xpath('//td[@class="vod_info"]/a[@class="vod_link"]').each do |vod|
                events_this_page += 1
                link = vod.get_attribute('href')
                event_uri = (link[0,1] == '/' ? 'http://www.gomtv.net' : '') + link

                event_doc = Nokogiri::HTML(open(event_uri))
                name = event_doc.xpath('//div[@class="vod_header"]/div[@class="vod_info"]/p[@class="vod_detail"]').text
                series_name = event_doc.xpath('//div[@class="vod_header"]/div[@class="vod_info"]/h3/a').text

                event = find_or_initialize_by_name_and_series(name, series_name)
                event.update_attributes({
                    date: event_doc.xpath('//p[@class="vod_time"]/strong').text.to_datetime,
                    uri: event_uri,
                })

                event.touch

                events.push(event)
            end

            page += 1
        end while events_this_page > 0

        print "#{events.count}\n"

        return events
    end

end
