time = require 'time'
moment = require 'moment'

module.exports = (Event) ->
    {VCalendar, VEvent} = require './index'

    Event::toIcal = (timezone = "UTC") ->
        startDate = new time.Date @start
        endDate   = new time.Date @end
        startDate.setTimezone timezone, false
        endDate.setTimezone timezone, false
        new VEvent startDate, endDate, @description, @place, @id, @details

    Event.fromIcal = (vevent, timezone = "UTC") ->
        event = new Event()
        event.description = vevent.fields["SUMMARY"] or
                            vevent.fields["DESCRIPTION"]
        event.details = vevent.fields["DESCRIPTION"] or
                            vevent.fields["SUMMARY"]
        event.description ?= event.details
        event.place = vevent.fields["LOCATION"]

        startDate = vevent.fields["DTSTART"]
        startDate = moment startDate, "YYYYMMDDTHHmm00Z"
        if startDate._isUTC
            tz = vevent.fields["DTSTART-TZID"] or timezone
            startDate = new time.Date startDate, tz
            startDate.setTimezone 'UTC'

        endDate = vevent.fields["DTEND"]
        endDate = moment endDate, "YYYYMMDDTHHmm00Z"
        if endDate._isUTC
            endDate = new time.Date endDate, 'UTC'
        else
            tz = vevent.fields["DTEND-TZID"] or timezone
            endDate = new time.Date endDate, tz
            endDate.setTimezone 'UTC'


        event.start = startDate.toString().slice(0, 24)
        event.end = endDate.toString().slice(0, 24)
        event

    Event.extractEvents = (component, timezone) ->
        events = []
        component.walk (component) ->
            # if component.name is 'VTIMEZONE'
            #     timezone = component.fields["TZID"]
            if component.name is 'VEVENT'
                events.push Event.fromIcal component, timezone

        events
