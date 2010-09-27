
# Single Topic Twitter Queue
# Built by Greg Leuch <http://gleu.ch>
# ------------------------------------------------------------
# http://github.com/gleuch/single-topic-twitter-queue
# Released under GNU General Public License.
#


helpers do
  include Sinatra::Authorization

  def dev?; (Sinatra::Application.environment.to_s != 'production'); end

  def twitter_connect(user={})
    @twitter_client = TwitterOAuth::Client.new(:consumer_key => configatron.twitter_oauth_token, :consumer_secret => configatron.twitter_oauth_secret, :token => (!user.blank? ? user.oauth_token : nil), :secret => (!user.blank? ? user.oauth_secret : nil)) rescue nil
  end

  def twitter_fail(msg=false)
    raise (!msg.blank? ? msg : 'An error has occured while trying to talk to Twitter. Please try again.')
  end

  def partial(name, options = {})
    item_name, counter_name = name.to_sym, "#{name}_counter".to_sym
    options = {:cache => true, :cache_expiry => 300}.merge(options)

    if collection = options.delete(:collection)
      collection.enum_for(:each_with_index).collect{|item, index| partial(name, options.merge(:locals => { item_name => item, counter_name => index + 1 }))}.join
    elsif object = options.delete(:object)
      partial(name, options.merge(:locals => {item_name => object, counter_name => nil}))
    else
      unless options[:cache].blank?
        cache "_#{name}", :expiry => (options[:cache_expiry].blank? ? 300 : options[:cache_expiry]), :compress => false do
          haml "_#{name}".to_sym, options.merge(:layout => false)
        end
      else
        haml "_#{name}".to_sym, options.merge(:layout => false)
      end
    end
  end

  # Modified from Rails ActiveSupport::CoreExtensions::Array::Grouping
  def in_groups_of(item, number, fill_with = nil)
    if fill_with == false
      collection = item
    else
      padding = (number - item.size % number) % number
      collection = item.dup.concat([fill_with] * padding)
    end

    if block_given?
      collection.each_slice(number) { |slice| yield(slice) }
    else
      returning [] do |groups|
        collection.each_slice(number) { |group| groups << group }
      end
    end
  end


  def user_profile_url(screen_name, at=true)
    "<a href='http://www.twitter.com/#{screen_name || ''}' target='_blank'>#{at ? '@' : ''}#{screen_name || '???'}</a>"
  end

  def parse_tweet(tweet)
    tweet = tweet.gsub(/(http|https)(\:\/\/)([A-Z0-9\.\-\_\:]+)(\/?)([\w\=\+\-\.\?\&\%\#\~\/\[\]]+)/i, '<a href="\1\2\3\4\5" target="_blank" rel="nofollow">\1\2\3\4\5</a>')
    tweet = tweet.gsub(/(@)([A-Z0-9\_]+)/i, '<a href="http://www.twitter.com/\2" target="_blank" rel="nofollow">\1\2</a>')
    tweet = tweet.gsub(/(#[A-Z0-9\_]+)/i, '<a href="http://twitter.com/search?q=\1" target="_blank" rel="nofollow">\1</a>')
    tweet
  end

end