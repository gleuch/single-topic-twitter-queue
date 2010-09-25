
# Single Topic Twitter Queue
# Built by Greg Leuch <http://gleu.ch>
# ------------------------------------------------------------
# http://github.com/gleuch/single-topic-twitter-queue
# Released under GNU General Public License.
#


require 'rubygems'
require 'sinatra'


configure do |config|
  set :sessions, true

  %w(haml configatron twitter_oauth dm-core dm-types dm-timestamps dm-aggregates dm-ar-finders dm-validations lib/authorize lib/libs lib/models lib/helpers lib/actions).each{|lib| require lib}

  ROOT = File.expand_path(File.dirname(__FILE__))
  configatron.configure_from_yaml("#{ROOT}/settings.yml", :hash => Sinatra::Application.environment.to_s)

  DataMapper.setup(:default, configatron.db_connection.gsub(/ROOT/, ROOT))
  DataMapper.auto_upgrade!
end


# 404 errors
not_found do
  @error = 'Sorry, but the page you were looking for could not be found.</p><p><a href="/">Click here</a> to return to the homepage.'
  haml :fail
end

# 500 errors
error do
  haml :fail
end


# Require before
before do
  unless ['/connect', '/auth'].include?(request.env['REQUEST_PATH'])
    @user = User.first(:order => [:created_at.desc]) rescue nil
    redirect '/connect' and return if @user.blank?
  end

  # Require auth signup ('cept in dev mode)
  require_administrative_privileges unless dev?
end