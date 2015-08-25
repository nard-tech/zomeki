# encoding: utf-8
class Util::Qrcode

  require 'rqrcode_png'

  def self.create(text=nil, path=nil, size=8)
    return nil if text.blank? || path.blank?

    begin
      qr = RQRCode::QRCode.new(text, :size => size, :level => :h )
      png = qr.to_img
      png.resize(114, 114).save(path)
    rescue => e
      warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
      return nil
    end
    
  end


  def self.create_date(text=nil, path=nil, size=8)
    return nil if text.blank? || path.blank?

    begin
      qr = RQRCode::QRCode.new(text, :size => size, :level => :h )
      png = qr.to_img
      return png.resize(114, 114).to_blob
    rescue => e
      warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
      return nil
    end
    return nil
  end

end
