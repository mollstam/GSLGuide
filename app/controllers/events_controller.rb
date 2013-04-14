class EventsController < ApplicationController

    def list
        @events = Event.all.order('date DESC')
    end

    def show
        @event = Event.find(params[:id])
    end

end
