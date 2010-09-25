
# Single Topic Twitter Queue
# Built by Greg Leuch <http://gleu.ch>
# ------------------------------------------------------------
# http://github.com/gleuch/single-topic-twitter-queue
# Released under GNU General Public License.
#


require 'rubygems'


%w{configatron twitter_oauth net/imap tmail dm-core dm-timestamps dm-aggregates dm-validations}.each{|r| require r}


ROOT = File.expand_path(File.dirname(__FILE__))
REPO_ROOT = ROOT.gsub(/(\/bin)$/i, '')


require "#{REPO_ROOT}/lib/models"
require "#{REPO_ROOT}/lib/libs"


configatron.configure_from_yaml("#{REPO_ROOT}/settings.yml", :hash => (Sinatra::Application.environment.to_s rescue 'development'))

DataMapper.setup(:default, configatron.db_connection.gsub(/ROOT/, REPO_ROOT))
DataMapper.auto_upgrade!



# Don't die upon logout/disconnect (when used w/ ruby *.rb > *.log)
# Signal.trap('HUP', 'IGNORE')
# Signal.trap('INT', 'IGNORE')



def twitter_account
  @user ||= User.first(:order => [:created_at.desc]) rescue nil
rescue
  nil
end

def dev?; (Sinatra::Application.environment.to_s != 'production') rescue false; end

def twitter_connect(user={})
  @twitter_client = TwitterOAuth::Client.new(:consumer_key => configatron.twitter_oauth_token, :consumer_secret => configatron.twitter_oauth_secret, :token => (!user.blank? ? user.oauth_token : nil), :secret => (!user.blank? ? user.oauth_secret : nil)) rescue nil
end