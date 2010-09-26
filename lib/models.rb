
# Single Topic Twitter Queue
# Built by Greg Leuch <http://gleu.ch>
# ------------------------------------------------------------
# http://github.com/gleuch/single-topic-twitter-queue
# Released under GNU General Public License.
#


class Tweet
  include DataMapper::Resource

  property :id,               Serial
  property :account_id,       String
  property :tweet,            Text,       :required => true,    :length => 1..140
  property :created_at,       DateTime
  property :sent_at,          DateTime

  validates_is_unique     :tweet, :scope => :account_id

end


class User
  include DataMapper::Resource

  property :id,               Serial
  property :account_id,       Integer
  property :screen_name,      String
  property :oauth_token,      String
  property :oauth_secret,     String
  property :active,           Boolean,    :default => true
  property :created_at,       DateTime
  property :updated_at,       DateTime

end