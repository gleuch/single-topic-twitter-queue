
# Single Topic Twitter Queue
# Built by Greg Leuch <http://gleu.ch>
# ------------------------------------------------------------
# http://github.com/gleuch/single-topic-twitter-queue
# Released under GNU General Public License.
#


require 'rubygems'
require 'sinatra'

# set :environment, 'production'

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
  @title ||= 'Where\'d it go!?'
  @error ||= 'Sorry, but the page you were looking for could not be found.'

  request.xhr? ? halt(404, @error) : haml(:fail, 404)
end

# 500 errors
error do
  @title ||= 'Oops!'
  @error = request.env['sinatra.error'].message
  @error ||= 'An unknown error has occured.'
  
  request.xhr? ? halt(500, @error) : haml(:fail, 500)
end


# Require before
before do
  unless request.env['REQUEST_URI'].match(/\/(connect|auth)/)
    @user = User.first(:order => [:created_at.desc]) rescue nil
    redirect '/connect' and return if @user.blank?
  end

  # Require auth signup ('cept in dev mode)
  require_administrative_privileges unless dev?
end