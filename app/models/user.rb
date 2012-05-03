class User < ActiveRecord::Base
  has_many :memberships
end
