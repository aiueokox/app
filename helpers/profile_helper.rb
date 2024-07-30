module ProfileHelper

    def getProfileByUserID(user_id)

        res = Profile.joins(:department).select("profiles.*, departments.*").where(user_id: user_id,status: nil).first

        return res

    end

    def getCourseInfoByCourseID(course_id)

      getCourse = Course.find(course_id)
      getCollege = College.find(getCourse.college_id)

      courseInfo = []
      courseInfo = courseInfo.append(getCollege.name)
      courseInfo = courseInfo.append(getCourse.name)

      return courseInfo

    end

    def format_birthday(date)
      date.strftime("%Y/%m/%d")
    end


    def format_phone(str)
        return str if str.blank?

        case str.slice(0, 3)
        when '000', '070', '080', '090'
          str.gsub(/(\d{3})(\d{4})(\d{4})/, '\1-\2-\3')
        when /00[1-9]/
          str.slice(1, 11).gsub(/(\d{3})(\d{3})(\d{4})/, '\1-\2-\3')
        else
          str
        end
      end

    def format_age(date)
      return date if date.blank?

        date_format = "%Y%m%d"
        (Date.today.strftime(date_format).to_i - date.strftime(date_format).to_i) / 10000
    end
end
