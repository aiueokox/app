class Profile < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :department, optional: true
  belongs_to :course, optional: true
  belongs_to :college, optional: true
  mount_uploader :image, ProfileUploader

  before_save :change_student_num_format

  def change_student_num_format
    if self.student_num.present?
      self.student_num = self.student_num.upcase
    end
  end

  scope :search, -> (search_params) do
    # search_paramsが空の場合以降の処理を行わない。
    # >> {}.blank?
    # => true
    return if search_params.blank?

    # パラメータを指定して検索を実行する
    user_id_like(search_params[:user_id])
    .ruby_like(search_params[:ruby])
    .nickname_like(search_params[:nickname])
    .sex_is(search_params[:sex])
    .college_id_is(search_params[:college_id])
    .course_id_is(search_params[:course_id])
    .department_id_is(search_params[:department_id])
    .commute_is(search_params[:commute])
    .email_is(search_params[:email])
    .sign_in_count_is(search_params[:sign_in_count])
    .role_id_is(search_params[:role_id])
    .sign_in_ip_is(search_params[:sign_in_ip])
  end

  # 以下のscopeでSQLを生成
  scope :user_id_like, -> (user_id) { where('user_id LIKE ?', "#{sanitize_sql_like(user_id)}") if user_id.present? }
  scope :ruby_like, -> (ruby) { where('ruby LIKE ? ', "%#{sanitize_sql_like(ruby)}%").or(where('username LIKE ?', "%#{sanitize_sql_like(ruby)}%")) if ruby.present? }
  scope :nickname_like, -> (nickname) { where('nickname LIKE ?', "%#{sanitize_sql_like(nickname)}%") if nickname.present? }
  scope :sex_is, -> (sex) { where(sex: sex) if sex.present? }
  scope :college_id_is, -> (student_num) { where('student_num LIKE ?', "____#{student_num}____") if student_num.present? }
  scope :course_id_is, -> (course_id) { where(course_id: course_id) if course_id.present? }
  scope :department_id_is, -> (department_id) { where(department_id: department_id) if department_id.present? }
  scope :commute_is, -> (commute) { where(commute: commute) if commute.present? }
  #scope :age, -> (dob) { where('dob <= ?', "#{Date.today.strftime("%Y%m%d").to_i - (dob.to_s.to_i * 10000)}") if dob.present? }
  scope :email_is, -> (email) { where('users.email = ?', email) if email.present? }
  scope :sign_in_count_is, -> (sign_in_count) { where('users.sign_in_count = ?', sign_in_count) if sign_in_count.present? }
  scope :role_id_is, -> (role_id) { where('users.role_id LIKE ?', "#{role_id}%") if role_id.present? }
  scope :sign_in_ip_is, -> (sign_in_ip) { where('users.current_sign_in_ip = ? or users.last_sign_in_ip = ?', sign_in_ip,sign_in_ip) if sign_in_ip.present? }
end