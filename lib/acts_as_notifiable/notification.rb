module ActsAsNotifiable
  module Notification
    extend ActiveSupport::Concern

    included do
      class_eval do
        include ActsAsNotifiable::DeliveryMethods

        before_create :prepare
        after_create :deliver

        belongs_to :sender,     polymorphic: true
        belongs_to :receiver,   polymorphic: true
        belongs_to :notifiable, polymorphic: true

        attr_accessible :sender, :receiver, :notifiable

        scope :apn, where(:apns => true)
        scope :unprocessed, where(:apn_processed => false)
      end
    end

    # Run any courier notification preparations if there are any
    #
    # @see ActsAsNotifiable::Couriers::Courier#prepare
    def prepare
      notifiable.class.couriers.each { |c| c.prepare(self) }
    end

    # Deliver the notification via any couriers injected
    #
    # @see ActsAsNotifiable::Couriers::Courier#inject
    def deliver
      notifiable.class.couriers.each { |c| c.deliver(self) }
    end

  end
end
