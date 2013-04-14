class MatchSet < ActiveRecord::Base

    belongs_to :event
    serialize :players
    serialize :ratings

    def self.get_all_from_event(event)
        require 'open-uri'
        require 'net/http'
        require 'uri'

        sets = []

        print "Getting sets for #{event[:name]}"

        doc = Nokogiri::HTML(open(event[:uri]))
        doc.xpath('//ul[@id="vodList"]/li/a').each do |set|
            print "."
            players = set.get_attribute('title').gsub(/^\[.*\]\s*/,'').gsub(/\s*VS\s*/i, ',').split(',')

            set_index = set.get_attribute('onclick')[/.*clickSet\((\d+), (\d+)\).*/, 1].to_i
            set_id = set.get_attribute('onclick')[/.*clickSet\((\d+), (\d+)\).*/, 2].to_i

            playerinfo_uri = URI.parse('http://www.gomtv.net/process/playerInfo.gom')
            playerinfo_response = Net::HTTP.post_form(playerinfo_uri, {setid: set_id})
            playerinfo_doc = Nokogiri::HTML(playerinfo_response.body)
            map = playerinfo_doc.xpath('//p[@class="mapdatebox"]/a').text

            if event[:name] =~ /.*final.*/i then
                round = 2
            else
                round = event[:name][/.*ro\s{0,2}(\d+).*/i, 1].to_i
            end

            if event[:name] =~ /.*(Up\s{0,2}(&|and)\s{0,2}down).*/i then
                league = "Up/Down"
            elsif event[:name][/.*(Code\s{0,2}[SAB]).*/i, 1]
                league = event[:name][/.*(Code\s{0,2}[SAB]).*/i, 1]
            else
                league = nil
                logger.error "Unable to deduce league from event name: '#{event[:name]}'"
            end

            group = event[:name][/((Group|Day)\s{0,2}[0-9A-Z]+)/i, 1]

            match_set = MatchSet.find_or_initialize_by_gom_id(set_id)
            match_set.update_attributes({
                gom_id: set_id,
                event: event,
                index: set_index,
                players: players,
                map: map,
                uri: "#{event[:uri]}/?set=#{set_index}",
                league: league,
                round: round,
                group: group
            })

            match_set.touch

            sets.push(match_set)

            # Find Team Liquid forum thread
            best_thread = nil
            tl_name = "[#{league}] RO#{round} #{group}"
            tl_search = Nokogiri::HTML(open("http://www.teamliquid.net/forum/search.php?q=#{URI::encode(tl_name)}&t=t&f=36&u=&gb=date&d=create"))
            if tl_search.xpath('//td[@class="srch_res1"]')[0] != nil then

                tl_search.xpath('//td[@class="srch_res1"]')[0].parent.parent.children.each do |row|
                    unless row.xpath('td')[1].nil? then
                        next if row.xpath('td')[1].text == 'Topic'

                        thread = {
                            name: row.xpath('td')[1].text,
                            uri: "http://www.teamliquid.net/forum/#{row.xpath('td')[1].xpath('a')[0].get_attribute('href') unless row.xpath('td')[1].xpath('a')[0].nil?}"
                        }

                        unless thread[:uri].nil? then
                            tl_thread = Nokogiri::HTML(open(thread[:uri]))
                            thread[:date] = tl_thread.xpath('//a[@name="1"]')[0].parent.xpath('table//span[@class="forummsginfo"]').text[/.*\. (.*)\. Posts.*/i, 1].to_datetime
                            thread[:date_diff] = (thread[:date].to_i - event[:date].to_i).abs

                            if best_thread.nil? || thread[:date_diff] < best_thread[:date_diff] then
                                best_thread = thread
                            else
                                break
                            end
                        end
                    end
                end
            else
                logger.error "No search result found on page 'http://www.teamliquid.net/forum/search.php?q=#{URI::encode(tl_name)}&t=t&f=36&u=&gb=date&d=create'"
            end

            unless best_thread.nil? then
                # Time to find rating for MatchSet

                match_set[:forum_thread_uri] = best_thread[:uri]

                thread_doc = Nokogiri::HTML(open(best_thread[:uri]))
                poll = thread_doc.search("[text()*='Poll: Recommend']")[match_set[:index] - 1]
                unless poll.nil? then
                    ratings = {}
                    ratings[poll.parent.xpath('div')[0].children[0].text.downcase.gsub(' ', '_').to_sym] = poll.parent.xpath('div')[0].children[1].text[/.*\((\d+)\).*/i, 1].to_i
                    ratings[poll.parent.xpath('div')[0].children[7].text.downcase.gsub(' ', '_').to_sym] = poll.parent.xpath('div')[0].children[8].text[/.*\((\d+)\).*/i, 1].to_i
                    ratings[poll.parent.xpath('div')[0].children[14].text.downcase.gsub(' ', '_').to_sym] = poll.parent.xpath('div')[0].children[15].text[/.*\((\d+)\).*/i, 1].to_i

                    match_set[:ratings] = ratings
                end

                match_set.save
            end
        end

        print "#{sets.count} loaded\n"

        return sets
    end

    def players_as_text
        return "#{players[0]} vs #{players[1]}"
    end

end
