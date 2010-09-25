
# Single Topic Twitter Queue
# Built by Greg Leuch <http://gleu.ch>
# ------------------------------------------------------------
# http://github.com/gleuch/single-topic-twitter-queue
# Released under GNU General Public License.
#


get '/' do
  @tweet = Tweet.first(:order => [:sent_at.desc], :sent_at.not => nil, :sent_at.not => '') rescue nil
  haml :index
end


get '/tweets' do
  "COMING SOON! (TODO!)"
end

# View tweets
get '/tweets/sent' do
  @title = 'Sent Tweets'
  @tweets = Tweet.all(:order => [:sent_at.desc], :sent_at.not => nil) rescue nil
  haml :list
end

get '/tweets/queued' do
  @title = 'Queued Tweets'
  @tweets = Tweet.all(:order => [:created_at.desc], :sent_at => nil) rescue nil
  haml :list
end

get '/tweets/new' do
  "COMING SOON! (TODO!)"
end

post '/tweets/create' do
  "COMING SOON! (TODO!)"
end

post '/tweets/:id/delete' do
  "COMING SOON! (TODO!)"
end

post '/tweets/:id/send' do
  "COMING SOON! (TODO!)"
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
    return twitter_fail($!)#'An error has occured while trying to authenticate with Twitter. Please try again.')
  end
end


# Callback URL to return to after talking with Twitter
get '/auth' do
  @title = 'Authenticate with Twitter'  

  unless params[:denied].blank?
    @error = "We are sorry that you decided to not use #{configatron.site_name}. <a href=\"/\">Click</a> to return."
    haml :fail
  else
    twitter_connect
    @access_token = @twitter_client.authorize(session[:request_token], session[:request_token_secret], :oauth_verifier => params[:oauth_verifier])

    if @twitter_client.authorized?
      begin
        info = @twitter_client.info
      rescue
        twitter_fail and return
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