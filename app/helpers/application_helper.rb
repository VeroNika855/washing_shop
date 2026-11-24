module ApplicationHelper
  # Фото товару, мініатюра-картка для сертифіката або заглушка, якщо зображення не задано
  def product_image(product, size = nil)
    css = ["photo", size].compact.join(" ")
    if product.gift_card?
      content_tag(:div, content_tag(:span, t("gift.card_label")), class: "#{css} gift-mini")
    elsif product.image_url.present?
      content_tag(:div, image_tag(product.image_url, alt: product.name, loading: "lazy"), class: css)
    else
      content_tag(:div, t("catalog.photo"), class: css)
    end
  end

  # Ціна товару: зі знижкою показує нову, стару й відсоток
  def price_tag(product)
    if product.on_sale?
      content_tag(:p, class: "price") do
        safe_join([
          content_tag(:span, money(product.current_price), class: "price-new"),
          content_tag(:s, money(product.price), class: "price-old"),
          content_tag(:span, "-#{product.active_promotion.discount_percent}%", class: "sale-badge")
        ], " ")
      end
    else
      content_tag(:p, money(product.price), class: "price")
    end
  end

  # Банер акції: власне зображення, або фото товару, або кольорова заглушка
  def promo_banner(promo, size = nil)
    css = ["promo-banner", size].compact.join(" ")
    image = promo.image_url.presence || promo.products.first&.image_url
    if image.present?
      content_tag(:div, image_tag(image, alt: promo.title), class: css)
    else
      label = promo.discount_percent ? "-#{promo.discount_percent}%" : opt(promo.kind)
      content_tag(:div, content_tag(:span, label), class: "#{css} placeholder")
    end
  end

  def promo_days_left(promo)
    [((promo.ends_at - Time.current) / 1.day).ceil, 0].max
  end

  # Тривалість акції для вікна в адмінці: [число, "days"/"hours"]
  def promo_duration(promo)
    return [7, "days"] unless promo

    hours = ((promo.ends_at - promo.starts_at) / 3600).round
    (hours % 24).zero? ? [[hours / 24, 1].max, "days"] : [hours, "hours"]
  end

  # Посилання-чіп: додає параметр до поточного фільтра, повторний клік його скидає
  # (номер сторінки при цьому скидається)
  def chip_path(key, value, path = :products_path)
    q = request.query_parameters.except("page", "more")
    if q[key.to_s] == value.to_s
      q.delete(key.to_s)
    else
      q[key.to_s] = value
    end
    send(path, q)
  end

  # Посилання на сторінку каталогу; more: true показує всі сторінки від першої до n
  def page_url(number, more: false)
    q = request.query_parameters.except("page", "more").merge("page" => number)
    q["more"] = "1" if more
    products_path(q)
  end

  # Які номери показувати: 1 2 3 4 5 … 12
  def page_window(current, total)
    return (1..total).to_a if total <= 7

    if current <= 4
      [*1..5, :gap, total]
    elsif current >= total - 3
      [1, :gap, *((total - 4)..total)]
    else
      [1, :gap, current - 1, current, current + 1, :gap, total]
    end
  end

  # Посилання перемикача мови: лишає користувача на поточній сторінці
  def locale_link(code, label)
    path = if request.get?
             url_for(request.query_parameters.symbolize_keys.merge(locale: code, only_path: true))
           else
             root_path(locale: code)
           end
    link_to label, path, class: "lang #{'active' if I18n.locale.to_s == code}"
  end

  # "9 999 грн" / "9 999 UAH"
  def money(amount)
    "#{number_with_delimiter(amount.to_i, delimiter: ' ')} #{t('common.currency')}"
  end

  # Переклад значень, що зберігаються в БД українською (доставка, оплата, статус, тип завантаження, вид акції)
  def opt(value)
    I18n.t("options.#{value}", default: value.to_s)
  end
end