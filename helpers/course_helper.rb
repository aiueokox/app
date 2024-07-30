module CourseHelper

    def course_name(course_id)

        res = Course.find(course_id)

        p "#{res.name}（#{res.symbol}）"

    end

end
