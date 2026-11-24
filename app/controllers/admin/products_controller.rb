module Admin
  class ProductsController < BaseController
    before_action :set_product, only: %i[edit update toggle]

    def index
      @products = Product.search(params[:q]).order(:manufacturer, :name)
    end

    def new
      @product = Product.new(active: true, stock: 0, price: 0)
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: "Товар створено."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Зміни збережено."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # Приховати / показати товар (фізично не видаляємо)
    def toggle
      @product.update!(active: !@product.active)
      redirect_to admin_products_path,
                  notice: @product.active ? "Товар знову показано в каталозі." : "Товар приховано з каталогу."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
            params.require(:product).permit(:name, :manufacturer, :model_number, :description,
                                      :price, :stock, :load_type, :capacity,
                                      :spin_speed, :energy_class, :active, :image_url)
    end
  end
end