module EventsHelper

    def match_set_rating_bars(set, width=300)
        html = ''

        total = 0
        set.ratings.values.each {|r| total += r}
        total = total.to_f
        red = (set.ratings[:no] / total).round(2)
        green = (set.ratings[:yes] / total).round(2)
        yellow = (1 - red - green).round(2)

        html += "<div style=\"width:#{width}px\" class=\"rating_bars\">"
        html += "<a target=\"_blank\" href=\"#{set.uri}\" title=\"#{set.uri}\" class=\"green\" style=\"width:#{(green*width).round}px\"></a>"
        html += "<a target=\"_blank\" href=\"#{set.uri}\" title=\"#{set.uri}\" class=\"yellow\" style=\"width:#{(yellow*width).round}px\"></a>"
        html += "<a target=\"_blank\" href=\"#{set.uri}\" title=\"#{set.uri}\" class=\"red\" style=\"width:#{(red*width).round}px\"></a>"
        html += "</div>"

        return raw html
    end

end
