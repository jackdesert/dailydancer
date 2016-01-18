module MessagePresenter

  class << self
    def by_date_deduplicated(num_days, offset, show_duplicates)
      date_range_with_messages = Util.by_date(Message, num_days, offset)

      date_range_with_messages.each do |date, messages|
        # Cloning messages because deduplicate shifts from the array
        uniques = deduplicate(messages.clone)
        if show_duplicates
          duplicates = messages - uniques
          duplicates.each(&:mark_as_duplicate)
          messages_to_display = messages
        else
          messages_to_display = uniques
        end
        date_range_with_messages[date] = messages_to_display.sort_by(&:subject)
      end

      date_range_with_messages
    end

    private

    def deduplicate(original_messages)
      # This method checks the group of original_messages passed in and if any of
      # them are duplicates, includes only the one with the latest :received_at
      output = []

      while original_messages.length > 0

        message = original_messages.shift
        duplicates = []

        original_messages.each do |other_message|
          duplicates << other_message if message.duplicate_of?(other_message)
        end

        # Delete duplicates from original_messages
        # This is done in a separate step so the array will not change size
        # during the 'each' block above
        duplicates.each do |duplicate|
          original_messages.delete(duplicate)
        end

        message_with_duplicates = duplicates << message

        # Now the message and its duplicates are all in 'duplicates'
        # so we pick the one with the latest received_at

        output << message_with_duplicates.max_by(&:received_at)
      end

      output
    end

  end

end
