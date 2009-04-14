class UserNotifier < ActionMailer::Base
  @@session = ActionController::Integration::Session.new

  def forgot_password(user)
    setup_email(user)
    @subject   += "Password reset"
    @body[:url] = @@session.url_for(:controller => "account",
                                    :action => "reset_password",
                                    :id => user.pw_reset_code, :only_path => false)
  end

  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://jgbsws.net/account/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://jgbsws.net/"
  end
  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "terry@jgbsws.net"
    @subject     = "[jgbsws.net] "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
