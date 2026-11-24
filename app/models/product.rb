class Product < ApplicationRecord
  has_many :order_items
  has_many :promotion_products, dependent: :destroy
  has_many :promotions, through: :promotion_products
  has_many :reviews, dependent: :destroy

  validates :name, :manufacturer, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  before_validation { self.model_number = model_number.presence }
  validates :model_number, uniqueness: { scope: :manufacturer, message: "вже існує у цього виробника" },
                           allow_nil: true
  validates :image_url, format: { with: %r{\A(https?://|/)\S+\z}, message: "має бути посиланням (https://...) або шляхом (/images/...)" },
                        allow_blank: true

  scope :active, -> { where(active: true) }
  # Товари для каталогу пральних машин (без подарункових сертифікатів)
  scope :catalog, -> { active.where(gift_card: [false, nil]) }
  scope :search, ->(q) { where("name LIKE :q OR model_number LIKE :q", q: "%#{q}%") if q.present? }
  scope :by_manufacturer, ->(m) { where(manufacturer: m) if m.present? }
  scope :by_load_type, ->(t) { where(load_type: t) if t.present? }
  scope :by_energy_class, ->(e) { where(energy_class: e) if e.present? }
  scope :min_spin_speed, ->(s) { where("spin_speed >= ?", s) if s.present? }

  # Фільтр за ціною з урахуванням акції
  scope :price_between, ->(min, max) {
    rel = all
    rel = rel.where("#{Product.effective_price_sql} >= ?", min) if min.present?
    rel = rel.where("#{Product.effective_price_sql} <= ?", max) if max.present?
    rel
  }

  # Сортування за ціною з урахуванням акції
  scope :order_by_price, ->(direction) {
    dir = direction.to_s == "desc" ? "DESC" : "ASC"
    order(Arel.sql("#{Product.effective_price_sql} #{dir}")).order(:id)
  }

  # SQL-вираз «ціна зараз»: ціна з найбільшою діючою знижкою, а якщо акції немає, то звичайна ціна
  def self.effective_price_sql
    sanitize_sql_array([<<~SQL.squish, { now: Time.current, yes: true }])
      ROUND(COALESCE(
        (SELECT products.price * (100 - MAX(pr.discount_percent)) / 100.0
           FROM promotions pr
           INNER JOIN promotion_products pp ON pp.promotion_id = pr.id
          WHERE pp.product_id = products.id
            AND pr.active = :yes
            AND pr.discount_percent IS NOT NULL
            AND pr.starts_at <= :now
            AND pr.ends_at >= :now),
        products.price))
    SQL
  end

  # Середня оцінка (0, якщо відгуків ще немає)
  def rating_avg
    count = reviews_count.to_i
    count.zero? ? 0 : (rating_sum.to_f / count).round(1)
  end

  # Найбільша знижка серед діючих акцій, у яких бере участь товар
  def active_promotion
    return @active_promotion if defined?(@active_promotion)

    @active_promotion = promotions.running.where.not(discount_percent: nil)
                                  .order(discount_percent: :desc).first
  end

  def on_sale?
    active_promotion.present?
  end

  # Ціна з урахуванням акції (використовується в кошику й замовленні)
  def current_price
    promo = active_promotion
    promo ? (price * (100 - promo.discount_percent) / 100).round : price
  end
end