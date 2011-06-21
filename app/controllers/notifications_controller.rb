#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class NotificationsController < VannaController
  include NotificationsHelper

  def update(opts=params)
    note = Notification.where(:recipient_id => current_user.id, :id => opts[:id]).first
    if note
      note.update_attributes(:unread => false)
      {}
    else
      Response.new :status => 404
    end
  end

  def index(opts=params)
    @aspect = :notification
    notifications = Notification.find(:all, :conditions => {:recipient_id => current_user.id},
                                       :order => 'created_at desc', :include => [:target, {:actors => :profile}]).paginate :page => opts[:page], :per_page => 25
    notifications.each do |n|
      n[:actors] = n.actors
      n[:translation_key] = n.popup_translation_key
      if n.translation_key == "notifications.mentioned"
        n[:post] = Mention.find(n.target_id).post
      else
        n[:post] = Post.find(n.target_id)
      end
      # Go find out if the post exists, and set the target_id to nil if it doesn't
    end
    group_days = notifications.group_by{|note| I18n.l(note.created_at, :format => I18n.t('date.formats.fullmonth_day')) }
    {:group_days => group_days, :notifications => notifications}
  end

  def read_all(opts=params)
    Notification.where(:recipient_id => current_user.id).update_all(:unread => false)
  end
  post_process :html do
    def post_read_all
      Response.new(:status => 302, :location => aspects_path)
    end
  end
end
