
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

# Ensure host info is set
if configatron.email_imap_url.blank? || configatron.email_imap_port.blank?
  tell "ERROR: An email IMAP address and port number are required!", true, true
  exit 0
end

# Ensure login info is set
if configatron.email_username.blank? || configatron.email_password.blank?
  tell "ERROR: An email username and password are required!", true, true
  exit 0
end



# Lets connect to gmail and grab unread messages, throw them into queue, and logout.
tell "Begin fetching emails from #{configatron.email_username}...", true

begin
  opts = []

  # Connect
  @imap = Net::IMAP.new(configatron.email_imap_url, configatron.email_imap_port, true, nil, false)
  @imap.login(configatron.email_username, configatron.email_password)
  @imap.select('INBOX')
  
  # Get only whitelisted senders
  unless configatron.allowed_senders.blank?
    configatron.allowed_senders.each do |sender|
      opts << 'FROM'
      opts << sender
    end
  end
  opts << 'UNSEEN' # Get only unread messages!
  @unread_emails = @imap.search(opts)
  
  # Display count
  tell "#{@unread_emails.length} unread message#{'s' unless @unread_emails.length == 1}", true

  # Parse through unread messages
  @unread_emails.each do |message_id|
    message_body = nil
    fetched_message = @imap.fetch(message_id,'RFC822')[0].attr['RFC822']
    message = TMail::Mail.parse(fetched_message)

    begin
      # Try to gain plaintext part of message
      if message.multipart?

        # Loop through mulitparts
        message.parts.each do |m|
          case m.content_type
            # Plaintext is best!
            when 'text/plain':
              message_body = m.body
              break # its the best, what we want

            # Something similar, gets the job done
            when 'multipart/related'
              message_body = m.body.gsub(/^.*<td>(.*)<\/td>.*$/im, '\1').strip
          end
        end
      end
    rescue
      tell "ERROR: Could not parse multi-part message contents. (#{$!})"
    end

    message_body ||= message.body # Default to body. (Ugh)

    # Create tweet
    unless message_body.blank?
      tweet = Tweet.new(:tweet => message_body, :account_id => twitter_account.account_id)
      tell tweet.save ? "Saved tweet: #{message_body}" : "Could not save tweet: #{message_body}"
    end

    # @imap.store(message_id, "-FLAGS", [:Seen]) # For dev testing, don't mark as read.
  end


  @imap.expunge()

rescue => err
  tell "ERROR: #{err}", true, true
end


tell "Finished fetching emails.", true, true


exit 0