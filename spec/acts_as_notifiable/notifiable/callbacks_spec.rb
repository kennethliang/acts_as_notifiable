require 'spec_helper'

class Notifiable
  include ActsAsNotifiable::Notifiable::Callback

  class << self
    def receiver
      :receiver_method
    end

    def sender
      :sender_method
    end

    def target
      :target_method
    end
  end

  def receiver_method
    true
  end

  def multiple_receivers; end
end

class OtherNotifiable
  include ActsAsNotifiable::Notifiable::Callback

  class << self
    def receiver
      :receiver_method
    end

    def sender
      :sender_method
    end

    def target
      :target_method
    end
  end

  def receiver_method
    true
  end

  def multiple_receivers; end
end

class OtherNotifiable
  class << self
    def receiver
      nil
    end

    def sender
      nil
    end

    def target
      nil
    end
  end
end

class Receiver; end

describe ActsAsNotifiable::Notifiable::Callback do


  describe "#notification_callback" do
    it "should notify any receivers" do
      obj = Notifiable.new
      obj.stub(:notice_receiver).and_return(double('Receiver'))
      obj.should_receive(:notify)
      obj.notification_callback
    end

    it "should only notify if a notice receiver exists" do
      obj = Notifiable.new
      obj.stub(:notice_receiver).and_return(nil)
      obj.should_not_receive(:notify)
      obj.notification_callback
    end
  end

  describe "#interpret_target" do
    context "method as proc" do
      it "should call the proc on the notifiable instance" do
        obj = Notifiable.new

        method = Proc.new { |o| o.receiver_method }
        obj.should_receive(:receiver_method)
        obj.interpret_target(method)
      end
    end

    context "method name" do
      it "should call the method on the instance" do
        obj = Notifiable.new
        obj.should_receive(:receiver_method)
        obj.interpret_target(:receiver_method)
      end
    end
  end

  describe "#notice_receiver" do
    it "should interpret the notification's receiver" do
      obj = Notifiable.new
      obj.should_receive(:interpret_target).with(:receiver_method)
      obj.notice_receiver
    end
  end

  describe "#notice_sender" do
    it "should interpret the notification's sender" do
      obj = Notifiable.new
      obj.should_receive(:interpret_target).with(:sender_method)
      obj.notice_sender
    end

    it "should handle a nil sender gracefully" do
      obj = OtherNotifiable.new
      obj.notice_sender.should be_nil
    end
  end

  describe "#notice_target" do
    it "should interpret the notification's target" do
      obj = Notifiable.new
      obj.should_receive(:interpret_target).with(:target_method)
      obj.notice_target
    end

    it "should handle a nil target gracefully" do
      obj = OtherNotifiable.new
      obj.notice_target.should be_nil
    end
  end

  describe "notify" do
    it "should notify a single receiver" do
      obj = Notifiable.new

      receiver = Receiver.new
      obj.stub(:receiver_method).and_return(receiver)

      obj.should_receive(:notify!).with(receiver)
      obj.notify
    end

    it "should notify multiple receivers" do
      obj = Notifiable.new

      receiver_one = Receiver.new
      receiver_two = Receiver.new
      obj.stub(:receiver_method).and_return([receiver_one, receiver_two])

      obj.should_receive(:notify!).with(receiver_one)
      obj.should_receive(:notify!).with(receiver_two)

      obj.notify
    end
  end

  describe "#notify!" do
    it "should not notify a receiver if the receiver is the same as the sender" do
      obj = Notifiable.new

      receiver = Receiver.new
      obj.stub(:receiver_method).and_return(receiver)
      obj.stub(:sender_method).and_return(receiver)
      obj.should_not_receive(:notify_receiver).with(receiver)
      obj.notify
    end

    it "should notify a receiver" do
      obj = Notifiable.new

      receiver = Receiver.new
      obj.stub(:receiver_method).and_return(receiver)
      obj.stub(:sender_method).and_return(double("Sender"))
      obj.should_receive(:notify_receiver).with(receiver)
      obj.notify
    end
  end

end
