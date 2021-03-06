#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Like < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include ROXML

  include Diaspora::Webhooks
  include Diaspora::Guid
  include Diaspora::Relayable

  include Diaspora::Socketable

  xml_attr :positive
  xml_attr :diaspora_handle

  belongs_to :post
  belongs_to :author, :class_name => 'Person'

  validates_uniqueness_of :post_id, :scope => :author_id
  validates_presence_of :author, :post

  def diaspora_handle
    self.author.diaspora_handle
  end

  def diaspora_handle= nh
    self.author = Webfinger.new(nh).fetch
  end

  def parent_class
    Post
  end

  def parent
    self.post
  end

  def parent= parent
    self.post = parent
  end

  def notification_type(user, person)
    Notifications::Liked if self.post.author == user.person && user.person != person
  end
end
