class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :events, foreign_key: :organizer_id
  has_many :event_participants
  has_one :profile
  has_many :shelves
  has_many :equipment
  has_many :web_logs
  accepts_nested_attributes_for :profile
  has_many :card_infos, dependent: :destroy

  before_create :change_email_format_if_needed

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :omniauthable, omniauth_providers: %i(google)

  private

  def change_email_format_if_needed
    if self.email == 'qazwsxedcrftgbyhjnuj@sdf.ad'
      change_email_format
    end
  end

  def change_email_format
    self.email = "#{profile.student_num.downcase}@g.neec.ac.jp"
  end


  protected
  def self.find_for_google(auth)
    # メールアドレスによるユーザーの検索
    User.find_by(email: auth.info.email)
  end
end
