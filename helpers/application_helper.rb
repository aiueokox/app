module ApplicationHelper
    def generate_code128B(text)

        require 'barby/barcode/code_128'
        require 'barby/outputter/png_outputter'
        
        # パラメータ
        content = text # QRコードの中身
        xdim    = 6  # 一番細いバーの幅
        
        code128 = Barby::Code128B.new(content)
        
        # HTMLのimgタグ用のbase64で出力
        return code128.to_image(xdim: xdim).to_data_url

    end
    def age(dob)
        now = Time.zone.now
        age = now.year - dob.year
        age -= 1 if dob.strftime("%m%d").to_i > now.strftime("%m%d").to_i
        age
      end
      
end
