class Promotion < ApplicationRecord
  belongs_to :product, optional: true
  KINDS = ["Знижки", "Кешбеки", "Подарунки", "Гарантія та сервіс", "Розіграші"].freeze

  has_many :promotion_products, dependent: :destroy
  has_many :products, through: :promotion_products

  validates :title, :kind, :starts_at, :ends_at, presence: true
  validates :kind, inclusion: { in: KINDS }, allow_blank: true
  validates :discount_percent, numericality: { only_integer: true, in: 1..90 }, allow_nil: true
  validates :image_url, format: { with: %r{\A(https?://|/)\S+\z}, message: "має бути посиланням (https://...) або шляхом (/images/...)" },
                        allow_blank: true
  validate :ends_after_start

  scope :visible, -> { where(active: true) }
  # Акції, що діють просто зараз
  scope :running, -> { visible.where("starts_at <= :now AND ends_at >= :now", now: Time.current) }
  scope :by_kind, ->(k) { where(kind: k) if k.present? }

  # Стан акції для адмін-списку
  def status
    return :hidden unless active

    now = Time.current
    return :scheduled if starts_at > now
    return :ended if ends_at < now

    :running
  end

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "має бути пізніше за початок акції") if ends_at <= starts_at
  end
end