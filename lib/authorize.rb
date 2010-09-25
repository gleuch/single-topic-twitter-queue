
# Single Topic Twitter Queue
# Built by Greg Leuch <http://gleu.ch>
# ------------------------------------------------------------
# http://github.com/gleuch/single-topic-twitter-queue
# Released under GNU General Public License.
#


module Sinatra
  module Authorization
 
    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end
 
    def unauthorized!(realm='Administrative Area')
      headers 'WWW-Authenticate' => %(Basic realm="#{realm}")
      throw :halt, [ 401, 'Authorization Required' ]
    end
 
    def bad_request!
      throw :halt, [ 400, 'Bad Request' ]
    end
 
    def authorized?
      request.env['REMOTE_USER']
    end
 
    def authorize(username, password)
      configatron.auth_logins.each do |login|
        auth = login.split(':')
        return true if auth[0] == username && auth[1] == password
      end
      false
    end
 
    def require_administrative_privileges
      return if authorized?
      unauthorized! unless auth.provided?
      bad_request! unless auth.basic?
      unauthorized! unless authorize(*auth.credentials)
      request.env['REMOTE_USER'] = auth.username
    end
 
    def admin?
      authorized?
    end
 
  end
end