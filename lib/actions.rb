
# Single Topic Twitter Queue
# Built by Greg Leuch <http://gleu.ch>
# ------------------------------------------------------------
# http://github.com/gleuch/single-topic-twitter-queue
# Released under GNU General Public License.
#


get '/' do
  redirect '/tweets/queued'
end


get '/tweets' do
  redirect '/tweets/queued'
end

# View tweets
get '/tweets/sent' do
  @title = 'Sent Tweets'
  @tweets = Tweet.all(:order => [:sent_at.desc, :id.desc], :sent_at.not => nil) rescue nil
  haml :list
end

get '/tweets/queued' do
  @title = 'Queued Tweets'
  @tweets = Tweet.all(:order => [:created_at.asc, :id.asc], :sent_at => nil) rescue nil
  haml :list
end

get '/tweets/new' do
  haml :new
end

post '/tweets/create' do
  unless params[:tweets].blank?
    params[:tweets].each do |tweet|
      item = Tweet.new(:account_id => @user.account_id, :tweet => tweet) rescue nil
      (@tweets ||= []) << item unless item.save
    end
    
    return haml :new unless @tweets.blank?
  end

  redirect '/tweets/queued'
end

post '/tweets/:id/delete' do
  @tweet = Tweet.get(params[:id]) rescue nil
  raise "Could not find the tweet you requested." if @tweet.blank?
  raise "This tweet has already been sent." unless @tweet.sent_at.blank?
  
  begin
    @tweet.destroy
  rescue
    twitter_fail($!)
  end

  request.xhr? ? halt(200, 'Success') : redirect('/tweets/queued')
end

post '/tweets/:id/send' do
  @tweet = Tweet.get(params[:id]) rescue nil
  raise "Could not find the tweet you requested." if @tweet.blank?
  raise "This tweet has already been sent." unless @tweet.sent_at.blank?

  begin
    # Connect and tweet!
    twitter_connect(@user)
    @twitter_client.update(@tweet.tweet) unless dev?

    # Mark as sent!
    @tweet.sent_at = Time.now
    @tweet.save
  rescue
    twitter_fail($!)
  end

  request.xhr? ? halt(200, 'Success') : redirect('/tweets/queued')
end



# Initiate the conversation with Twitter
get '/connect' do
  @title = 'Connect to Twitter'
  twitter_connect

  begin
    request_token = @twitter_client.request_token(:oauth_callback => "http://#{request.env['HTTP_HOST']}/auth")
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    redirect request_token.authorize_url.gsub('authorize', 'authenticate')
  rescue
    twitter_fail($!) #'An error has occured while trying to authenticate with Twitter. Please try again.')
  end
end


# Callback URL to return to after talking with Twitter
get '/auth' do
  @title = 'Authenticate with Twitter'  

  unless params[:denied].blank?
    raise "We are sorry that you decided to not use #{configatron.site_name}. <a href=\"/\">Click</a> to return."
  else
    twitter_connect
    @access_token = @twitter_client.authorize(session[:request_token], session[:request_token_secret], :oauth_verifier => params[:oauth_verifier])

    if @twitter_client.authorized?
      begin
        info = @twitter_client.info
      rescue
        twitter_fail
      end

      @user = User.first_or_create(:account_id => info['id'])
      @user.active = true
      @user.account_id = info['id']
      @user.screen_name = info['screen_name']
      @user.oauth_token = @access_token.token
      @user.oauth_secret = @access_token.secret
      @user.save

      # Set and clear session data
      session[:user] = @user.id
      session[:account] = @user.account_id
      session[:request_token] = nil
      session[:request_token_secret] = nil
    end

    redirect '/'
  end
end