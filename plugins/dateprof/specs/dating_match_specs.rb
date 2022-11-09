module AresMUSH
  describe DatingMatch do
    describe :update_value do
      [
        [:nil, :missed, :missed_connection],
        [:missed, :nil, :missed_connection],
        [:skip, :missed, :missed_connection],
        [:missed, :skip, :missed_connection],
        [:curious, :curious, :maybe],
        [:curious, :interested, :okay],
        [:interested,:curious, :okay],
        [:interested, :interested, :solid],
      ].each do |swipe_type, backswipe_type, expected_value|
        make_swipe = lambda { |type|
          case type
          when :nil then
            nil
          when :missed then
            DatingSwipe.new(type: :interested, missed: true)
          else
            DatingSwipe.new(type: type)
          end
        }

        it "#{swipe_type} and #{backswipe_type} should be #{expected_value}" do
          match = DatingMatch.new()
          allow(match).to receive(:swipe) { make_swipe.call(swipe_type) }
          allow(match).to receive(:backswipe) { make_swipe.call(backswipe_type) }
          match.update_value!
          expect(match.value).to eq(expected_value)
        end
      end
    end
  end
end
