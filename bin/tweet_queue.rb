
# Single Topic Twitter Queue
# Built by Greg Leuch <http://gleu.ch>
# ------------------------------------------------------------
# http://github.com/gleuch/single-topic-twitter-queue
# Released under GNU General Public License.
#


require 'config'

# Nice formatted outputs
def tell(msg, t_space=false, b_space=false)
  puts "#{t_space ? "\n" : ''}[#{Time.now.to_s}] #{msg}#{b_space ? "\n\n" : ''}"
end


# Ensure a twitter account is synced to this app.
if twitter_account.blank?
  tell "ERROR: You must connect a Twitter account to this app.", true, true
  exit 0
end




# Lets connect to gmail and grab unread messages, throw them into queue, and logout.
tell "Begin sending tweet to @#{twitter_account.screen_name}...", true

begin

  # Grab first tweet, oldest first
  @tweet = Tweet.first(:order => [:created_at.asc], :sent_at => nil) rescue nil
  unless @tweet.blank? || @tweet.tweet.blank?
    begin
      # Connect to Twitter
      twitter_connect(twitter_account)

      begin

        # Send to twitter
        tell "Sending tweet: #{@tweet.tweet}"
        @twitter_client.update(@tweet.tweet)

        begin
          # Mark as sent.
          @tweet.sent_at = Time.now
          @tweet.save
          tell "Sent!"

        rescue
          tell "ERROR: Could not mark tweet as sent."
        end
      rescue
        tell "ERROR: Could not send tweet."
      end
    rescue
      tell "ERROR: Could not connect to Twitter."
    end
  else
    tell "No tweets queued."
  end

rescue => err
  tell "ERROR: #{err}", true, true
end


tell "Finished sending tweet.", true, true


exit 0