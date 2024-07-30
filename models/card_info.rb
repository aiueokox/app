class CardInfo < ApplicationRecord
    belongs_to :user
  
    key = Rails.application.config.attr_encrypted_key
    Rails.logger.debug("Encryption key in model: #{key} (#{key.bytesize} bytes)")
  
    attr_encrypted :card_number, key: key, attribute: 'encrypted_card_number'
    attr_encrypted :security_code, key: key, attribute: 'encrypted_security_code'
  
    VALID_CARD_BRANDS = ['Visa', 'MasterCard']
    VALID_CARD_HOLDER_NAME_REGEX = /\A[A-Z\s]+\z/
    VALID_CARD_NUMBER_REGEX = /\A\d{15,16}\z/
    VALID_SECURITY_CODE_REGEX = /\A\d{3,4}\z/
    VALID_EXPIRATION_DATE_REGEX = /\A\d{4}-\d{2}-01\z/
  
    validates :user_id, presence: true
    validates :card_brand, presence: true, inclusion: { in: VALID_CARD_BRANDS }
    validates :card_holder_name, presence: true, format: { with: VALID_CARD_HOLDER_NAME_REGEX }
    validates :card_number, presence: true, format: { with: VALID_CARD_NUMBER_REGEX }
    validates :security_code, presence: true, format: { with: VALID_SECURITY_CODE_REGEX }
    validates :expiration_date, presence: true, format: { with: VALID_EXPIRATION_DATE_REGEX }
  end
  